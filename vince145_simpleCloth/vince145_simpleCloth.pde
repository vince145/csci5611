// vince145_simpleCloth by Matthew Vincent, vince145
// for CSCI 5611 at the University of Minnesota Twin Cities
// Physics code and update frequency adapted from Stephen Guy's string physics.
//
//
//
// PeasyCam 3D user interactive camera library is used.
// The PeasyCam library was made by Jonathan Feinberg
// http://mrfeinberg.com/peasycam/
//
//////////////////////////////////////////////////////////////////
// TODO: 
//
//
//
//////////////////////////////////////////////////////////////////

import peasy.*;

PeasyCam cam;

int nSprings = 30;
int meters = 50;
int nx = nSprings;
int ny = nSprings;
Spring[][] springs = new Spring[nx][ny];
float rl = meters/nSprings;
float dt = 0.0000001;
float k = 1000000; // 80000
float kv = 10000; // 4000
float mass = 0.6*(rl*rl/4);
float gravity = 9.8;
float newSpringX = 200;
float newSpringY = 0;
float newSpringZ = 0;

float sphereR = 7.5;
Vector sphereP = new Vector(17.5,17.5,0);

PImage poohbear;

boolean sphereOn = true;
boolean dragOn = true;
boolean clothTextureOn = true;
boolean passiveDragOn = true;
boolean fixLeft = true;

void setup() {
  size(800, 600, P3D);
  cam = new PeasyCam(this, 85);
  cam.setMinimumDistance(85);
  cam.setMaximumDistance(800);
  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      springs[i][j] = new Spring(j*rl,0,i*rl-15);
    }
  }
  poohbear = loadImage("pooh.jpg");
  fill(255);
  stroke(255);
  strokeWeight(3);
}

void draw() {
  lights();
  background(0, 0, 0); // Black background
  for (int i = 0; i<50; i++) {
    updateThreads();
  }
  drawThreads();
  if (sphereOn) {
    drawSphere();
  }
  
  if (keyPressed == true) {
    moveSphere(key);
  }
 fill(255);
 text("Frame rate: " + int(frameRate), 0, 0, -100);
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
  
  Vector scalerNC(float scalerValue) {
    Vector resultVector = new Vector(x*scalerValue, y*scalerValue, z*scalerValue);
    return resultVector;
  }
  
  void addV(Vector addVector) {
    x = x + addVector.x;
    y = y + addVector.y;
    z = z + addVector.z;
  }
  
  void divide(float divideValue) {
    x = x / divideValue;
    y = y / divideValue;
    z = z / divideValue;
  }
  
  float magnitude() {
    return sqrt((float) ((x*x)+(y*y)+(z*z)));
  }
  
  // Calculates distance from point startV to .this point.
  Vector d(Vector startV) {
    Vector distanceVector = new Vector(x-startV.x, y-startV.y, z-startV.z);
    return distanceVector;
  }
  
  float dotProd(Vector startV) {
    float dotProduct = (x * startV.x) + (y * startV.y) + (z * startV.z);
    return dotProduct;
  }
  
  Vector crossProd(Vector b) {
    Vector resultVector = new Vector((y)*(b.z)-(z)*(b.y),
                                     -1*((x)*(b.z)-(z)*(b.x)),
                                     (x)*(b.y)-(y)*(b.x));
    return resultVector;
  }
  
  void reset() {
    x = 0;
    y = 0;
    z = 0;
  }
}

void drawSphere() {
  pushMatrix();
  noStroke();
  fill(0,255,0);
  translate(sphereP.x, sphereP.y, sphereP.z);
  sphere(sphereR);
  fill(255);
  popMatrix();
}

