// vince145_PRM_motion by Matthew Vincent, vince145
// for CSCI 5611 at the University of Minnesota Twin Cities
//
//
// PeasyCam 3D user interactive camera library is used.
// The PeasyCam library was made by Jonathan Feinberg
// http://mrfeinberg.com/peasycam/
//
// Ray - Sphere intersection code modified from
// http://kylehalladay.com/blog/tutorial/math/2013/12/24/Ray-Sphere-Intersection.html
//
// Dijikstra's Algorithm code modified from
// https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
// pseudocode
//
//
// http://www.kfish.org/boids/pseudocode.html
//////////////////////////////////////////////////////////////////
// TODO: 
//
//   - 
//
//////////////////////////////////////////////////////////////////

import java.util.Collections;
import peasy.*;
PeasyCam cam;
float fov = PI/3.0;


boolean chickenBoid = true;
boolean wolfAttack = true;
boolean gameRunning = false;
boolean gameSetup = true;
boolean cleanGame = false;
boolean gameOver = false;

boolean placedObject = false;
float gameSize = 1500;
float edgeMaxDistance = gameSize/2; // boardSize/10
int numberOfSampledPoints = 35;
int inputDelay = 5;

float w = 800;
float h = 600;
float dt = 0.001;

Game game = new Game(0.0, 0.0, 0.0, gameSize);

void setup() {
  size(1600, 900, P3D);
  fill(255);
  cam = new PeasyCam(this, 500);
  cam.setMinimumDistance(250);
  cam.setMaximumDistance(1500);
  textSize(32);
}

void draw() {
  lights();
  background(186, 223, 255);
  
  /*
  camera(width/4.0, -height/4.0, 0.0,
         0.0, 0.0, 0.0,
         0.0, 1.0, 0.0);
         */
         
  game.drawGame();
  if (keyPressed == true) {
    handleInput(key);
    if (gameRunning) {
      game.getUser().move(key);
    }
    if (gameSetup) {
      game.getSetupAgent().move(key);
    }
  }
  if (inputDelay > 1000) {
    inputDelay = 100;
  }
  inputDelay++;
  
}

void handleInput(char input) {
  switch (input) {
    case 'x': if (inputDelay >= 20) {
                gameRunning = false;
                gameSetup = true;
                cleanGame = false;
                gameOver = false;
                game = new Game(0.0, 0.0, 0.0, gameSize);
                inputDelay = 0;
              }
              break;
    case 'c': if (inputDelay >= 20) {
                gameRunning = false;
                gameSetup = true;
                cleanGame = true;
                gameOver = false;
                game = new Game(0.0, 0.0, 0.0, gameSize);
                inputDelay = 0;
              }
              break;
    case 'z': if (inputDelay >= 20 && !gameOver) {
                gameRunning = !gameRunning;
                if (gameSetup) {
                  gameSetup = false;
                }
                inputDelay = 0;
              }
              break;
    case '1': if (inputDelay >= 20 && !gameOver) {
                if (gameRunning) {
                  if (game.getUser().getState() != 1) {
                    game.getUser().setState(1);
                  } else {
                    game.getUser().setState(0);
                  }
                  inputDelay = 0;
                }
              }
              break;
    case 'q': if (inputDelay >= 20) {
                if (gameSetup) {
                  game.getSetupAgent().stateDec();
                  inputDelay = 0;
                }
              }
              break;
    case 'e': if (inputDelay >= 20) {
                if (gameSetup) {
                  game.getSetupAgent().stateInc();
                  inputDelay = 0;
                }
              }
              break;
    case ' ': if (inputDelay >= 20) {
                if (gameSetup) {
                  game.setupAddObject();
                  inputDelay = 0;
                }
              }
              break;
    default:
              break;
  }
}


public class Vector2D {
  float x;
  float z;
  
  Vector2D(float newX, float newZ) {
    x = newX;
    z = newZ;
  }
  
  void scaler(float scalerValue) {
    x = x * scalerValue;
    z = z * scalerValue;
  }
  
  Vector2D scalerNC(float scalerValue) {
    Vector2D resultVector = new Vector2D(x*scalerValue, z*scalerValue);
    return resultVector;
  }
  
  void addV(Vector2D addVector) {
    x = x + addVector.x;
    z = z + addVector.z;
  }
  
  void divide(float divideValue) {
    if (divideValue != 0) {
      x = (float) x / (float) divideValue;
      z = (float) z / (float) divideValue;
    }
  }
  
  Vector2D divideNC(float scalerValue) {
    if (scalerValue != 0) {
      float newX = ((float) x)/ (float) scalerValue;
      float newZ = ((float) z)/ (float) scalerValue;
      Vector2D resultVector = new Vector2D(newX, newZ);
      return resultVector;
    } else {
      Vector2D resultVector = new Vector2D(x, z);
      return resultVector;
    }
  }
  
  float magnitude() {
    return sqrt((float) (((x*x)+(z*z))));
  }
  
