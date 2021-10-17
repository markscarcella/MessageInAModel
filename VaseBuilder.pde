
class VaseBuilder {

  PShape vase;
  PShape base;
  PShape[] rings;
  IntList x;
  IntList y;
  int n;

  VaseBuilder(IntList _x, IntList _y, int _n) {
    x = _x;
    y = _y;
    n = _n;
    vase = createShape(GROUP);
    build();
  }

  void build() {
    // draw base
    base = createShape();
    base.beginShape();
    for (int i=0; i<n+1; i++) {
      float theta = TWO_PI/nSides;
      float x = cos(i*theta)*xPoints.get(xPoints.size()-1);
      float y = yPoints.get(yPoints.size()-1);
      float z = sin(i*theta)*xPoints.get(xPoints.size()-1);
      base.vertex(x, y, z);
    }
    base.endShape(CLOSE);

    rings = new PShape[xPoints.size()];

    // for each step
    for (int i=0; i<xPoints.size()-1; i++) {

      // draw a ring of triangles
      rings[i] = createShape();
      rings[i].beginShape(TRIANGLE_STRIP);
      for (int j=0; j<n+1; j++) {
        float theta = TWO_PI/nSides;

        float x1 = cos(j*theta)*xPoints.get(i);
        float y1 = yPoints.get(i);
        float z1 = sin(j*theta)*xPoints.get(i);

        float x2 = cos(j*theta)*xPoints.get(i+1);
        float y2 = yPoints.get(i+1);
        float z2 = sin(j*theta)*xPoints.get(i+1);

        rings[i].vertex(x1, y1, z1);
        rings[i].vertex(x2, y2, z2);            
      }
      rings[i].endShape(CLOSE);
    }
    vase.addChild(base);
    for (int i=0; i<xPoints.size(); i++) {
      vase.addChild(rings[i]);
    }
  }

  void record() {
    beginRecord("nervoussystem.obj.OBJExport", "vase.obj");

    // draw base
    beginShape();
    for (int i=0; i<n+1; i++) {
      float theta = TWO_PI/nSides;
      float x = cos(i*theta)*xPoints.get(xPoints.size()-1);
      float y = yPoints.get(yPoints.size()-1);
      float z = sin(i*theta)*xPoints.get(xPoints.size()-1);
      vertex(x, y, z);
    }
    endShape(CLOSE);

    rings = new PShape[xPoints.size()];

    // for each step
    for (int i=0; i<xPoints.size()-1; i++) {

      // draw a ring of triangles
      beginShape(TRIANGLE_STRIP);
      for (int j=0; j<n+1; j++) {
        float theta = TWO_PI/nSides;

        float x1 = cos(j*theta)*xPoints.get(i);
        float y1 = yPoints.get(i);
        float z1 = sin(j*theta)*xPoints.get(i);

        float x2 = cos(j*theta)*xPoints.get(i+1);
        float y2 = yPoints.get(i+1);
        float z2 = sin(j*theta)*xPoints.get(i+1);

        vertex(x1, y1, z1);
        vertex(x2, y2, z2);
      }
      endShape(CLOSE);
    }
    endRecord();
  }
  
  void display(int xPos, int yPos, int zPos) {
    pushMatrix();
    translate(xPos,yPos,zPos);
    rotateX(-PI/6);
    fill(255);
    noStroke();
    directionalLight(126, 126, 156, -1, 1, 0);
    ambientLight(80, 80, 80); 
    shape(vase);
    popMatrix();
    endRecord();
  }
}