void moveSphere(char direction) {
  float movespeed = 0.5;
  switch (direction) {
    case 'w': sphereP.z-=movespeed;
            break;
    case 's': sphereP.z+=movespeed;
            break;
    case 'd': sphereP.x+=movespeed;
            break;
    case 'a': sphereP.x-=movespeed;
            break;
    case 'q': sphereP.y-=movespeed;
            break;
    case 'e': sphereP.y+=movespeed;
            break;
    default:
            break;
  }
}
void drawThreads() {
  if (clothTextureOn) {
    noStroke();
    fill(255,255,255);
    for (int i = 0; i < nx-1; i = i+1) {
      for (int j = 0; j < ny-1; j = j+1) {
        float u1 = poohbear.width / nSprings * i;
        float v2 = poohbear.height / nSprings * (j+1);
        float u2 = poohbear.width / nSprings * (i+1);
        float v1 = poohbear.height / nSprings * j;
        beginShape();
        texture(poohbear);
        vertex(springs[i][j].getPos().x, springs[i][j].getPos().y, springs[i][j].getPos().z, u1, v1);
        vertex(springs[i+1][j].getPos().x, springs[i+1][j].getPos().y, springs[i+1][j].getPos().z, u2, v1);
        vertex(springs[i+1][j+1].getPos().x, springs[i+1][j+1].getPos().y, springs[i+1][j+1].getPos().z, u2, v2);
        vertex(springs[i][j+1].getPos().x, springs[i][j+1].getPos().y, springs[i][j+1].getPos().z, u1, v2);
        endShape();
      }
    }
  } else {
    for (int i = 0; i < nx-1; i++) {
      for (int j = 0; j < ny-1; j++) {
        if (i == 0 || j == 0) {
          stroke(255,0,0);
        } else {
          stroke(255);
        }
        line(springs[i][j].getPos().x, springs[i][j].getPos().y, springs[i][j].getPos().z,
             springs[i+1][j].getPos().x, springs[i+1][j].getPos().y, springs[i+1][j].getPos().z);
        line(springs[i][j].getPos().x, springs[i][j].getPos().y,springs[i][j].getPos().z,
             springs[i][j+1].getPos().x, springs[i][j+1].getPos().y, springs[i][j+1].getPos().z);
      }
    }
    stroke (255,0,0);
    for (int i = 0; i < nx-1; i++) {
      line(springs[i][ny-1].getPos().x, springs[i][ny-1].getPos().y, springs[i][ny-1].getPos().z,
           springs[i+1][ny-1].getPos().x, springs[i+1][ny-1].getPos().y, springs[i+1][ny-1].getPos().z);
    }
    for (int j = 0; j < ny-1; j++) {
      line(springs[nx-1][j].getPos().x, springs[nx-1][j].getPos().y, springs[nx-1][j].getPos().z,
           springs[nx-1][j+1].getPos().x, springs[nx-1][j+1].getPos().y, springs[nx-1][j+1].getPos().z);
    }
  }
}

void updateThreads() {
  
  if (dragOn) {
    for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny; j++) {
        if (i != 0 && j!= 0) {
          springs[i][j].updateDrag(dt, springs[i][j-1], springs[i-1][j], springs[i-1][j-1]);
        } 
      }
    }
  }
  
  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      if (i != 0 && j!= 0) {
        springs[i][j].update(dt, springs[i][j-1], springs[i-1][j], springs[i-1][j-1]);
      } else if (i == 0 && j == 0) {
        springs[i][j].update(dt, null,null, null);
      } else if (i == 0 && j != 0) {
        springs[i][j].update(dt, springs[i][j-1], null, null);
      } else if (i != 0 && j == 0) {
        springs[i][j].update(dt, null, springs[i-1][j], null);
      }
    }
  }
  if (fixLeft) {
    for (int i = 0; i < nx; i++) {
      springs[i][0].setVel(new Vector(0,0,0));
      springs[i][0].fixY();
      springs[i][0].setPos(new Vector(0,0,i*rl-15));
    }
  }
}

class Spring {
  Vector pos;
  Vector vel;
  Vector acc;
  Vector force;
  
  Spring() {
    pos =  new Vector (newSpringX, newSpringY, newSpringZ);
    vel = new Vector (0, 0, 0);
    acc = new Vector (0, 0, 0);
    force = new Vector (0, 0, 0);
  }
  