  void normalizeV() {
    float mag = sqrt((float) (x*x)+(z*z));
    if (mag != 0) {
      x = x/(mag);
      z = z/(mag);
    }
  }
  
  // Calculates distance from point startV to .this point.
  Vector2D d(Vector2D startV) {
    Vector2D distanceVector = new Vector2D(x-startV.x, z-startV.z);
    return distanceVector;
  }
  
  float dotProd(Vector2D startV) {
    float dotProduct = (x * startV.x) + (z * startV.z);
    return dotProduct;
  }
  
  void reset() {
    x = 0;
    z = 0;
  }
}

public class Vector3D {
  float x;
  float y;
  float z;
  
  Vector3D(float newX, float newY, float newZ) {
    x = newX;
    y = newY;
    z = newZ;
  }
  
  void scaler(float scalerValue) {
    x = x * scalerValue;
    y = y * scalerValue;
  }
  
  Vector3D scalerNC(float scalerValue) {
    Vector3D resultVector = new Vector3D(x*scalerValue, y*scalerValue, z*scalerValue);
    return resultVector;
  }
  
  void addV(Vector3D addVector) {
    x = x + addVector.x;
    y = y + addVector.y;
  }
  
  void divide(float divideValue) {
    if (divideValue != 0) {
      x = (float) x / (float) divideValue;
      y = (float) y / (float) divideValue;
      z = (float) z / (float) divideValue;
    }
  }
  
  Vector3D divideNC(float scalerValue) {
    if (scalerValue != 0) {
      float newX = ((float) x)/ (float) scalerValue;
      float newY = ((float) y)/ (float) scalerValue;
      float newZ = ((float) z)/ (float) scalerValue;
      Vector3D resultVector = new Vector3D(newX, newY, newZ);
      return resultVector;
    } else {
      Vector3D resultVector = new Vector3D(x, y, z);
      return resultVector;
    }
  }
  
  float magnitude() {
    return sqrt((float) (((x*x)+(y*y)+(z*z))));
  }
  
  void normalizeV() {
    float mag = sqrt((float) (x*x)+(y*y)+(z*z));
    if (mag != 0) {
      x = x/(mag);
      y = y/(mag);
    }
  }
  
  // Calculates distance from point startV to .this point.
  Vector3D d(Vector3D startV) {
    Vector3D distanceVector = new Vector3D(x-startV.x, y-startV.y, z-startV.z);
    return distanceVector;
  }
  
  float dotProd(Vector3D startV) {
    float dotProduct = (x * startV.x) + (y * startV.y) + (z * startV.z);
    return dotProduct;
  }
  
  void reset() {
    x = 0;
    y = 0;
  }
}

// Andre LaMothe's code from Tricks of the Windows Game Programming Gurus:
boolean linesIntersect(Vector2D p0, Vector2D p1, Vector2D p2, Vector2D p3) {
  Vector2D s1 = p1.d(p0);
  Vector2D s2 = p3.d(p2);
  
  float s = (-s1.z * (p0.x - p2.x) + s1.x * (p0.z - p2.z)) / (-s2.x * s1.z + s1.x * s2.z);
  float t = ( s2.x * (p0.z - p2.z) - s2.z * (p0.x - p2.x)) / (-s2.x * s1.z + s1.x * s2.z);
  
  if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
    return true;
  }
  return false;
}



//////////////////////////////////////////////////////////////////
//
// 
//
// Dijkstra Algorithm
//

public class dijkstraResult {
  float dist[];
  Milestone prev[];
  
  dijkstraResult(float startDist[], Milestone startPrev[]) {
    dist = startDist;
    prev = startPrev;
  }
}

dijkstraResult dijkstra(ArrayList<Milestone> nodes, ArrayList<Edge> paths, Milestone source) {
  float dist[] = new float[nodes.size()];
  Milestone prev[] = new Milestone[nodes.size()];
  ArrayList<Milestone> Q = new ArrayList<Milestone>();
  for (int i = 0; i < nodes.size(); i++) {
    if (!nodes.get(i).compare(source)) {
      dist[i] = 999999;
    } else if (nodes.get(i).compare(source)) {
      dist[i] = 0;
    }
    prev[i] = null;
    if (nodes.get(i).getType() != 2) {
      Q.add(nodes.get(i));
    }
  }
  while (Q.size() > 0) {
    float minDist = 999999;
    int minNodei = 0;
    int minNodej = 0;
    Milestone v = source;
    for (int i = 0; i < Q.size(); i++) {
      int nodeJ = i;
      for (int j = 0; j < nodes.size(); j++) {
        if (Q.get(i).compare(nodes.get(j))) {
          nodeJ = j;
        }
      }
      if (dist[nodeJ] < minDist) {
        minDist = dist[nodeJ];
        v = nodes.get(nodeJ);
        for (int j = 0; j < nodes.size(); j++) {
          if (v.compare(nodes.get(j))) {
            minNodei = i;
            minNodej = j;
          }
        }
      }
    }
    Q.remove(minNodei);
    
    int uNode = 0;
    for (int i = 0; i < paths.size(); i++) {
      if (paths.get(i).getA().compare(v)) {
        float alt = dist[minNodej] + paths.get(i).getCost();
        for (int j = 0; j < nodes.size(); j++) {
          if (nodes.get(j).compare(paths.get(i).getB())) {
            uNode = j;
          }
        }
        if (alt < dist[uNode]) {
          dist[uNode] = alt;
          prev[uNode] = nodes.get(minNodej);
          nodes.get(uNode).setPrev(nodes.get(minNodej));
        }
      }
    }
  }
  
  dijkstraResult result = new dijkstraResult(dist, prev);
  return result;
}

