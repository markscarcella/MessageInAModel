class ColumnLayout {
  
  int paddingX = 10;
  int paddingY = 10;
  ArrayList<Component> components;
  PGraphics viewport;
  int x;
  int y;
  int w;
  int h = paddingY;
  
  ColumnLayout(PGraphics _viewport, int _x, int _y, int _w) {
    components = new ArrayList<Component>();
    viewport = _viewport;
    x = _x;
    y = _y;
    w = _w;
  }
    
  void update() {
      for (int i=0; i<components.size(); i++) {
         components.get(i).update(); 
      }
  }
  
   void display() {
      viewport.translate(paddingX,paddingY);
      for (int i=0; i<components.size(); i++) {
         components.get(i).display(); 
         viewport.translate(0, paddingY + components.get(i).getHeight());
      }
  }
  
  void addComponent(Component c) {
     c.setLayout(viewport, x+paddingX, y+h, viewport.width-2*paddingX);
     components.add(c); 
     h += c.getHeight()+paddingY;
  }
}