  Spring(float startX, float startY, float startZ) {
    pos =  new Vector (startX, startY, startZ);
    vel = new Vector (0, 0, 0);
    acc = new Vector (0, 0, 0);
    force = new Vector (0, 0, 0);
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
  void setVel(Vector newVel) {
    vel = newVel;
  }
  void setPos(Vector newPos) {
    pos = newPos;
  }
  void setForce(Vector newForce) {
    force.x = newForce.x;
    force.y = newForce.y;
    force.z = newForce.z;
  }
  void fixY() {
    pos.y = 0;
  }
  void moveToward(Vector target) {
    vel = target.d(pos);
    vel.scaler(10);
  }
  
  void update(float dt, Spring neighborW, Spring neighborA, Spring neighborQ) {
    float dampF = 0;
    float springF = 0;
    float v1 = 0;
    float v2 = 0;
    Vector unitLength = new Vector(0,0,0);
    float threadLength = 0;
    float totalSpringF = 0;
    
    // Handles vertical neighbors
    
    if (neighborW == null) {
      //force.y = 0;
    } else {
      unitLength = pos.d(neighborW.getPos());
      threadLength = unitLength.magnitude();
      unitLength.divide(threadLength);
      v2 = unitLength.dotProd(vel);
      v1 = unitLength.dotProd(neighborW.getVel());
      springF = -k*(rl-threadLength);
      dampF = -kv*(v1-v2);
      totalSpringF = springF + dampF;
      vel = vel.d(unitLength.scalerNC(0.5*totalSpringF*dt));
      
      neighborW.getVel().addV(unitLength.scalerNC(0.5*totalSpringF*dt));

      
    }
    
    // Handles horizontal neighbors
    
    
    if (neighborA == null) {
      //force.x = 0;
    } else {
      unitLength = pos.d(neighborA.getPos());
      threadLength = unitLength.magnitude();
      unitLength.divide(threadLength);
      v2 = unitLength.dotProd(vel);
      v1 = unitLength.dotProd(neighborA.getVel());
      springF = -k*(rl-threadLength);
      dampF = -kv*(v1-v2);
      totalSpringF = (dampF + springF);

      vel = vel.d(unitLength.scalerNC(0.5*totalSpringF*dt));
      
      neighborA.getVel().addV(unitLength.scalerNC(0.5*totalSpringF*dt));
    }
    
    
    
    
    acc.y = (force.y + gravity)/mass;
    acc.z = force.z/mass;
    acc.x = force.x/mass;
    vel.y += acc.y * dt;
    vel.z += acc.z * dt;
    vel.x += acc.x * dt;
    
    if (passiveDragOn) {
      vel.scaler(0.99985);
    }
    
    pos.addV(vel);
    
    if (sphereOn) {
      float sphereDistance = pos.d(sphereP).magnitude();
      if (sphereDistance < sphereR + 0.12) {
        Vector n = new Vector(0,0,0);
        n = sphereP.d(pos);
        n.scaler(-1);
        n.divide(n.magnitude());
        Vector bounce = new Vector(0,0,0);
        bounce = n.scalerNC(vel.dotProd(n));
        vel = vel.d((bounce.scalerNC(1.5)));
        pos.addV(n.scalerNC(0.13 + sphereR - sphereDistance));
      }
    }
    
  }
  
  void updateDrag(float dt, Spring neighborW, Spring neighborA, Spring neighborQ) {
    // Drag
    if (dragOn) {
      if (neighborA != null && neighborW != null) {
        float dragCoefficient = 0.5;
        float airMassDensity = 1.225; // 1.225
        // Lower triangle
        Vector dragForce = new Vector(0,0,0);
        
        float dragVelocity = 0;
        Vector dragVelocityVector = new Vector(0,0,0);
        dragVelocityVector.addV(vel);
        dragVelocityVector.addV(neighborA.getVel());
        dragVelocityVector.addV(neighborW.getVel());
        dragVelocityVector.divide(3);
        dragVelocity = dragVelocityVector.magnitude();
        
        Vector dragNormal = new Vector(0,0,0);
        dragNormal = (pos.d(neighborA.getPos())).crossProd(pos.d(neighborW.getPos()));
        float van = dragVelocity*(dragVelocityVector.dotProd(dragNormal)) / (2 * dragNormal.magnitude());
        dragForce = dragNormal.scalerNC(van);
        dragForce.scaler(-0.5);
        dragForce.scaler(airMassDensity); // mass density of air, p
        dragForce.scaler(dragCoefficient); // drag coefficient 
        force.addV(dragForce.scalerNC(0.3333333333));

        neighborA.getForce().addV(dragForce.scalerNC(0.3333333333));
        neighborW.getForce().addV(dragForce.scalerNC(0.3333333333));
        //println(dragForce.x + ",  " + dragForce.y + ",   " + dragForce.z);
        // Upper triangle
        
        dragVelocityVector.reset();
        dragForce.reset();
        dragNormal.reset();
        dragVelocityVector.addV(neighborQ.getVel());
        dragVelocityVector.addV(neighborA.getVel());
        dragVelocityVector.addV(neighborW.getVel());
        dragVelocityVector.divide(3);
        
        dragVelocity = dragVelocityVector.magnitude();
        
        dragNormal = (neighborA.getPos().d(neighborQ.getPos())).crossProd(neighborW.getPos().d(neighborQ.getPos()));
        van = dragVelocity*(dragVelocityVector.dotProd(dragNormal)) / (2 * dragNormal.magnitude());
        dragForce = dragNormal.scalerNC(van);
        
        dragForce.scaler(-0.5);
        dragForce.scaler(airMassDensity); // mass density of air, p
        dragForce.scaler(dragCoefficient); // drag coefficient
        neighborQ.getForce().addV(dragForce.scalerNC(0.3333333333));
        neighborA.getForce().addV(dragForce.scalerNC(0.3333333333));
        neighborW.getForce().addV(dragForce.scalerNC(0.3333333333));
      }
    }
  }
}
