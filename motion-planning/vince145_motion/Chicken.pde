class Chicken {
  Vector2D pos;
  Vector2D vel;
  ArrayList<Milestone> path = new ArrayList<Milestone>();
  int pathIndex;
  float rotation;
  int animationFrame;
  boolean chickenInPen;
  int penNumber;
  
  Chicken(float startX, float startZ) {
    this.pos = new Vector2D(startX, startZ);
    this.vel = new Vector2D(0.0, 0.0);
    this.pathIndex = 0;
    this.rotation = 0;
    this.animationFrame = 0;
    this.chickenInPen = false;
    this.penNumber = -1;
  }
  
  Vector2D getPos() {
    return this.pos;
  }
  
  Vector2D getVel() {
    return this.vel;
  }
  
  boolean inPen() {
    return chickenInPen;
  }
  
  void setPath(ArrayList<Milestone> newPath) {
    this.path = newPath;
  }
  
  void update() {
    
    pos.addV(vel.scalerNC(dt));
    
    // Handles edge of game collision
    if (pos.x < -1.0*gameSize/2) {
      vel.x *= -1;
      pos.x += 2;
    } else if (pos.x > gameSize/2) {
      vel.x *= -1;
      pos.x -= 2;
    }
    if (pos.z < -1.0*gameSize/2) {
      vel.z *= -1;
      pos.z += 2;
    } else if (pos.z > gameSize/2) {
      vel.z *= -1;
      pos.z -= 2;
    }
    
    // Handles collision with obstacles
    for (int i = 0; i < game.getObstacles().size(); i++) {
      Vector2D xBound = game.getObstacles().get(i).getXBound();
      Vector2D zBound = game.getObstacles().get(i).getZBound();
      if (pos.x > xBound.x - 5 && pos.x < xBound.z + 5 &&
          pos.z > zBound.x - 5 && pos.z < zBound.z + 5) {
        vel.x *= -1.3;
        vel.z *= -1.3;
        pos.addV(vel.scalerNC(dt*2.0));
      } 
    }
    
    // Handles collision with chicken Pens
    if (!chickenInPen) {
      for (int i = 0; i < game.getChickenPens().size(); i++) {
        Vector2D xBound = game.getChickenPens().get(i).getXBound();
        Vector2D zBound = game.getChickenPens().get(i).getZBound();
        if (pos.x > xBound.x + 5 && pos.x < xBound.z - 5 &&
            pos.z > zBound.x + 5 && pos.z < zBound.z - 5) {
          chickenInPen = true;
          penNumber = i;
        } 
      }
    }
    if (chickenInPen) {
      Vector2D xBound = game.getChickenPens().get(penNumber).getXBound();
      Vector2D zBound = game.getChickenPens().get(penNumber).getZBound();
      if (!(pos.x > xBound.x + 5 && pos.x < xBound.z - 5 &&
          pos.z > zBound.x + 5 && pos.z < zBound.z - 5)) {
        vel.x *= -1.3;
        vel.z *= -1.3;
        pos.addV(vel.scalerNC(dt*0.999));
      }
    }
    
    float velMin = 0.1;
    if (vel.x > 0 && vel.z < velMin && vel.z > -1.0*velMin) {
      rotation = -PI/2;
    } else if (vel.x < 0 && vel.z < velMin && vel.z > -1.0*velMin) {
      rotation = PI/2;
    } else if (vel.x < velMin && vel.x > -1.0*velMin && vel.z > 0) {
      rotation = PI;
    } else if (vel.x < velMin && vel.x > -1.0*velMin && vel.z < 0) {
      rotation = 0;
    } else if (vel.x > 0 && vel.z > 0) {
      rotation = atan(vel.z/(vel.x + 0.0000001)) + PI;
    } else if (vel.x > 0 && vel.z < 0) {
      rotation = atan(vel.z/(vel.x + 0.0000001));
    } else if (vel.x < 0 && vel.z > 0) {
      rotation = atan(vel.z/(vel.x + 0.0000001)) + PI;
    } else if (vel.x < 0 && vel.z < 0) {
      rotation = atan(vel.z/(vel.x + 0.0000001)) + 2*PI;
    }
    
  }
  
  void drawChicken() {
    pushMatrix();
    noStroke();
    translate(this.pos.x,0,this.pos.z);
    rotateY(rotation);
    fill(225); // white
    translate(0, -12.5, 0);
    box(7.5,10,13.5); // body
    translate(7.5/2, 7.5, 0);
    fill(225, 225, 0); // yellow
    box(1.75,10,2.5); // right leg
    translate(-7.5, 0, 0);
    box(1.75,10,2.5); // left leg
    translate(0,4,-2);
    box(0.5,1.0,2); // left foot middle toe
    translate(1.2,0,0);
    rotateY(-0.5);
    box(0.5,1.0,2); // left foot right toe
    rotateY(0.5);
    translate(-2.4,0,0);
    rotateY(0.5);
    box(0.5,1.0,2); // left foot left toe
    rotateY(-0.5);
    translate(1.2 + 7.5, 0, 0);
    box(0.5,1.0,2); // right foot middle toe
    translate(1.2,0,0);
    rotateY(-0.5);
    box(0.5,1.0,2); // right foot right toe
    rotateY(0.5);
    translate(-2.4,0,0);
    rotateY(0.5);
    box(0.5,1.0,2); // right foot left toe
    rotateY(-0.5);
    translate(1.2 - 7.5/2, -12.5 - 6.0, -5);
    fill(225); // white
    box(3.0,4,8); // head
    translate(0, 1.75, -4.0);
    fill(255,0,0); // red
    box(1.5,3.0,0.8); // gizzard
    translate(0.5, -2.35, 0);
    fill(0);
    box(0.5, 1.0, 0.5); // right eye
    translate(-1.0, 0, 0);
    box(0.5, 1.0, 0.5); // left eye
    translate(0.5, -1, 1);
    fill(255,0,0); // red
    box(0.60, 1.2, 1.6);
    popMatrix();
  }
}
