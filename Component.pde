interface Component {
  void update();
  void display();
  int getHeight();
  void setLayout(PGraphics pg, int x, int y, int w);
  void setLock(boolean b);
}
