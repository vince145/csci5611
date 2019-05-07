class Player {
  Vector2D pos;
  Vector2D vel;
  int state;
  int animationFrame;
  float rotation;
  
  
  Player(float startX, float startZ) {
    this.pos = new Vector2D(startX, startZ);
    this.vel = new Vector2D(0.0, 0.0);
    this.state = 0;
    this.animationFrame = 0;
    this.rotation = 0;
  }
  
  Vector2D getPos() {
    return this.pos;
  }
  
  Vector2D getVel() {
    return this.vel;
  }
  
  int getState() {
    return this.state;
  }
  
  void setState(int newState) {
    this.state = newState;
  }
  
  void move(char direction) {
    Vector2D oldPos = new Vector2D(pos.x, pos.z);
    switch (direction) {
      case 'w': pos.z-=3;
                rotation = PI;
              break;
      case 's': pos.z+=3;
                rotation = 0;
              break;
      case 'd': pos.x+=3;
                rotation = PI/2;
              break;
      case 'a': pos.x-=3;
                rotation = -PI/2;
              break;
      default:
              break;
    }
    
    // Handles collision with obstacles
    for (int i = 0; i < game.getObstacles().size(); i++) {
      Vector2D xBound = game.getObstacles().get(i).getXBound();
      Vector2D zBound = game.getObstacles().get(i).getZBound();
      
      if (pos.x > xBound.x - 15 && pos.x < xBound.z + 25 &&
          pos.z > zBound.x - 25 && pos.z < zBound.z + 15) {
        pos.x = oldPos.x;
        pos.z = oldPos.z;
      } 
    }
    
  }
  

  
  void drawPlayer() {
    pushMatrix();
    noStroke();
    translate(this.pos.x-7.5,-2.5,this.pos.z+10);
    rotateY(rotation);
    fill(255); // white
    box(10,-5,20); // left foot
    translate(15,0,0);
    box(10,-5,20); // right foot
    translate(0,-20,-9);
    box(10,-40,5); // right leg
    translate(-15,0,0);
    box(10,-40,5); // left leg
    
    translate(7.5,-50,0);
    box(13,-60,8); // torso
    translate(0,-40,0);
    box(20,20,20); // head
    translate(5,-5,10);
    fill(0); // black
    switch (state) {
      case 0: 
              break;
      case 1: fill(255,0,0); // red
              break;
      case 2: fill(0,0,255); // blue
              break;
      case 3: fill(0,0,255); // blue
              break;
      case 4: fill(0,0,126); // dark blue
              break;
      default:
              break;
      }
    box(3,6,3); // right eye
    translate(-10,0,0);
    box(3,6,3); // left eye
    fill(255);
    translate(5,5,-10);
    translate(0,40,0);
    translate(-28,-60,0);
    rotateZ(radians(-30));
    box(8,-75,5); // left arm
    rotateZ(radians(30));
    translate(56,0,0);
    rotateZ(radians(30));
    box(8,-75,5); // right arm
    popMatrix();
  }
}
