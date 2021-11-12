class Label implements Component {
 
  String t;
  int x = 0;
  int y = 0;
  int h = 32;
  int w;
  PGraphics viewport;
  
  int textSize;
  
  boolean lock;
  
  Label(String _t, int _textSize) {
      t = _t;
      textSize = _textSize;
  }
  
  void update() {
      
  }
  
  void display() {
    viewport.stroke(0);
    viewport.fill(0);
    viewport.textAlign(CENTER,CENTER);
    viewport.textFont(createFont("Courier",12));
    viewport.textSize(textSize);
    viewport.text(t, w/2, h/2);    
    viewport.textSize(12);
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
