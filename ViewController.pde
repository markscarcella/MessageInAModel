
class ViewController {

  PGraphics mainViewport;
  int mainX = 0;
  int mainY = 0;
  int mainW = int(0.8*width);
  int mainH = int(0.9*height);
  PGraphics recordingViewport;

  PGraphics settingsViewport;
  int settingsX = mainW;
  int settingsY = 0;
  int settingsW = width - mainW;
  int settingsH = height;

  PGraphics infoViewport;
  int infoX = mainX;
  int infoY = mainH;
  int infoW = mainW;
  int infoH = height-mainH;
  
  CameraController cam;
  ModelBuilder model;
  AudioController audio;
  boolean move;
  boolean saving;
  int samples;

  Button recordButton;
  Button saveButton;

  Slider segmentsSlider;
  Slider radiusSlider;
  Slider heightSlider;
  Slider stepSlider;
  Slider fminSlider;
  Slider fmaxSlider;

  Radio topRadio;
  Radio bottomRadio;
  Radio modeRadio;

  Label spacerLabel;
  Label menuLabel;
  Label infoLabel;

  ColumnLayout settingsLayout;
  ColumnLayout infoLayout;

  ViewController(CameraController _cam, ModelBuilder _obj, AudioController _audio) {
    mainViewport = createGraphics(mainW, mainH, P3D);
    recordingViewport = createGraphics(mainW, mainH);
    settingsViewport = createGraphics(settingsW, settingsH);
    infoViewport = createGraphics(infoW, infoH);

    cam = _cam;
    model = _obj;
    audio = _audio;

    settingsLayout = new ColumnLayout(settingsViewport, settingsX, settingsY, settingsW);
    
    menuLabel = new Label("MESSAGE IN A MODEL", 18);
    settingsLayout.addComponent(menuLabel);
    
    recordButton = new Button("RECORD");
    settingsLayout.addComponent(recordButton);

    spacerLabel = new Label(" ", 12);
    settingsLayout.addComponent(spacerLabel);

    segmentsSlider = new Slider("SEGMENTS", 3, 40);
    settingsLayout.addComponent(segmentsSlider);

    radiusSlider = new Slider("INNER RADIUS (% OUTER RADIUS)", 25, 75);
    settingsLayout.addComponent(radiusSlider);

    heightSlider = new Slider("HEIGHT (% WIDTH)", 50, 200);
    settingsLayout.addComponent(heightSlider);

    stepSlider = new Slider("SAMPLES", 2, 10);
    settingsLayout.addComponent(stepSlider);
    
    fminSlider = new Slider("LOW FREQUENCY CUTOFF (Hz)",0,3000);
    settingsLayout.addComponent(fminSlider);

    fmaxSlider = new Slider("HIGH FREQUENCY CUTOFF (Hz)",0,3000);
    settingsLayout.addComponent(fmaxSlider);
    
    modeRadio = new Radio("SHOW MESH");
    settingsLayout.addComponent(modeRadio);
    
    topRadio = new Radio("INCLUDE TOP");
    settingsLayout.addComponent(topRadio);

    bottomRadio = new Radio("INCLUDE BOTTOM");
    settingsLayout.addComponent(bottomRadio);
    
    settingsLayout.addComponent(spacerLabel);
    
    saveButton = new Button("SAVE");
    settingsLayout.addComponent(saveButton);
    
    infoLayout = new ColumnLayout(infoViewport, infoX, infoY, infoW);
    infoLabel = new Label("",12);
    infoLayout.addComponent(infoLabel);
    
    reset();
  }

