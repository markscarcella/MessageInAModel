class Button implements Component {
 
  String t;
  int x = 0;
  int y = 0;
  int h = 32;
  int w;
  PGraphics viewport;

  boolean lock;
  boolean over;
  boolean press;

  Button(String _t) {
      t = _t;
  }
  
  void update() {
      rollOver();
      pressEvent();
  }
  
  void display() {
    if (over) {
     viewport.noFill();  
      viewport.stroke(0,255,0);
    } else {
      viewport.noFill();  
      viewport.stroke(0);
    }
     viewport.rect(0, 0, w, h);
     viewport.fill(0);
     viewport.textAlign(CENTER,CENTER);
     viewport.text(t, w/2, h/2);
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
     if (rollOver() && mousePressed && !lock) {

         lock = true;
         press = true;
         return true;
     }
     press = false;
     return false;
  }
  
  void setLayout(PGraphics _viewport, int _x, int _y, int _w) {
    viewport = _viewport;
    x = _x;
    y = _y;
    w = _w;
  }
    
  int getHeight() {
     return h; 
  }
  
  void setLock(boolean b) {
     lock = b; 
  }
  
}
