import beads.*;
import java.util.Arrays;
import nervoussystem.obj.*;

AudioContext ac;
PowerSpectrum ps;
Frequency freq;

int timer;
int recordTime = 500;
boolean recording = false;

IntList xPoints;
IntList yPoints;
int nSides = 5;
int yHeight = 50;

VaseBuilder vase;

void setup() {
  size(600, 600, P3D);
  ac = AudioContext.getDefaultContext();

  Gain g = new Gain(2, 0.2);
  UGen input = ac.getAudioInput(new int[]{1, 2});
  print(ac.getAudioFormat().outputs);
  g.addInput(input);
  ac.out.addInput(g);
  /*
   * To analyse a signal, build an analysis chain.
   */
  ShortFrameSegmenter sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(ac.out);
  FFT fft = new FFT();
  ps = new PowerSpectrum();
  freq = new Frequency(ac.getSampleRate());

  sfs.addListener(fft);     // Do an FFT on the short time segments
  fft.addListener(ps);      // Calculate the Power Spectrum from the FFT.
  ps.addListener(freq);     // Look for the frequency peaks in the power spectrum
  ac.out.addDependent(sfs);


  sfs.addSegmentListener(new SegmentListener() {

    public void newSegment(TimeStamp timeStampStart, TimeStamp timeStampEnd) {
    }
  }
  );
  ac.start();

  background(0);
  stroke(255);
  fill(100);
  xPoints = new IntList();
  yPoints = new IntList();
}

void draw() {
  //background(0);
  //if (keyPressed && key == 'r') {
  //  if (!recording) {
  //    xPoints.clear();
  //    yPoints.clear();
  //    background(0);
  //    recording = true;
  //    timer = millis();
  //  }
  //}
  //if (recording) {
  //  text("recording", 10, 10);
  //  println(freq.getFeatures());
  //  if (millis() - timer > recordTime) {
  //    recording = false;
  //    vase = new VaseBuilder(xPoints, yPoints, nSides);
  //    vase.display(width/2, height/3, 0);
  //  }
  //  int x = int(map(freq.getFeatures(), 0, 2000, 10, 250));
  //  int y = int(map(millis() - timer, 0, recordTime, 0, height));
  //  ellipse(x, y, 1, 1);
  //  xPoints.append(x);
  //  yPoints.append(y);
  //}
  if (vase != null) {
    vase.display(width/2, height/3, 0);
  }
}

void mousePressed() {
  if (vase != null) {
     vase.vase.setVisible(false); 
  }
  xPoints.clear();
  yPoints.clear();
  background(0);
  recording = true;
}

void mouseDragged() {
  int x = int(map(mouseX,0,width,10,250));
  int y = int(map(mouseY,0,height,0,250));
  stroke(255);
  ellipse(mouseX, mouseY, 1, 1);
  if (mouseY%yHeight == 0) {
  xPoints.append(x);
  yPoints.append(y);
  }
}

void mouseReleased() {
  vase = new VaseBuilder(xPoints, yPoints, nSides);
  vase.record();
  background(0);
}

void keyPressed() {
  background(0);
  vase.vase.rotateY(0.1);
}