//
//
//
//
//
//////////////////////////////////////////////////////////////////

class Edge {
  Milestone A;
  Milestone B;
  float cost;
  
  Edge(Milestone startA, Milestone startB, float startCost) {
    this.A = startA;
    this.B = startB;
    this.cost = startCost;
  }
  
  Milestone getA() {
    return this.A;
  }
  
  Milestone getB() {
    return this.B;
  }
  
  float getCost() {
    return this.cost;
  }
}

class Milestone {
  int type;
  Vector2D pos;
  Milestone prev;
  
  Milestone(float startX, float startZ, int startType) {
    this.type = startType;
    this.pos = new Vector2D(startX, startZ);
  }
  
  void setType(int newType) {
    this.type = newType;
  }
  
  int getType() {
    return this.type;
  }
  
  Vector2D getPos() {
    return this.pos;
  }
  
  void setPrev(Milestone newPrev) {
    this.prev = newPrev;
  }
  
  Milestone getPrev() {
    return this.prev;
  }
  
  boolean compare(Milestone A) {
    if (A == null) {
      return false;
    }
    Vector2D aPos = A.getPos();
    if (this.pos.x == aPos.x && this.pos.z == aPos.z) {
      return true;
    } else {
      return false;
    }
  }
}

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

class Wolf {
  Vector2D pos;
  Vector2D vel;
  ArrayList<Milestone> path = new ArrayList<Milestone>();
  int pathIndex;
  float rotation;
  int animationFrame;
  float speed;
  
  Wolf(float startX, float startZ) {
    this.pos = new Vector2D(startX, startZ);
    this.vel = new Vector2D(0.0, 0.0);
    this.pathIndex = 0;
    this.rotation = 0;
    this.animationFrame = 0;
    this.speed = 2400;
  }
  
  Vector2D getPos() {
    return this.pos;
  }
  
  Vector2D getVel() {
    return this.vel;
  }
  
  void setPath(ArrayList<Milestone> newPath) {
    this.path = newPath;
    this.pathIndex = 0;
  }
  
  void update() {
    
    if (wolfAttack) {
      if (pathIndex != path.size()) {
        Vector2D dist = path.get(pathIndex).getPos().d(this.pos);
        
        if (dist.magnitude() < 1) {
          pathIndex++;
          vel.reset();
        }
        
        dist.divide(dist.magnitude());
        dist.scaler(this.speed);
        vel = dist;
      } else {
        vel.reset();
      }
    }
    
    pos.addV(vel.scalerNC(dt));
    
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
  
  void drawWolf() {
    pushMatrix();
    noStroke();
    translate(this.pos.x,0,this.pos.z);
    rotateY(rotation);
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
  }
}


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

class Game {
  Player user;
  SetupAgent setupAgent;
  ArrayList<Wolf> wolves = new ArrayList<Wolf>();
  ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
  ArrayList<ChickenPen> chickenPens = new ArrayList<ChickenPen>();
  ArrayList<Chicken> chickens = new ArrayList<Chicken>();
  ArrayList<Milestone> PRM_Map = new ArrayList<Milestone>();
  boolean generateNewMap;
  int mapTimer;
  float size;
  Vector3D center;
  int searchTimer;
  int chickensEatten;
  int chickensSafe;
  
