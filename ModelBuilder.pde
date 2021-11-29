import java.util.List;
import java.util.Date;
import java.text.SimpleDateFormat;

class ModelBuilder {

  PShape mesh;
  PShape top;
  PShape[] bands;
  PShape bottom;
  float dy = 20;
  float h;
  float r;
  float rMin = 50;
  float rMax = 500;
  float nSegments;
  float step = 1;
  float samples;
  FloatList profile;
  FloatList colours;
  float fMin = 0;
  float fMax = 3000;

  boolean move;
  boolean addTop;
  boolean addBottom;
  boolean drawMesh;

  String filePath;
  boolean saving;
  boolean readyToWrite;

  ModelBuilder() {
    profile = new FloatList();
    colours = new FloatList();
    mesh = createShape(GROUP);
  }

  void update() {
    if (saving || mesh == null) {
      return;
    }
    build();
    if (drawMesh) {
      mesh.setFill(false);
      mesh.setStroke(true);
      mesh.setStroke(color(0, 0, 0));
    } else {
      mesh.setStroke(false);
    }
  }
  
  void display(PGraphics viewport) {
    if (mesh == null) {
      return;
    }
    viewport.noFill();
    viewport.stroke(0, 255, 0);
    viewport.box(rMax*2.1, h*1.1, rMax*2.1);

    viewport.directionalLight(255, 255, 255, 1, -1, 0);
    viewport.ambientLight(80, 80, 80);
    viewport.translate(0, -h/2, 0);
    viewport.stroke(0, 0, 0);
    viewport.shape(mesh);
  }

  void setProfile(FloatList levels) {
    profile = levels;
  }
  
  void setColours(FloatList freqs) {
    colours = new FloatList();
    for (int i=0; i<freqs.size(); i++) {
      float f = freqs.get(i);
      if (fMax == 0) {
        colours.append(0);
      } else {
        float hue = map(f, fMin, fMax, 0, 1);
        if (hue < 0 || hue > 1) {
          hue = -1;
        }
        colours.append(hue);
      }
    }
  }

  void setRMin(float pct) {
    rMin = (pct/100)*rMax;
  }

  void setDy(float pct) {
    dy = (pct/100)*(2*rMax/profile.size());
  }

  boolean setSteps(int divisions) {
    step = int(float(profile.size())/(divisions-1));
    if (divisions != 2) {
      int prevStep = int(float(profile.size())/(divisions-2));
      if (prevStep == step) {
        return false;
      }
    }
    samples = profile.size()/step;
    return true;
  }


  void build() {
    if (profile.size() < 2) {
      return;
    }
    mesh = createShape(GROUP);
    h = profile.size()*dy;

    // create shape for displaying
    top = createShape();
    top.beginShape(TRIANGLE_FAN);
    top.colorMode(HSB,1.0);
    top.fill(colours.get(profile.size()-1),1,colours.get(profile.size()-1)==-1?0:1);
      
    for (int segment=0; segment<nSegments+1; segment++) {
      float dTheta = TWO_PI/nSegments;
      float r = map(profile.get(profile.size()-1), profile.min(), profile.max(), rMin, rMax);
      float x = r*cos(segment*dTheta);
      float y = (profile.size()-1)*dy;
      float z = r*sin(segment*dTheta);
      top.vertex(x, y, z);
    }
    top.endShape(CLOSE);

    bands = new PShape[profile.size()];

    boolean lastStep = false;
    // for each band
    for (int bandIdx=0; bandIdx<profile.size()-1; bandIdx+=step) {
      int i1 = bandIdx;
      int i2 = bandIdx+int(step);
      if (profile.size()-i2 < step) {
        i2 = profile.size()-1;
        lastStep = true;
      }

      // draw a ring of triangles
      bands[bandIdx] = createShape();
      bands[bandIdx].beginShape(TRIANGLE_STRIP);
      bands[bandIdx].colorMode(HSB,1.0);
      bands[bandIdx].fill(colours.get(i1),1,colours.get(profile.size()-1)==-1?0:1);
      for (int segment=0; segment<nSegments+1; segment++) {
        float dTheta = TWO_PI/nSegments;

        float r1 = map(profile.get(i1), profile.min(), profile.max(), rMin, rMax);
        float x1 = r1*cos(segment*dTheta);
        float y1 = i1*dy;
        float z1 = r1*sin(segment*dTheta);

        float r2 = map(profile.get(i2), profile.min(), profile.max(), rMin, rMax);
        float x2 = r2*cos(segment*dTheta);
        float y2 = (i2)*dy;
        float z2 = r2*sin(segment*dTheta);

        bands[bandIdx].vertex(x1, y1, z1);
        bands[bandIdx].vertex(x2, y2, z2);
      }
      bands[bandIdx].endShape(CLOSE);

      if (lastStep) {
        lastStep = false;
        break;
      }
    }

    bottom = createShape();
    bottom.beginShape(TRIANGLE_FAN);
    bottom.colorMode(HSB,1.0);
    bottom.fill(colours.get(0),1,colours.get(profile.size()-1)==-1?0:1);
    
    for (int i=0; i<nSegments+1; i++) {
      float dTheta = TWO_PI/nSegments;
      float r = map(profile.get(0), profile.min(), profile.max(), rMin, rMax);
      float x = r*cos(i*dTheta);
      float y = 0;
      float z = r*sin(i*dTheta);
      bottom.vertex(x, y, z);
    }

    bottom.endShape(CLOSE);

    if (addBottom) {
      mesh.addChild(bottom);
    }
    for (int i=0; i<profile.size(); i++) {
      mesh.addChild(bands[i]);
    }
    if (addTop) {
      mesh.addChild(top);
    }
  }

