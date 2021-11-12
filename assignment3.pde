import java.util.Arrays;
import nervoussystem.obj.*;
import processing.sound.*;
import processing.sound.Waveform;

int timer;
int recordTime = 500;
boolean recording = false;

int nSegments = 5;

ModelBuilder model;
AudioController audio;
CameraController cam;

float cameraX, cameraY, cameraZ, cameraRotX, cameraRotY, cameraRadius;
float cameraRotXAmt = 10;
float cameraRotYAmt = 10;
boolean movingCamera = false;

ViewController vc;

void setup() {
  frameRate(30);
  shapeMode(CENTER);
  textAlign(CENTER, CENTER);
  size(1280, 720, P3D);
  audio = new AudioController(this);
  cam = new CameraController();
  model = new ModelBuilder();
  vc = new ViewController(cam, model, audio);

  background(255);
  stroke(255);
}

void draw() {
  background(255);

  vc.update();
  vc.display();
}

void keyReleased() {
  if (key == ' ') {
    audio.endRecording();
    recording = false;
    model.profile = audio.levels;
    model.build();
    if (model.mesh != null) {
      model.mesh.setVisible(true);
      cam.reset(2*max(model.h, 2*model.r), 30, 70);
    }
    background(0);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  cam.zoom(-e*10);
}

void mouseReleased() {
  for (int i=0; i<vc.settingsLayout.components.size(); i++) {
    vc.settingsLayout.components.get(i).setLock(false);
  }
}

void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("Folder selected: " + selection.getAbsolutePath());
    model.filePath = selection.getAbsolutePath();
    model.readyToWrite = true;
  }
}