  Game(float startX, float startY, float startZ, float startSize) {
    this.center = new Vector3D(startX, startY, startZ);
    this.size = startSize;
    this.searchTimer = 0;
    this.mapTimer = 0;
    this.generateNewMap = true;
    this.chickensEatten = 0;
    this.chickensSafe = 0;
    
    // Set Obstacles
    //obstacles.add(new Obstacle(this.center.x, this.center.z, 5, 10, 5));
    // Creating edge of game
    obstacles.add(new Obstacle(this.center.x + this.size*0.5, this.center.z, 5, 35, this.size)); // right wall
    obstacles.add(new Obstacle(this.center.x - this.size*0.5, this.center.z, 5, 35, this.size)); // left wall
    obstacles.add(new Obstacle(this.center.x, this.center.z + this.size*0.5, this.size, 35, 5)); // front wall
    obstacles.add(new Obstacle(this.center.x, this.center.z - this.size*0.5, this.size, 35, 5)); // back wall
    // Creating center box
    if (!cleanGame) {
      obstacles.add(new Obstacle(this.center.x + 150, this.center.z, 5, 200, 200)); // right wall
      obstacles.add(new Obstacle(this.center.x - 150, this.center.z, 5, 200, 200)); // left wall
      obstacles.add(new Obstacle(this.center.x, this.center.z - 100, 300, 200, 5)); // back wall
      obstacles.add(new Obstacle(this.center.x + (150-75*0.5), this.center.z + 100, 75, 200, 5)); // right doorway wall
      obstacles.add(new Obstacle(this.center.x - (150-75*0.5), this.center.z + 100, 75, 200, 5)); // left doorway wall
      
      // Set ChickenPen
      chickenPens.add(new ChickenPen(this.center.x, this.center.z, 300, 40, 200));
    }
    
    
    // Setup SetupAgent
    setupAgent = new SetupAgent(this.center.x, this.center.z + 30);
    
    // Setup user controlled agent
    user = new Player(this.center.x, this.center.z);
    
    // Setup chickens
    if (!cleanGame) {
      for (int i = 0; i < 100; i++) {
        float randomX = random(this.center.x-this.size*0.45, this.center.x+this.size*0.45);
        float randomZ = random(this.center.y-this.size*0.45, this.center.y+this.size*0.45);
        boolean viableAgentPlacement = false;
        while (!viableAgentPlacement) {
          viableAgentPlacement = true;
          for (int k = 0; k < obstacles.size(); k++) {
            Vector2D xBound = obstacles.get(k).getXBound();
            Vector2D zBound = obstacles.get(k).getZBound();
            if (randomX > xBound.x - 7 && randomX < xBound.z + 7 &&
                randomZ > zBound.x - 7 && randomZ < zBound.z + 7) {
              randomX = random(this.center.x-this.size*0.45, this.center.x+this.size*0.45);
              randomZ = random(this.center.y-this.size*0.45, this.center.y+this.size*0.45);
              viableAgentPlacement = false;
            }
          }
        }
        chickens.add(new Chicken(randomX, randomZ));
      }
    }
    
    // Setup wolf
    if (!cleanGame) {
      for (int i = 0; i < 1; i++) {
        float randomX = random(this.center.x-this.size*0.45, this.center.x+this.size*0.45);
        float randomZ = random(this.center.y-this.size*0.45, this.center.y+this.size*0.45);
        boolean viableAgentPlacement = false;
        while (!viableAgentPlacement) {
          viableAgentPlacement = true;
          for (int k = 0; k < obstacles.size(); k++) {
            Vector2D xBound = obstacles.get(k).getXBound();
            Vector2D zBound = obstacles.get(k).getZBound();
            if (randomX > xBound.x - 10 && randomX < xBound.z + 10 &&
                randomZ > zBound.x - 10 && randomZ < zBound.z + 10) {
              randomX = random(this.center.x-this.size*0.45, this.center.x+this.size*0.45);
              randomZ = random(this.center.y-this.size*0.45, this.center.y+this.size*0.45);
              viableAgentPlacement = false;
            }
          }
        }
        wolves.add(new Wolf(randomX, randomZ));
      }
    }
    
    if (gameRunning) {
      // Wolves will attempt to eat chickens if turned on
      if (wolfAttack) {
        for (int i = 0; i < wolves.size(); i++) {
          wolves.get(i).setPath(WolfPRM(wolves.get(i)));
        }
      }
    }
  }
  
  Player getUser() {
    return this.user;
  }
  
  SetupAgent getSetupAgent() {
    return this.setupAgent;
  }
  
  ArrayList<Obstacle> getObstacles() {
    return this.obstacles;
  }
  
  ArrayList<ChickenPen> getChickenPens() {
    return this.chickenPens;
  }
  
