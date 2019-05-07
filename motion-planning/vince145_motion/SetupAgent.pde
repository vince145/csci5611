class SetupAgent {
  Vector2D pos;
  int state;
  float w;
  float b;
  float h;
  
  SetupAgent(float startX, float startZ) {
    this.pos = new Vector2D(startX, startZ);
    this.state = 0;
    this.w = 75;
    this.h = 75;
    this.b = 75;
  }
  
  Vector2D getPos() {
    return this.pos;
  }
  float getW() {
    return w;
  }
  float getB() {
    return b;
  }
  float getH() {
    return h;
  }
  int getState() {
    return this.state;
  }
  
  void stateInc() {
    if (this.state < 4) {
      this.state++;
    }
  }
  
  void stateDec() {
    if (this.state > 0) {
      this.state--;
    }
  }
  
  void move(char direction) {
    Vector2D oldPos = new Vector2D(this.pos.x, this.pos.z);

    switch (direction) {
      case 'w': this.pos.z-=3;
                break;
      case 's': this.pos.z+=3;
                break;
      case 'd': this.pos.x+=3;
                break;
      case 'a': this.pos.x-=3;
                break;
                
      case 'i': if (this.b<gameSize) {this.b+=2;}
                break;
      case 'k': if (this.b>6) {this.b-=2;}
                break;
      case 'l': if (this.w<gameSize) {this.w+=2;}
                break;
      case 'j': if (this.w>6) {this.w-=2;}
                break;
      case 'o': if (this.h<201) {this.h+=2;}
                break;
      case 'u': if (this.h>36) {this.h-=2;}
                break;
                
      case 'b': this.w = 75;
                break;
      case 'n': this.h = 75;
                break;
      case 'm': this.b = 75;
                break;
                
      default:
              break;
    }
    
    // Handles collision with obstacles
    if (!placedObject) {
      for (int i = 0; i < game.getObstacles().size(); i++) {
        Vector2D xBound = game.getObstacles().get(i).getXBound();
        Vector2D zBound = game.getObstacles().get(i).getZBound();
        
        if (state != 3) { // If the moving object is not an obstacle
          if (this.pos.x > xBound.x - 15 && this.pos.x < xBound.z + 25 &&
              this.pos.z > zBound.x - 25 && this.pos.z < zBound.z + 15) {
            this.pos.x = oldPos.x;
            this.pos.z = oldPos.z;
          }
        } else if (state == 3) {
          if (this.pos.x > xBound.x - w*0.5 && this.pos.x < xBound.z + w*0.5 &&
              this.pos.z > zBound.x - b*0.5 && this.pos.z < zBound.z + b*0.5) {
            this.pos.x = oldPos.x;
            this.pos.z = oldPos.z;
          }
        }
      }
    } else {
      // used to allow setupAgent to move away from obstacles after
      // they are placed
      boolean resetBoolean = true;
      for (int i = 0; i < game.getObstacles().size(); i++) {
        Vector2D xBound = game.getObstacles().get(i).getXBound();
        Vector2D zBound = game.getObstacles().get(i).getZBound();
        
        if (state != 3) { // If the moving object is not an obstacle
          if (this.pos.x > xBound.x - 15 && this.pos.x < xBound.z + 25 &&
              this.pos.z > zBound.x - 25 && this.pos.z < zBound.z + 15) {
            resetBoolean = false;
          }
        } else if (state == 3) {
          if (this.pos.x > xBound.x - w*0.5 && this.pos.x < xBound.z + w*0.5 &&
              this.pos.z > zBound.x - b*0.5 && this.pos.z < zBound.z + b*0.5) {
            resetBoolean = false;
          }
        }
      }
      
      if (resetBoolean) {
        placedObject = false;
      }
    }
  }
  
  void drawSetupAgent() {
    switch(state) {
      case 0:  // Draw Sphere
              pushMatrix();
              translate(this.pos.x, -15, this.pos.z);
              fill(255);
              sphere(10);
              popMatrix();
              break;
      case 1: // Draw Chicken
              pushMatrix();
              noStroke();
              translate(this.pos.x,0,this.pos.z);
              //rotateY(rotation);
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
              break;
      case 2: // Draw Wolf
              pushMatrix();
              noStroke();
              translate(this.pos.x,0,this.pos.z);
              //rotateY(rotation);
              fill(255,0,0); // white
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
              break;
      case 3: // Draw Obstacle
              pushMatrix();
              fill(100,0,0);
              stroke(255,0,0);
              translate(pos.x, (-h * 0.5) - 0.15, pos.z);
              box(w, h, b);
              popMatrix();
              break;
      case 4: // Draw Chicken Pen
              fill(139,69,19);
              stroke(0,0,0);
              // right wall
              pushMatrix();
              translate(pos.x + w * 0.5 - 2.5, (-40.0 * 0.5) - 0.15, pos.z);
              box(5, 40, b);
              popMatrix();
              // left wall
              pushMatrix();
              translate(pos.x - w * 0.5 + 2.5, (-40.0 * 0.5) - 0.15, pos.z);
              box(5, 40, b);
              popMatrix();
              // front wall
              pushMatrix();
              translate(pos.x, (-40.0 * 0.5) - 0.15, pos.z + b * 0.5 - 2.5);
              box(w, 40, 5);
              popMatrix();
              // back wall
              pushMatrix();
              translate(pos.x, (-40.0 * 0.5) - 0.15, pos.z - b * 0.5 + 2.5);
              box(w, 40, 5);
              popMatrix();
              break;
    }
  }

}
