class ChickenPen {
  Vector2D pos;
  float w;
  float b;
  float h;
  
  ChickenPen(float startX, float startZ, float startW, float startH, float startB) {
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
  /*
      obstacles.add(new Obstacle(this.center.x + 150, this.center.z, 5, 200, 200)); // right wall
      obstacles.add(new Obstacle(this.center.x - 150, this.center.z, 5, 200, 200)); // left wall
      obstacles.add(new Obstacle(this.center.x, this.center.z - 100, 300, 200, 5)); // back wall
      obstacles.add(new Obstacle(this.center.x + (150-75*0.5), this.center.z + 100, 75, 200, 5)); // right doorway wall
      obstacles.add(new Obstacle(this.center.x - (150-75*0.5), this.center.z + 100, 75, 200, 5)); // left doorway wall
  */
  void drawChickenPen() {
    fill(139,69,19);
    stroke(0,0,0);
    // right wall
    pushMatrix();
    translate(pos.x + w * 0.5 - 2.5, (-h * 0.5) - 0.15, pos.z);
    box(5, h, b);
    popMatrix();
    // left wall
    pushMatrix();
    translate(pos.x - w * 0.5 + 2.5, (-h * 0.5) - 0.15, pos.z);
    box(5, h, b);
    popMatrix();
    // front wall
    pushMatrix();
    translate(pos.x, (-h * 0.5) - 0.15, pos.z + b * 0.5 - 2.5);
    box(w, h, 5);
    popMatrix();
    // back wall
    pushMatrix();
    translate(pos.x, (-h * 0.5) - 0.15, pos.z - b * 0.5 + 2.5);
    box(w, h, 5);
    popMatrix();
  }
}
