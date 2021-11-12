class Slider implements Component {

  String t;
  int x = 0;
  int y = 0;
  int h = 52;
  int w;
  PGraphics viewport;
  
  boolean hold;
  boolean over;
  boolean press;
  boolean lock;

  float min;
  float max;
  float value;
  
  float handleX;
  float handleY;
  float handleW = 34;
  float handleH = 18;
  
  Slider(String _t, float _min, float _max) {
      t = _t;
      min = _min;
      max = _max;
  }
  
  void update() {
      rollOver();
      pressEvent();
      if (hold) {
          moveHandle();
      }
  }
  
  void display() {
   if (over) {
     viewport.fill(255);  
      viewport.stroke(0,255,0);
    } else {
      viewport.fill(255);  
      viewport.stroke(0);
    }
    // draw line
     viewport.rect(0, h/2, w, 1);
     // draw handle
     viewport.rect(handleX, handleY, handleW, handleH);
     viewport.fill(0);
     viewport.textAlign(CENTER,CENTER);
     viewport.text(int(value), handleX+handleW/2, h/2);
     viewport.textAlign(LEFT,CENTER);
     viewport.text(t,0,0);
  }

  void setLayout(PGraphics _viewport, int _x, int _y, int _w) {
    viewport = _viewport;
    x = _x;
    y = _y;
    w =_w;
    handleX = x;
    handleY = (h-handleH)/2;
    setValue(min);
  }
  
  boolean rollOver() {
     if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
       over = true;
       return true;
     } else {
       over = false;
       return false;
     }
  }
  
  boolean pressEvent() {
     if (rollOver() && mousePressed) {
         hold = true;
         return true;
     }
     hold = false;
     return false;
  }
  
  int getHeight() {
     return h; 
  }
  
  void setValue(float val) {
      value = constrain(val, min, max);
      setHandle();
  }
  
  int getValue() {
      return int(value);
  }
  
  void moveHandle() {
    float handleMouseX = constrain(mouseX, x+handleW/2, x+w-handleW/2);
    handleX = map(handleMouseX, x+handleW/2, x+w-handleW/2, 0, w-handleW);
    float val = map(handleX/(w-handleW),0,1,min,max);
    setValue(val);
  }
  
  void setHandle() {
      handleX = (w-handleW)*(value-min)/(max-min);
  }
  
    void setLock(boolean b) {
     lock = b; 
  }
}
