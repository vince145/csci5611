// vince145_thread by Matthew Vincent, vince145
// for CSCI 5611 at the University of Minnesota Twin Cities
// Physics code and update frequency adapted from Stephen Guy's string physics.
//
//
//////////////////////////////////////////////////////////////////
// TODO: 
//
//
//
//////////////////////////////////////////////////////////////////


float dt = 0.001;
float k = 60;
float kv = 40;
float rl = 7;
float gravity = 9.8;
float mass = 7;
ArrayList<Spring> springs = new ArrayList<Spring>();
float newSpringX = 200;
float newSpringY = 0;

void setup() {
  size(400, 600, P3D);
  for (int i = 0; i < 15; i++) {
    springs.add(new Spring());
  }
  fill(255);
  stroke(255);
  strokeWeight(3);
}

void draw() {
  lights();
  background(0, 0, 0); // Black background
  for (int i = 0; i<100; i++) {
    updateThreads();
  }
  drawThreads();
  
  text("Frame rate: " + int(frameRate), 10, 590);
}

public class Vector {
  float x;
  float y;
  float z;
  
  Vector(float newX, float newY, float newZ) {
    x = newX;
    y = newY;
    z = newZ;
  }
  
  void scaler(float scalerValue) {
    x = x * scalerValue;
    y = y * scalerValue;
    z = z * scalerValue;
  }
  
  float magnitude() {
    return sqrt((x*x)+(y*y)+(z*z));
  }
  
  float xzMagnitude() {
    return sqrt((x*x)+(z*z));
  }
  
  // Calculates distance from point startV to .this point.
  Vector d(Vector startV) {
    Vector distanceVector = new Vector(x-startV.x, y-startV.y, z-startV.z);
    return distanceVector;
  }
  
  float dotProd(Vector startV) {
    float dotProduct = (x * startV.x) + (y * startV.y);
    return dotProduct;
  }
}

void drawThreads() {
  for (int i = 1; i < springs.size(); i++) {
    pushMatrix();
    stroke(255);
    line(springs.get(i-i).getPos().x, springs.get(i-i).getPos().y,
         springs.get(i).getPos().x, springs.get(i).getPos().y);
    stroke(255,198,253);
    translate(springs.get(i).getPos().x, springs.get(i).getPos().y,0);
    sphere(2);
    popMatrix();
  }
}

void updateThreads() {
  if (springs.size() > 1) {
    //springs.get(0).update(dt, null, springs.get(1));
  }
  for (int i = 1; i < springs.size()-1; i++) {
    springs.get(i).update(dt, springs.get(i-1), springs.get(i+1));
  }
  if (springs.size() > 1) {
    springs.get((springs.size()-1)).update(dt, springs.get(springs.size()-2), null);
  }
  if (mousePressed) {
    springs.get(springs.size()-1).moveToward(new Vector(0,mouseY,0));
  }
}

class Spring {
  Vector pos;
  Vector vel;
  Vector acc;
  Vector force;
  //Spring neighbor;
  
  Spring() {
    pos =  new Vector (newSpringX, newSpringY, 0);
    vel = new Vector (0, 0, 0);
    acc = new Vector (0, 0, 0);
    force = new Vector (0, 0, 0);
    newSpringY += 23;
  }
  
  Vector getPos() {
    return pos;
  }
  Vector getVel() {
    return vel;
  }
  Vector getForce() {
    return force;
  }
  void moveToward(Vector target) {
    vel = target.d(pos);
    vel.scaler(10);
  }
  
  void update(float dt, Spring neighborW, Spring neighborD) {
    float dampF = 0;
    float springF = 0;
    if (neighborW == null) {
      force.y = 0;
    } else {
      springF = -k*(pos.y - neighborW.getPos().y) - rl;
      dampF = -kv*(vel.y - neighborW.getVel().y);
      force.y = dampF + springF;
    }
    if (neighborD == null) {
      acc.y = gravity + 0.5*force.y/mass;
    } else {
      acc.y = gravity + 0.5*force.y/mass - 0.5*neighborD.getForce().y/mass;
    }
    vel.y += acc.y*dt;
    pos.y += vel.y*dt;
  }
}
