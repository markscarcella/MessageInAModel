class Radio implements Component {

  String t;
  int x = 0;
  int y = 0;
  int h = 32;
  int w;
  PGraphics viewport;

  boolean lock;
  boolean over;
  boolean press;

  boolean selected = false;
  int innerPadding = 8;
  int radioW = h;
  int radioH = radioW;

  Radio(String _t) {
    t = _t;
  }

  void update() {
    rollOver();
    pressEvent();
  }

  void display() {
    if (over) {
      viewport.noFill();
      viewport.stroke(0, 255, 0);
    } else {
      viewport.noFill();
      viewport.stroke(0);
    }
    viewport.rect(w-radioW, 0, radioW, h);
    if (selected) {
      viewport.noStroke();
      viewport.fill(0, 255, 0);
      viewport.rect(w-radioW+innerPadding, innerPadding, radioW - 2*innerPadding, radioH - 2*innerPadding);
    }
    viewport.fill(0);
    viewport.textAlign(LEFT,CENTER);
    viewport.text(t, 0, h/2);
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
      selected = !selected;
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