  void update() {
    // update display panel
    
    if (recordButton.press) {
      model.setProfile(audio.levels);
      model.setColours(audio.freqs);

      if (audio.recording) {
        audio.endRecording();
        cam.reset(3*height, 70, 70);
        reset();
      } else {
        audio.startRecording();
      }
    }
    
    if (model.saving && model.readyToWrite) {
        model.writeModel(); 
        model.readyToWrite = false;
        reset();
    }
    
    if (saveButton.press) {
      model.saveModel();
    }

    if (segmentsSlider.hold) {
      model.nSegments = segmentsSlider.getValue();
    }

    if (radiusSlider.hold) {
      model.setRMin(radiusSlider.getValue());
    }

    if (heightSlider.hold) {
      model.setDy(heightSlider.getValue());
    }

    if (stepSlider.hold) {
      samples = stepSlider.getValue();
      while (!model.setSteps(samples)) {
        samples--;
        stepSlider.setValue(model.samples);
      }
    }
    
    if (fmaxSlider.hold) {
      model.fMax = fmaxSlider.getValue();
      model.setColours(audio.freqs);
    }
    
    if (fminSlider.hold) {
      model.fMin = fminSlider.getValue();
      model.setColours(audio.freqs);
    }
    
    moveEvent();
    if (move) {
      cam.orbit(pmouseY-mouseY, pmouseX-mouseX);
    }

    cam.update();
    model.update();
    audio.update();
    settingsLayout.update();

    model.addTop = topRadio.selected;
    model.addBottom = bottomRadio.selected;
    model.drawMesh = modeRadio.selected;

  }

  void display() {
    // main/recording panel
    if (audio.recording) {
      recordingViewport.beginDraw();
      recordingViewport.background(255);
      recordButton.t = "STOP";
      audio.display(recordingViewport);
      recordingViewport.endDraw();
      image(recordingViewport, mainX, mainY);
    } else {
      mainViewport.beginDraw();
      mainViewport.background(255);
      recordButton.t = "RECORD";
      if (model.profile.size() != 0) {
        cam.display(mainViewport);
        model.display(mainViewport);
      }
      mainViewport.endDraw();
      image(mainViewport, mainX, mainY);
    }

    // settings panel
    settingsViewport.beginDraw();
    settingsViewport.background(255);
    settingsViewport.textSize(12);
    settingsLayout.display();
    settingsViewport.endDraw();
    image(settingsViewport, settingsX, settingsY);
    
    // info panel
    infoViewport.beginDraw();
    infoViewport.background(255);
    if (model.profile.size() == 0) {
      infoLabel.t = "PRESS RECORD TO LEAVE A MESSAGE";
    } else {
      infoLabel.t = "CLICK AND DRAG TO VIEW / SCROLL TO ZOOM / EDIT SETTINGS / SAVE YOUR MODEL / RECORD A NEW MESSAGE";
    }
    if (audio.recording) {
      infoLabel.t = "PRESS STOP TO CREATE YOUR MODEL";
    } 
    infoLayout.display();
    infoViewport.endDraw();
    image(infoViewport, infoX, infoY);
  }
  
  void reset() {
        segmentsSlider.setValue(segmentsSlider.max);
        segmentsSlider.setHandle();
        model.nSegments = segmentsSlider.getValue();

        radiusSlider.setValue(25);
        radiusSlider.setHandle();
        model.setRMin(radiusSlider.getValue());

        heightSlider.setValue(100);
        heightSlider.setHandle();
        model.setDy(heightSlider.getValue());

        stepSlider.max = model.profile.size();
        stepSlider.setValue(stepSlider.max);
        stepSlider.setHandle();
        model.setSteps(int(stepSlider.value));
       
        fminSlider.setValue(0);
        fminSlider.setHandle();
        model.fMin = fminSlider.getValue();
        fmaxSlider.setValue(3000);
        fmaxSlider.setHandle();
        model.fMax = fmaxSlider.getValue();
        model.setColours(audio.freqs);

        modeRadio.selected = false;
        topRadio.selected = false;
        bottomRadio.selected = false;
  }

  void moveEvent() {
    move = false;
    if (mouseX < mainW && mouseY < mainH) {
      if (mousePressed && mouseButton == LEFT) {
        cursor(MOVE);
        move = true;
      } else {
        cursor(HAND);
      }
    } else {
      cursor(ARROW);
    }
  }
}
