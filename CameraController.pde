
class CameraController {
  float x = 0;
  float y = 0;
  float z = 0;
  float r = 0; // radius of orbit
  float phi = 0; // rotation around X-Z
  float theta = 0; // rotation around Y

  CameraController() {
    reset(height, 30, 70);
  }

  void update() {
    x = r * cos(radians(phi)) * sin(radians(theta));
    y = r * cos(radians(theta));
    z = r * sin(radians(phi)) * sin(radians(theta));
  }
  
  void display(PGraphics viewport) {
    viewport.camera(x, y, z, 0, 0, 0, 0, -1, 0);
  }

  void zoom(float amt) {
    r = constrain(r - amt, 0.1*height, 5*height);
    update();
  }

  void orbit(int dTheta, int dPhi) {
    theta = constrain(theta + dTheta, 10, 170);
    phi += dPhi;
    update();
  }

  void reset(PGraphics viewport) {
    viewport.camera(); 
  }

  void reset(float _r, float _theta, float _phi) {
    r = _r;
    phi = _phi;
    theta = _theta;
    update();
  }
}