  void saveModel() {
    saving = true;
    selectFolder("Select a save folder:", "folderSelected");
  }

  void writeModel() {
    if (profile.size() < 2) {
      return;
    }
    h = profile.size()*dy;

    String timeStamp = new SimpleDateFormat("yyyy-MM-dd' at 'hh.mm.ss a").format(new Date());

    OBJExport o = (OBJExport) createGraphics(int(2.1*rMax),int(1.1*h),"nervoussystem.obj.OBJExport", filePath+"/Message In A Model "+timeStamp+".obj");
    o.setColor(true);

    o.beginDraw();
    o.colorMode(HSB,1.0);
      
    if (addBottom) {
      o.beginShape(TRIANGLE_FAN);
      o.fill(colours.get(0),1,colours.get(profile.size()-1)==-1?0:1);
      for (int i=0; i<nSegments+1; i++) {
        float dTheta = TWO_PI/nSegments;
        float r = map(profile.get(0), profile.min(), profile.max(), rMin, rMax);
        float x = r*cos(i*dTheta);
        float y = 0;
        float z = r*sin(i*dTheta);
        o.vertex(x, y, z);
      }
      o.endShape(CLOSE);
    }

    bands = new PShape[profile.size()];
    boolean lastStep = false;
    // for each band
    for (int bandIdx=0; bandIdx<profile.size()-1; bandIdx+=step) {
      int i1 = bandIdx;
      int i2 = bandIdx+int(step);
      if (profile.size()-i2 < step) {
        i2 = profile.size()-1;
        lastStep = true;
      }
      
      // draw a ring of triangles
      o.beginShape(TRIANGLE_STRIP);
      o.fill(colours.get(i1),1,colours.get(profile.size()-1)==-1?0:1);

      for (int segment=0; segment<nSegments+1; segment++) {
        float dTheta = TWO_PI/nSegments;

        float r1 = map(profile.get(i1), profile.min(), profile.max(), rMin, rMax);
        float x1 = r1*cos(segment*dTheta);
        float y1 = i1*dy;
        float z1 = r1*sin(segment*dTheta);

        float r2 = map(profile.get(i2), profile.min(), profile.max(), rMin, rMax);
        float x2 = r2*cos(segment*dTheta);
        float y2 = (i2)*dy;
        float z2 = r2*sin(segment*dTheta);
        o.vertex(x1, y1, z1);
        o.vertex(x2, y2, z2);
      }
      o.endShape(CLOSE);

      if (lastStep) {
        lastStep = false;
        break;
      }
    }

    if (addTop) {
      o.beginShape(TRIANGLE_FAN);
      o.fill(colours.get(profile.size()-1),1,colours.get(profile.size()-1)==-1?0:1);
      for (int segment=0; segment<nSegments+1; segment++) {
        float dTheta = TWO_PI/nSegments;
        float r = map(profile.get(profile.size()-1), profile.min(), profile.max(), rMin, rMax);
        float x = r*cos(segment*dTheta);
        float y = (profile.size()-1)*dy;
        float z = r*sin(segment*dTheta);
        o.vertex(x, y, z);
      }
      o.endShape(CLOSE);
    }
    
    o.endDraw();
    o.dispose();
    println("Model saved!");
    profile.clear();
    saving = false;
  }
}