  void setupAddObject() {
    int setupAgentState = setupAgent.getState();
    float agentX = setupAgent.getPos().x;
    float agentZ = setupAgent.getPos().z;
    boolean viableAgentPlacement = true;
    if (!placedObject) {
      switch(setupAgentState) {
        case 0: break;
        case 1: 
                // Checks to make sure chickens are not placed in obstacles
                for (int k = 0; k < obstacles.size(); k++) {
                  Vector2D xBound = obstacles.get(k).getXBound();
                  Vector2D zBound = obstacles.get(k).getZBound();
                  if (agentX > xBound.x - 7 && agentX < xBound.z + 7 &&
                      agentZ > zBound.x - 7 && agentZ < zBound.z + 7) {
                    viableAgentPlacement = false;
                  }
                }
                if (viableAgentPlacement) {
                  chickens.add(new Chicken(agentX, agentZ));
                }
                break;
        case 2: 
                // Checks to make sure wolves are not placed in obstacles
                for (int k = 0; k < obstacles.size(); k++) {
                  Vector2D xBound = obstacles.get(k).getXBound();
                  Vector2D zBound = obstacles.get(k).getZBound();
                  if (agentX > xBound.x - 7 && agentX < xBound.z + 7 &&
                      agentZ > zBound.x - 7 && agentZ < zBound.z + 7) {
                    viableAgentPlacement = false;
                  }
                }
                // Checks to make sure wolves are not placed in chicken pens
                for (int k = 0; k < chickenPens.size(); k++) {
                  Vector2D xBound = chickenPens.get(k).getXBound();
                  Vector2D zBound = chickenPens.get(k).getZBound();
                  if (agentX > xBound.x - 7 && agentX < xBound.z + 7 &&
                      agentZ > zBound.x - 7 && agentZ < zBound.z + 7) {
                    viableAgentPlacement = false;
                  }
                }
                if (viableAgentPlacement) {
                  wolves.add(new Wolf(agentX, agentZ));
                }
                break;
        case 3: 
                obstacles.add(new Obstacle(agentX, agentZ, 
                                           setupAgent.getW(), 
                                           setupAgent.getH(), 
                                           setupAgent.getB()));
                Vector2D xBound = obstacles.get(obstacles.size()-1).getXBound();
                Vector2D zBound = obstacles.get(obstacles.size()-1).getZBound();
                
                // Handles attempt to place obstacle over player
                if (user.getPos().x > xBound.x - 15 && user.getPos().x < xBound.z + 25 &&
                    user.getPos().z > zBound.x - 25 && user.getPos().z < zBound.z + 15) {
                  obstacles.remove(obstacles.size()-1);
                } else {
                  placedObject = true;
                  // Handles the obstacle being placed over chickens
                  for (int i = 0; i < chickens.size(); i++) {
                    float chickenX = chickens.get(i).getPos().x;
                    float chickenZ = chickens.get(i).getPos().z;
                    if (chickenX > xBound.x - 7 && chickenX < xBound.z + 7 &&
                        chickenZ > zBound.x - 7 && chickenZ < zBound.z + 7) {
                      chickens.remove(i);
                      i--;
                    }
                  }
                  // Handles the obstacle being placed over wolves
                  for (int i = 0; i < wolves.size(); i++) {
                    float wolfX = wolves.get(i).getPos().x;
                    float wolfZ = wolves.get(i).getPos().z;
                    if (wolfX > xBound.x - 7 && wolfX < xBound.z + 7 &&
                        wolfZ > zBound.x - 7 && wolfZ < zBound.z + 7) {
                      wolves.remove(i);
                      i--;
                    }
                  }
                }
                break;
        case 4: 
                chickenPens.add(new ChickenPen(agentX, agentZ, 
                                           setupAgent.getW(), 
                                           40, 
                                           setupAgent.getB()));
                Vector2D xBound2 = chickenPens.get(chickenPens.size()-1).getXBound();
                Vector2D zBound2 = chickenPens.get(chickenPens.size()-1).getZBound();
                
                // Handles attempt to place obstacle over player
                if (user.getPos().x > xBound2.x - 15 && user.getPos().x < xBound2.z + 25 &&
                    user.getPos().z > zBound2.x - 25 && user.getPos().z < zBound2.z + 15) {
                  //chickenPens.remove(chickenPens.size()-1);
                } else {
                  placedObject = true;
                  // Handles the obstacle being placed over chickens
                  /*
                  for (int i = 0; i < chickens.size(); i++) {
                    float chickenX = chickens.get(i).getPos().x;
                    float chickenZ = chickens.get(i).getPos().z;
                    if (chickenX > xBound.x - 7 && chickenX < xBound.z + 7 &&
                        chickenZ > zBound.x - 7 && chickenZ < zBound.z + 7) {
                      chickens.remove(i);
                      i--;
                    }
                  }
                  */
                  // Handles the obstacle being placed over wolves
                  for (int i = 0; i < wolves.size(); i++) {
                    float wolfX = wolves.get(i).getPos().x;
                    float wolfZ = wolves.get(i).getPos().z;
                    if (wolfX > xBound2.x - 7 && wolfX < xBound2.z + 7 &&
                        wolfZ > zBound2.x - 7 && wolfZ < zBound2.z + 7) {
                      wolves.remove(i);
                      i--;
                    }
                  }
                }
                break;
        default:
                break;
      }
    }
  }
  
