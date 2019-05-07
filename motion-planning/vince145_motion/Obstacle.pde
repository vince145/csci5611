class Obstacle {
  Vector2D pos;
  float w;
  float b;
  float h;
  
  Obstacle(float startX, float startZ, float startW, float startH, float startB) {
    this.pos = new Vector2D(startX, startZ);
    this.w = startW;
    this.b = startB;
    this.h = startH;
  }
  
  Vector2D getPos() {
    return this.pos;
  }
  
  float getW() {
    return this.w;
  }
  
  float getH() {
    return this.h;
  }
  
  Vector2D getXBound() {
    Vector2D resultXBound = new Vector2D(this.pos.x - this.w * 0.5,
                                         this.pos.x + this.w * 0.5);
    return resultXBound;
  }
  
  Vector2D getZBound() {
    Vector2D resultZBound = new Vector2D(this.pos.z - this.b * 0.5,
                                         this.pos.z + this.b * 0.5);
    return resultZBound;
  }
  
  void drawObstacle() {
    pushMatrix();
    fill(100,0,0);
    stroke(255,0,0);
    translate(pos.x, (-h * 0.5) - 0.15, pos.z);
    box(w, h, b);
    popMatrix();
  }
}
