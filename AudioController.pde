import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.analysis.FFT;

class AudioController {

  Minim minim;

  AudioInput in;
  AudioRecorder recorder;
  boolean recording = false;
  boolean recorded = false;
  FloatList levels;
  FloatList freqs;

  FFT fft;
  float[] buffer;
  int timeSize = 1024;
  int sampleRate = 44100;
  
  AudioOutput out;
  FilePlayer player;

  AudioController(Object o) {
    minim = new Minim(o);
    fft = new FFT(timeSize, sampleRate);
    in = minim.getLineIn(Minim.STEREO, timeSize);
    out = minim.getLineOut( Minim.STEREO );
    levels = new FloatList();
    freqs = new FloatList();
  }

  void update() {
    if (recording) {
      levels.append(in.left.level());
      fft.forward(in.mix);
      float ampMax = 0;
      int bandMax = -1;
      for(int i = 0; i < fft.specSize(); i++)
      {
        float amp = fft.getBand(i);
        if (amp > ampMax) {
          ampMax = amp;
          bandMax = i;
        }
      }
      if (bandMax != -1) {
        freqs.append(calcFrequency(bandMax));
      }
    }
  }

  void startRecording() {
    if (!recording) {
      recorder = minim.createRecorder(in, "myrecording.wav");
      recorder.beginRecord();
      levels = new FloatList();
      freqs = new FloatList();
      println("Recording...");
      recording = true;
    }
  }

  void endRecording() {
    if (recording) {
      recorder.endRecord();
      recorder.save();
      println("Saving recording...");
      recording = false;
      recorded = true;
    }
  }

  void playRecording() {
    if (recorded) {
      player = new FilePlayer(minim.loadFileStream("myrecording.wav"));
      player.patch(out);
      player.play();
      println("Playing recording...");
    }
  }

  void display(PGraphics viewport) {
    if (levels.size() > 1) {     
      float minLevel = 0.0;
      float maxLevel = 0.4;
      for (int i=0; i<levels.size(); i++) {
        float x = map(i, 0, levels.size(), 0, viewport.width);
        float y = map(levels.get(i), minLevel, maxLevel, 0, 0.9*viewport.height);
        viewport.fill(0);
        viewport.stroke(0);
        float y1 = (viewport.height-y)/2;
        float y2 = (viewport.height+y)/2;
        viewport.line(x, y1, x, y2);
      }
    }
  }
  
  float calcFrequency(float bandIdx) {
      float freq = (bandIdx/timeSize) * sampleRate;
      return freq;
  }
}