  void boids() {

    if (chickens.size() > 1) {
      float baseScale = 0.6;
      float localFlockDistance = 500;
      float frightDistance = 500;
      float attractDistance = 400;
      float matchPosM = 30 * baseScale;
      float moveAwayM = 60 * baseScale;
      float matchVelM = 5 * baseScale;
      float followPlayerM = 10 * baseScale;
      float distAwayFromOthers = 100 * baseScale;
      float wolfFrightM = 9 * baseScale;
      Vector2D[] sumsOfBoid = new Vector2D[chickens.size()];
      for (int i = 0; i < chickens.size(); i++) {
        Vector2D sumOfBoid = new Vector2D(0,0);
        
        /////////////////////////////////////////////////////
        
        // Move each chicken toward the center position
        // of all chickens
        
        Vector2D centerOfChickens = new Vector2D(0,0);
        for (int j = 0; j < chickens.size(); j++) {
          float jDist = chickens.get(j).getPos().d(chickens.get(i).getPos()).magnitude();
          if (i != j && jDist < localFlockDistance) {
            centerOfChickens.addV(chickens.get(j).getPos());
          }
        }
        centerOfChickens.divide(chickens.size()-1);
        Vector2D dist = centerOfChickens.d(chickens.get(i).getPos());
        dist.normalizeV();
        if ((int) random(0,10) > 5) {
          dist.scaler(-1.0);
        }
        dist.scaler(matchPosM);
        sumOfBoid.addV(dist);
        
        /////////////////////////////////////////////////////
        
        // Keep chickens away from each other
        Vector2D moveAway = new Vector2D(0,0);
        for (int j = 0; j < chickens.size(); j++) {
          if (i != j) {
            Vector2D dist2 = chickens.get(i).getPos().d(chickens.get(j).getPos());
            float dist2Mag = dist2.magnitude();
            if (dist2Mag < distAwayFromOthers) {
              moveAway.addV(dist2);
            }
          }
        }
        moveAway.normalizeV();
        moveAway.scaler(moveAwayM);
        sumOfBoid.addV(moveAway);
        
        /////////////////////////////////////////////////////
        
        // Match nearby chickens velocities
        Vector2D centerOfChickensVel = new Vector2D(0,0);
        for (int j = 0; j < chickens.size(); j++) {
          float jDist = chickens.get(j).getPos().d(chickens.get(i).getPos()).magnitude();
          if (i != j && jDist < localFlockDistance) {
            centerOfChickensVel.addV(chickens.get(j).getVel());
          }
        }
        centerOfChickensVel.divide(chickens.size()-1);
        centerOfChickensVel.normalizeV();
        centerOfChickensVel.scaler(matchVelM);
        sumOfBoid.addV(centerOfChickensVel);
        
        /////////////////////////////////////////////////////
        
        // Flock around player
        
        Vector2D distToPlayer = user.getPos().d(chickens.get(i).getPos());
        if (user.getState() == 1) {
          if (distToPlayer.magnitude() < frightDistance) {
            distToPlayer.normalizeV();
            distToPlayer.scaler(followPlayerM);
            float spookFactor = -3.0*followPlayerM/(distToPlayer.magnitude()+0.0001);
            distToPlayer.scaler(spookFactor);
            
            sumOfBoid.addV(distToPlayer);
          }
        } else {
          if (distToPlayer.magnitude() < attractDistance) {
            distToPlayer.normalizeV();
            distToPlayer.scaler(followPlayerM);
            
            sumOfBoid.addV(distToPlayer);
          }
        }

        
        /////////////////////////////////////////////////////
        
        // Run away from wolves
        
        for (int j = 0; j < wolves.size(); j++) {
          Vector2D distToWolf = wolves.get(j).getPos().d(chickens.get(i).getPos());
          if (wolfAttack) {
            if (distToWolf.magnitude() < frightDistance) {
              distToWolf.normalizeV();
              distToWolf.scaler(wolfFrightM);
              float spookFactor = -3.0*followPlayerM/(distToWolf.magnitude()+0.0001);
              distToWolf.scaler(spookFactor);
              
              sumOfBoid.addV(distToWolf);
            }
          }
        }
        
        
        /////////////////////////////////////////////////////
        
        
        /////////////////////////////////////////////////////
        
        sumsOfBoid[i] = sumOfBoid;
        /////////////////////////////////////////////////////
      }
      for (int i = 0; i < chickens.size(); i++) {
        chickens.get(i).getVel().addV(sumsOfBoid[i]);
      }
    }
    
    
    // Limits the speed of the chickens
    if (chickens.size() > 1) {
      for (int i = 0; i < chickens.size(); i++) {
        float limitSpeed = 1400;
        
        float chickenSpeed = chickens.get(i).getVel().magnitude();
        if (chickenSpeed > limitSpeed) {
          chickens.get(i).getVel().divide(chickenSpeed);
          chickens.get(i).getVel().scaler(limitSpeed);
        }
      }
    }
  }
  
  
  
  void drawGame() {
    
    
    if (gameOver) {
      stroke(0);
      fill(0);
      text("Chickens Saved: " + chickensSafe , -140, -500, -250);
      text("Chickens Eatten: " + chickensEatten, -140, -450, -250);
    }
    
    /////////////////////////////////////////////////////
    // Draws floor
    stroke(255,0,0);
    fill(50,150,50);
    beginShape();
    vertex(center.x-(size*0.5), 0, center.z-(size*0.5));
    vertex(center.x+(size*0.5), 0, center.z-(size*0.5));
    vertex(center.x+(size*0.5), 0, center.z+(size*0.5));
    vertex(center.x-(size*0.5), 0, center.z+(size*0.5));
    endShape();
    //
    /////////////////////////////////////////////////////
    
    if (gameRunning) {
      /////////////////////////////////////////////////////
      // Check if game over
      boolean endGame = true;
      
      chickensSafe = 0;
      for (int i = 0; i < chickens.size(); i++) {
        if (!chickens.get(i).inPen()) {
          endGame = false;
        } else {
          chickensSafe++;
        }
      }
      // Ends game when all chickens are eatten or safe
      if (endGame) {
        gameOver = true;
        gameRunning = false;
      }
      
      // Update chickens
      for (int i = 0; i < chickens.size(); i++) {
        chickens.get(i).update();
      }
      
      // Update wolves
      for (int i = 0; i < wolves.size(); i++) {
        wolves.get(i).update();
      }
      
      
      // Wolves will attempt to attack chickens if turned on
      if (wolfAttack) {
        if (searchTimer == 20) {
          for (int i = 0; i < wolves.size(); i++) {
            wolves.get(i).setPath(WolfPRM(wolves.get(i)));
          }
          searchTimer = 0;
          if (mapTimer == 4) {
            generateNewMap = true;
            mapTimer = 0;
          } else {
            mapTimer++;
          }
        } else {
          searchTimer++;
        }
        
        // Handle wolves collisions with chickens
        for (int i = 0; i < wolves.size(); i++) {
          for (int j = 0; j < chickens.size(); j++) {
            Vector2D dist = chickens.get(j).getPos().d(wolves.get(i).getPos());
            float distM = dist.magnitude();
            if (distM < 20.0) {
              chickens.remove(j);
              chickensEatten++;
              // Reupdate wolf's goal after old goal has been achieved
              wolves.get(i).setPath(WolfPRM(wolves.get(i)));
            }
          }
        }
      }
      
      // Chickens will flock if turned on
      if (chickenBoid) {
        this.boids();
      }
      //
      /////////////////////////////////////////////////////
    }
    
    /////////////////////////////////////////////////////
    // Draws obstacles
    for (int i = 0; i < obstacles.size(); i++) {
      obstacles.get(i).drawObstacle();
    }
    //
    /////////////////////////////////////////////////////
    
    /////////////////////////////////////////////////////
    // Draws chickenPens
    for (int i = 0; i < chickenPens.size(); i++) {
      chickenPens.get(i).drawChickenPen();
    }
    //
    /////////////////////////////////////////////////////
    
    /////////////////////////////////////////////////////
    // Draws chickens
    for (int i = 0; i < chickens.size(); i++) {
      chickens.get(i).drawChicken();
    }
    //
    /////////////////////////////////////////////////////
    
    /////////////////////////////////////////////////////
    // Draws setupAgent
    if (gameSetup) {
      setupAgent.drawSetupAgent();
    }
    //
    /////////////////////////////////////////////////////
    
    /////////////////////////////////////////////////////
    // Draws player
    user.drawPlayer();
    //
    /////////////////////////////////////////////////////
    
    /////////////////////////////////////////////////////
    // Draws wolves
    for (int i = 0; i < wolves.size(); i++) {
      wolves.get(i).drawWolf();
    }
    //
    /////////////////////////////////////////////////////
  }
  
  ArrayList<Milestone> WolfPRM(Wolf agent) {
    
    // Sample random points
    if (generateNewMap) {
      PRM_Map.clear();
      for (int i = 0; i < numberOfSampledPoints; i++) {
        // Randomly sample configurations
        float randomX =  random(center.x - size * 0.5, center.x + size * 0.5);
        float randomZ =  random(center.z - size * 0.5, center.z + size * 0.5);
        boolean validMilestone = true;
        // Check if sampled point is inside an obstacle
        for (int k = 0; k < obstacles.size(); k++) {
          Vector2D xBound = obstacles.get(k).getXBound();
          Vector2D zBound = obstacles.get(k).getZBound();
          
          if (randomX > xBound.x - 5 && randomX < xBound.z + 5 &&
              randomZ > zBound.x - 5 && randomZ < zBound.z + 5) {
            validMilestone = false;
          } 
        }
        // Check if sampled point is inside an chicken pen
        for (int k = 0; k < chickenPens.size(); k++) {
          Vector2D xBound = chickenPens.get(k).getXBound();
          Vector2D zBound = chickenPens.get(k).getZBound();
          
          if (randomX > xBound.x - 5 && randomX < xBound.z + 5 &&
              randomZ > zBound.x - 5 && randomZ < zBound.z + 5) {
            validMilestone = false;
          } 
        }
        if (validMilestone) {
          PRM_Map.add(new Milestone(randomX, randomZ, 0));
        } else {
          i--;
        }
      }
    }
    ArrayList<Milestone> milestones = new ArrayList<Milestone>(PRM_Map);
    ArrayList<Edge> paths = new ArrayList<Edge>();
    
    // Create goal milestone
    for (int i = 0; i < chickens.size(); i++) {
      milestones.add(new Milestone(chickens.get(i).getPos().x, chickens.get(i).getPos().z, 2));
    }
    // Create source milestone
    milestones.add(new Milestone(agent.getPos().x, agent.getPos().z, 0));
    
    // Straight lines connect neighboring milestones
    for (int i = 0; i < milestones.size(); i++) {
      for (int j = 0; j < milestones.size(); j++) {
        float dist = abs((milestones.get(j).getPos().x - milestones.get(i).getPos().x));
        dist += abs((milestones.get(j).getPos().z - milestones.get(i).getPos().z));
        if (dist < edgeMaxDistance && dist > 0) {
          boolean addEdge = true;
          // Check for edge collision with obstacles
          for (int k = 0; k < obstacles.size(); k++) {
            Vector2D pointA = milestones.get(i).getPos();
            Vector2D pointB = milestones.get(j).getPos();
            Vector2D xBound = obstacles.get(k).getXBound();
            Vector2D zBound = obstacles.get(k).getZBound();
            Vector2D endPointA = new Vector2D(xBound.x - 10, zBound.x + 10);
            Vector2D endPointB = new Vector2D(xBound.z - 10, zBound.x + 10);
            Vector2D endPointC = new Vector2D(xBound.z - 10, zBound.z + 10);
            Vector2D endPointD = new Vector2D(xBound.x - 10, zBound.z + 10);
            
            if (linesIntersect(pointA, pointB, endPointA, endPointB)) {
              addEdge = false;
            }
            if (linesIntersect(pointA, pointB, endPointB, endPointC)) {
              addEdge = false;
            }
            if (linesIntersect(pointA, pointB, endPointC, endPointD)) {
              addEdge = false;
            }
            if (linesIntersect(pointA, pointB, endPointD, endPointA)) {
              addEdge = false;
            }
          }
          // Check for edge collision with chicken pens
          for (int k = 0; k < chickenPens.size(); k++) {
            Vector2D pointA = milestones.get(i).getPos();
            Vector2D pointB = milestones.get(j).getPos();
            Vector2D xBound = chickenPens.get(k).getXBound();
            Vector2D zBound = chickenPens.get(k).getZBound();
            Vector2D endPointA = new Vector2D(xBound.x - 10, zBound.x + 10);
            Vector2D endPointB = new Vector2D(xBound.z - 10, zBound.x + 10);
            Vector2D endPointC = new Vector2D(xBound.z - 10, zBound.z + 10);
            Vector2D endPointD = new Vector2D(xBound.x - 10, zBound.z + 10);
            
            if (linesIntersect(pointA, pointB, endPointA, endPointB)) {
              addEdge = false;
            }
            if (linesIntersect(pointA, pointB, endPointB, endPointC)) {
              addEdge = false;
            }
            if (linesIntersect(pointA, pointB, endPointC, endPointD)) {
              addEdge = false;
            }
            if (linesIntersect(pointA, pointB, endPointD, endPointA)) {
              addEdge = false;
            }
          }
          
          // Check for edge collision with player
          for (int k = 0; k < 1; k++) {
            Vector2D pointA = milestones.get(i).getPos();
            Vector2D pointB = milestones.get(j).getPos();
            Vector2D userPos = user.getPos();
            Vector2D xBound = new Vector2D(userPos.x - 20, userPos.x + 20);
            Vector2D zBound = new Vector2D(userPos.z - 20, userPos.z + 20);
            Vector2D endPointA = new Vector2D(xBound.x - 10, zBound.x + 10);
            Vector2D endPointB = new Vector2D(xBound.z - 10, zBound.x + 10);
            Vector2D endPointC = new Vector2D(xBound.z - 10, zBound.z + 10);
            Vector2D endPointD = new Vector2D(xBound.x - 10, zBound.z + 10);
            
            if (linesIntersect(pointA, pointB, endPointA, endPointB)) {
              addEdge = false;
            }
            if (linesIntersect(pointA, pointB, endPointB, endPointC)) {
              addEdge = false;
            }
            if (linesIntersect(pointA, pointB, endPointC, endPointD)) {
              addEdge = false;
            }
            if (linesIntersect(pointA, pointB, endPointD, endPointA)) {
              addEdge = false;
            }
          }
          if (addEdge) {
            paths.add(new Edge(milestones.get(i), milestones.get(j), dist));
          }
        }
      }
    }
    
    // Create source milestone index
    int agentMilestone = milestones.size()-1;
    // Create goal milestone index
    int goalMilestone = 0;

    
    // Perform search algorithm
    dijkstraResult djikstraR = dijkstra(milestones, paths, milestones.get(agentMilestone));
    
    // Finds closest goal to go after
    float shortestDist = djikstraR.dist[0];
    for (int i = 0; i < milestones.size() - 1; i++) {
      if (djikstraR.dist[i] < shortestDist && (milestones.get(i).getType() == 2)) {
        shortestDist = djikstraR.dist[i];
        goalMilestone = i;
      }
      
    }
    
    ArrayList<Milestone> agentPath = new ArrayList<Milestone>();
    agentPath.add(milestones.get(goalMilestone));
    
    Milestone pathTile = milestones.get(agentMilestone);
    if (djikstraR.prev[goalMilestone] != null) {
      pathTile = djikstraR.prev[goalMilestone];
    }
    while (pathTile != null) {
      agentPath.add(pathTile);
      pathTile = pathTile.getPrev();
    }
    Collections.reverse(agentPath);
    return agentPath;
  }
}
