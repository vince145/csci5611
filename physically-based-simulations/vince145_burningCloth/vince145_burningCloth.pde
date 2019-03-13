// vince145_advancedCloth by Matthew Vincent, vince145
// for CSCI 5611 at the University of Minnesota Twin Cities
// Physics code and update frequency adapted from Stephen Guy's string physics.
//
//
//
// PeasyCam 3D user interactive camera library is used.
// The PeasyCam library was made by Jonathan Feinberg
// http://mrfeinberg.com/peasycam/
//
// 
// Cloth Eulerian integration and drag physics adapted from
// Stephen Guy's cloth physics.
//
//////////////////////////////////////////////////////////////////
// TODO: 
//
//   - Add cloth burning
//   - Add cloth self-collision
//   - Add higher-order explicit integrator
//   - Add Implicit integrator
//   - Compare performance of different integrators
//   - Add thread-parallel implementation
//   - Add two-way coupling object-simulation coupling,
//     cloth moves ball
//   - Better configure k, kv, mass constants
//
//////////////////////////////////////////////////////////////////

import peasy.*;
import java.util.*;

PeasyCam cam; // Main instance of PeasyCam used for program

// Setting up global variables to be used in the spring system
int nSprings = 30; // Number of springs used in the mass-spring system
int meters = 50; // Ideal length of the cloth
int nx = nSprings; // Number of springs per row
int ny = nSprings; // Number of springs per column
Spring[][] springs = new Spring[nx][ny];
float initialrl = meters/nSprings;
float dt = 0.0000001; // Time step
float k = 1000000; // 80000,  spring constant
float kv = 10000; // 4000,    dampening constant for springs
float mass = 0.6*(initialrl*initialrl/4); // mass of cloth area surrounding spring
float gravity = 9.8;

Vector windVector = new Vector(0,0,0); // used for referencing wind acceleration

float sphereR = 7.5; // sphere radius
Vector sphereP = new Vector(17.5,17.5,0); // sphere starting position

float pullingDistance = 0; // used for user interaction stretching/contracting
                           // the fixed ends of cloth

float floorY = 50; // used to setup the distance of the floor from (0,0,0)

PImage poohbear; // used for cloth texture

// Fire variables
int particleLimit = 100000;
ArrayList<Particle> particles = new ArrayList<Particle>();
PImage fire01;
PImage fire02;
PImage fire03;
//////////////////////////////////////////////////////////////////
// The booleans below are used for setting up different simulation
// elements or physics for the cloth physical simulation.
// They may be turned off or on freely to observe the effect
// each feature has on the system.
//
//
//

// GENERAL FEATURES

// Adds in a user controllable sphere to interact with the cloth
// Input keys: with reference to starting camera orientation
// q = move sphere up, y increase
// e = move sphere down, y decreases
// w = move sphere away from start, z decreases
// s = move sphere toward start, z increases
// a = move sphere left, x decreases
// d = move sphere right, x increases
boolean sphereOn = true; 

// Adds in air drag physics for air collision with surface area of cloth
boolean dragOn = true;

// Modifies how the cloth is drawn to show a texture of Pooh rather than a wireframe
boolean clothTextureOn = true;

// Adds in passive drag to reduce velocity and forces overtime to stabalize cloth to rest
boolean passiveDragOn = true;

// Adds in wind to the drag applied in the x direction that may be increased by the user.
// Input keys:
// 1 = increase wind acceleration in x direction
// 2 = decrease wind acceleration in x direction
boolean windOn = true;

// Adds in a floor drawn that may collide with the cloth and allow the cloth to fall onto.
boolean floorOn = false;

// Adds in the frame rate and wind acceleration to observe as text in the background
boolean textOn = true;

// Adds in burning cloth
boolean burningOn = true;

// FEATURES THAT FIX CLOTH AT STARTING POINT
// TURN BOTH ON FOR HORIZONTAL CLOTH IN AIR
// TO STRETCH OR CONTRACT
// Input keys:
// z = stretch fix points outward
// x = contract fix points inward
// c = sets fixLeft to false
// v = sets fixRight to false
// b = sets fixLeft and fixRight both to false
boolean fixRight = true;
boolean fixLeft = true;


//
//
//
//////////////////////////////////////////////////////////////////

/*
  Spring(float startX, float startY, float startZ, 
         Spring sNeighborW, Spring sNeighborA, Spring sNeighborQ, 
         Spring sNeighborD, Spring sNeighborS) {
*/
void setup() {
  //size(800, 600, P3D);
  size(1920, 1080, P3D);
  cam = new PeasyCam(this, 120);
  //cam.setMinimumDistance(85);
  cam.setMinimumDistance(120);
  cam.setMaximumDistance(800);
  
  // Creates initial placement of each spring in the spring-mass system
  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      if (i != 0 && j!= 0) {
        springs[i][j] = new Spring(j*initialrl,0,i*initialrl-15,
                                   springs[i][j-1], springs[i-1][j], springs[i-1][j-1]);
      } else if (i == 0 && j == 0) {
        springs[i][j] = new Spring(j*initialrl,0,i*initialrl-15,
                                   null, null, null);
      } else if (i == 0 && j != 0) {
        springs[i][j] = new Spring(j*initialrl,0,i*initialrl-15,
                                   springs[i][j-1], null, null);
      } else if (i != 0 && j == 0) {
        springs[i][j] = new Spring(j*initialrl,0,i*initialrl-15,
                                   null, springs[i-1][j], null);
      }
    }
  }
  
  poohbear = loadImage("pooh.jpg");
  fill(255);
  stroke(255);
  strokeWeight(3);
  if (burningOn) {
    fire01 = loadImage("fireT01.png");
    fire02 = loadImage("fireT02.png");
    fire03 = loadImage("fireT03.png");
    sphereR = 2.5;
  }
}

// Lights, background, cloth are drawn to simulate a
// physical representation of a cloth using a mass-spring
// system as a basis for the physics.

void draw() {
  lights();
  background(0, 0, 0); // Black background
  // Updates physics of each spring in cloth
  // 50 times for each draw frame to allow
  // small dt
  if (burningOn) {
    updateBurn();
    drawFireParticles();
  }
  
  for (int i = 0; i<50; i++) {
    updateThreads();
  }
  
  // Draws cloth
  drawThreads();
  // Draws sphere
  if (sphereOn) {
    drawSphere();
  }
  // Draws floor
  if (floorOn) {
    drawFloor();
  }
  
  // Handles user input and moves sphere
  if (keyPressed == true) {
    handleInput(key);
  }
  // Creates background text for rendering
  fill(255);
  if (textOn) {
    if (windOn) {
     text("Wind accel: " + windVector.x, 0, -12, -100);
    }
   text("Frame rate: " + int(frameRate), 0, 0, -100);
  }
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
  
  float xzMagnitude() {
    return sqrt((x*x)+(z*z));
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

void drawFloor() {
  pushMatrix();
  noStroke();
  translate(0,floorY,0);
  fill(255,100,100); // brownish
  box(1500,5,1500); // Grass floor
  //fill(255,100,100); // Brownish
  //box(500,-10,500); // Brick floor
  popMatrix();
}

void drawSphere() {
  pushMatrix();
  noStroke();
  fill(255,0,0);
  translate(sphereP.x, sphereP.y, sphereP.z);
  sphere(sphereR);
  fill(255);
  popMatrix();
}

// Refer to features up above to learn
// about what each input does.
void handleInput(char direction) {
  float movespeed = 0.5;
  float pullingSpeed = 0.1;
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
    case 'z': pullingDistance += pullingSpeed;
            break;
    case 'x': pullingDistance -= pullingSpeed;
            break;
    case 'c': fixLeft = false;
            break;
    case 'v': fixRight = false;
            break;
    case 'b': fixRight = false;
              fixLeft = false;
            break;
   case '1': windVector.addV(new Vector(0.001,0,0));
            break;
   case '2': windVector.addV(new Vector(-0.001,0,0));
            break;
    default:
            break;
  }
}
void drawThreads() {
  // Handles textured cloth
  if (clothTextureOn) {
    noStroke();
    fill(255,255,255);
    for (int i = nx-1; i > 0; i = i-1) {
      for (int j = ny-1; j > 0; j = j-1) {
        if (springs[i][j].getNeighborW() != null &&
            springs[i][j].getNeighborA() != null &&
            springs[i][j].getNeighborQ() != null) {
          float u1 = poohbear.width / nSprings * i;
          float v2 = poohbear.height / nSprings * (j-1);
          float u2 = poohbear.width / nSprings * (i-1);
          float v1 = poohbear.height / nSprings * j;
          beginShape();
          texture(poohbear);
          vertex(springs[i][j].getPos().x, springs[i][j].getPos().y, springs[i][j].getPos().z, u1, v1);
          vertex(springs[i-1][j].getPos().x, springs[i-1][j].getPos().y, springs[i-1][j].getPos().z, u2, v1);
          vertex(springs[i-1][j-1].getPos().x, springs[i-1][j-1].getPos().y, springs[i-1][j-1].getPos().z, u2, v2);
          vertex(springs[i][j-1].getPos().x, springs[i][j-1].getPos().y, springs[i][j-1].getPos().z, u1, v2);
          endShape();
        }
      }
    }
  // Handles non-textured cloth with wireframe
  } else {
    for (int i = nx-1; i > 0; i = i-1) {
      for (int j = ny-1; j > 0; j = j-1) {
        if (springs[i][j].getNeighborW() != null &&
            springs[i][j].getNeighborA() != null &&
            springs[i][j].getNeighborQ() != null) {
          if (i == 1 || j == 1) {
            stroke(255,0,0);
          } else {
            stroke(255);
          }
          line(springs[i][j].getPos().x, springs[i][j].getPos().y, springs[i][j].getPos().z,
               springs[i-1][j].getPos().x, springs[i-1][j].getPos().y, springs[i-1][j].getPos().z);
          line(springs[i][j].getPos().x, springs[i][j].getPos().y,springs[i][j].getPos().z,
               springs[i][j-1].getPos().x, springs[i][j-1].getPos().y, springs[i][j-1].getPos().z);
        }
      }
    }
    stroke (255,0,0);
    // Draws red outline
    for (int i = nx-1; i > 0; i--) {
      if (springs[i][ny-1].getNeighborW() != null &&
          springs[i][ny-1].getNeighborA() != null &&
          springs[i][ny-1].getNeighborQ() != null) {
        line(springs[i][ny-1].getPos().x, springs[i][ny-1].getPos().y, springs[i][ny-1].getPos().z,
             springs[i-1][ny-1].getPos().x, springs[i-1][ny-1].getPos().y, springs[i-1][ny-1].getPos().z);
      }
    }
    // Draws red outline
    for (int j = ny-1; j > 0; j--) {
      if (springs[nx-1][j].getNeighborW() != null &&
          springs[nx-1][j].getNeighborA() != null &&
          springs[nx-1][j].getNeighborQ() != null) {
        line(springs[nx-1][j].getPos().x, springs[nx-1][j].getPos().y, springs[nx-1][j].getPos().z,
             springs[nx-1][j-1].getPos().x, springs[nx-1][j-1].getPos().y, springs[nx-1][j-1].getPos().z);
      }
    }
  }
}

void updateThreads() {
  // Handles drag first across triangles for surface area
  if (dragOn) {
    for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny; j++) {
        if (i != 0 && j!= 0) {
          springs[i][j].updateDrag();
        } 
      }
    }
  }
  // Handles each spring and it's neighbors update
  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      springs[i][j].update();
    }
  }
  // Resets physics for fixed points
  if (fixLeft) {
    for (int i = 0; i < nx; i++) {
      springs[i][0].setVel(new Vector(0,0,0));
      springs[i][0].fixY();
      springs[i][0].setPos(new Vector(pullingDistance,0,i*initialrl-15));
    }
  }
  if (fixRight) {
    for (int i = 0; i < nx; i++) {
      springs[i][nSprings-1].setVel(new Vector(0,0,0));
      springs[i][nSprings-1].fixY();
      springs[i][nSprings-1].setPos(new Vector((nSprings-1*initialrl)-pullingDistance,0,i*initialrl-15));
    }
  }
}

void updateBurn() {
  if (burningOn) {
    for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny; j++) {
        if (i != 0 && j!= 0) {
          springs[i][j].updateBurn();
        } 
      }
    }
  }
}

class Spring {
  Vector pos;
  Vector vel;
  Vector acc;
  Vector force;
  float rl;
  Spring neighborW;
  Spring neighborA;
  Spring neighborQ;
  float life;
  boolean burning;
  
  Spring(float startX, float startY, float startZ) {
    pos =  new Vector (startX, startY, startZ);
    vel = new Vector (0, 0, 0);
    acc = new Vector (0, 0, 0);
    force = new Vector (0, 0, 0);
    rl = initialrl;
    burning = false;
  }
  
  Spring(float startX, float startY, float startZ, 
         Spring sNeighborW, Spring sNeighborA, Spring sNeighborQ) {
    pos =  new Vector (startX, startY, startZ);
    vel = new Vector (0, 0, 0);
    acc = new Vector (0, 0, 0);
    force = new Vector (0, 0, 0);
    neighborW = sNeighborW;
    neighborA = sNeighborA;
    neighborQ = sNeighborQ;
    rl = initialrl;
    life = 150;
    burning = false;
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
  float getrl() {
    return rl;
  }
  Spring getNeighborW() {
    return neighborW;
  }
  Spring getNeighborA() {
    return neighborA;
  }
  Spring getNeighborQ() {
    return neighborQ;
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
  float getLife() {
    return life;
  }
  void fixY() {
    pos.y = 0;
  }
  void moveToward(Vector target) {
    vel = target.d(pos);
    vel.scaler(10);
  }
  void startBurn() {
    burning = true;
  }

  void update() {
    float dampF = 0;
    float springF = 0;
    float v1 = 0;
    float v2 = 0;
    Vector unitLength = new Vector(0,0,0);
    float threadLength = 0;
    float totalSpringF = 0;
    float failureLength = 1.5*initialrl;
    
    // Handles vertical neighbors
    
    if (neighborW == null) {
      //force.y = 0;
    } else {
      // Eulerian Integration
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
      
      if (threadLength > failureLength) {
        neighborW = null;
      }
      
    }
    
    // Handles horizontal neighbors
    
    
    if (neighborA == null) {
      //force.x = 0;
    } else {
      // Eulerian Integration
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
      
      if (threadLength > failureLength) {
        neighborA = null;
      }
    }
    
    
    
    
    
    acc.y = (force.y + gravity)/mass;
    acc.z = force.z/mass;
    acc.x = force.x/mass;
    vel.y += acc.y * dt;
    vel.z += acc.z * dt;
    vel.x += acc.x * dt;
    
    // Settles the cloth down after time
    // with forces building up from drag / springs / wind.
    // Helps make the wind not go too crazy.
    if (passiveDragOn) {
      vel.scaler(0.99985);
      force.scaler(0.99985);
    }
    
    // Handles sphere collision with cloth
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
        if (burningOn) {
          startBurn();
        }
      }
    }
    
    // Handles floor collision with cloth
    if (floorOn) {
      Vector floorP = new Vector(pos.x,floorY,pos.z);
      float floorDistance = pos.d(floorP).magnitude();
      if (floorDistance < 0.2 + 3) {
        Vector n = new Vector(0,0,0);
        n = floorP.d(pos);
        n.scaler(-1);
        n.divide(n.magnitude());
        Vector bounce = new Vector(0,0,0);
        bounce = n.scalerNC(vel.dotProd(n));
        vel = vel.d((bounce.scalerNC(1.05)));
        force.scaler(0.65);
        vel.scaler(0.65);
        pos.addV(n.scalerNC(0.22 + 3 - floorDistance));
      }
    }
  }
  
  void updateBurn() {
    if (burningOn) {
      if (burning) {
        life--;
        for (int i = 0; i<(int) random(1,4); i++) {
          particles.add(new Particle(this));
        }
        if (life <= 30) {
          if (neighborW != null) {
            neighborW.startBurn();
          }
          if (neighborA != null) {
            neighborA.startBurn();
          }
        }
        if (life <= 5) {
          neighborW = null;
          neighborA = null;
          neighborQ = null;
          burning = false;
        }
      } else if (life > 0) {
        if (neighborW != null) {
          if (neighborW.getLife() <= 5) {
            neighborW = null;
          } else if (neighborW.getLife() <= 30) {
            startBurn();
          }
        }
        if (neighborA != null) {
          if (neighborA.getLife() <= 5) {
            neighborA = null;
          } else if (neighborA.getLife() <= 30) {
            startBurn();
          }
        }
        if (neighborQ != null) {
          if (neighborQ.getLife() <= 5) {
            neighborQ = null;
          }
        }
      }
    }
  }
  
  void updateDrag() {
    // Drag
    if (dragOn) {
      if (neighborA != null && neighborW != null && neighborQ != null) {
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
        if (windOn) {
          dragVelocityVector.addV(windVector);
        }
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
        if (windOn) {
          dragVelocityVector.addV(windVector);
        }
        
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

// Used to sort the particles in order of z for
// textured particles to not have black boxes and
// since particles are drawn from back to front,
// no objects are hidden.
class SortByZ implements Comparator<Particle> {
  public int compare(Particle a, Particle b) {
    if (a.getZ() < b.getZ()) {
      return -1;
    } else if (a.getZ() > b.getZ()) {
      return 1;
    } else {
      return 0;
    }
  }
}

void drawFireParticles() {
  /*
  float[] camPos = cam.getPosition();
  Vector camVector = new Vector(camPos[0], camPos[1], camPos[2]);
  Collections.sort(particles, new SortByZ()); // Sorts particles
  
  for (int i = 0; i < particles.size(); i++) {
    float x = particles.get(i).getX();
    float y = particles.get(i).getY();
    float z = particles.get(i).getZ();
    Vector pVector = new Vector(x,y,z);
    Vector camDis = camVector.d(pVector);
    float yRot = atan2(camDis.x,camDis.z);
    pushMatrix();
    beginShape();
    rotateY(yRot); // Rotates textures toward camera
    particles.get(i).selectTexture();
    tint(255, 44); // Adds transparency/alpha to particles/textures
    vertex(x, y, z, 0, 0);
    vertex(x+4, y, z, fire01.width, 0);
    vertex(x+4, y+4, z, fire01.width, fire01.height);
    vertex(x, y+4, z, 0, fire01.height);
    endShape();
    popMatrix();
  
    particles.get(i).update(dt); // updates life and physics
    // Removes dead particles
    if (particles.get(i).getLife() <= 0) {
      particles.remove(i);
    }
  }
  */
  for (int i = 0; i < particles.size(); i++) {
    float x = particles.get(i).getX();
    float y = particles.get(i).getY();
    float z = particles.get(i).getZ();

    int colorNum = particles.get(i).getColor();
    float life = particles.get(i).getLife();
    switch (colorNum) {
      case 0: stroke(170-(particles.get(i).getLife())*10);
              break;
      case 1: stroke(242,12+life*4,12+life*4);
              break;
      case 2: stroke(237,146-life*2,9);
              break;
      case 3: stroke(249,221-life*2,9);
              break;
    }
    point(x,y,z);
    noStroke();
    particles.get(i).update(dt); // updates life and physics
    // Removes dead particles
    if (particles.get(i).getLife() <= 0) {
      particles.remove(i);
    }
  }
  
}


// Class that handles particle's position, velocity, acceleration, life,
// physics, and textures.
class Particle {
  Vector center; // x,y,z
  Vector pos; // x,y,z
  Vector vel; // vx,vy,vz
  Vector acc; // ax,ay,az
  float life;
  
  // Default constructor for new fire particles
  // which sample ontop on the log in a bit of a 
  // square shape.
  Particle(Spring parentSpring) {
    center = new Vector (parentSpring.getPos().x,
                         parentSpring.getPos().y,
                         parentSpring.getPos().z);
    pos = new Vector(parentSpring.getPos().x + random(-1,1),
                     parentSpring.getPos().y + random(-2,1),
                     parentSpring.getPos().z + random(-1,1));
    vel = center.d(pos);
    vel.y -= 35;
    acc = new Vector(0,vel.y/10,0);
    life = 45;
  }
  // Returns particle's life
  float getLife() {
    return life;
  }
  // Returns particle's x coordinate
  float getX() {
   return pos.x;
  }
  // Returns particle's y coordinate
  float getY() {
    return pos.y;
  }
  // Returns particle's z coordinate
  float getZ() {
    return pos.z;
  }
  
  // Handles particle texture selection out of
  // the different choices depending on the distance
  // the particles are from the basepoint of the fire.
  // This is to give a better appearence of a fire in
  // which the white flames are near the bottom/center
  // orange flames spread out after white
  // red flames are generally on the outside/outline of
  // the fire
  void selectTexture() {
    Vector dist = pos.d(center);
    float mag = dist.magnitude();
    float xzMag = dist.xzMagnitude();
    if (mag < 10) {
      texture(fire01);
    } else if (mag < 15) {
      texture(fire02);
    } else if (mag < 26 && xzMag < 4) {
      texture(fire02);
    } else {
      texture(fire03);
    }
    
  }
  
  int getColor() {
    if (life < 10) {
      return 0;
    } else if (life < 20) {
      return 1;
    } else if (life < 30) {
      return 2;
    } else if (life < 40) {
      return 3;
    } else {
      return 4;
    }
  }
  // Handles the position, velocity, life, and acceleration of the particles
  // while adding in randomness to the particles to give a better appearence
  // of fire.
  void update(float dt) {
    // Handles velocity while adding some random movements.
    pos.x += (vel.x*dt*50)*random(1,1.2) + (dt*(1*random(-1,1)));
    pos.z += (vel.z*dt*50)*random(1,1.2) + (dt*(1*random(-1,1)));
    pos.y += (vel.y*dt*50)*0.90 + ((1/2)*acc.y*dt*dt) + ((0.05 * acc.y) * random(2));
    if (life < 10) {
      pos.y += (vel.y*pow(dt,random(0.2,0.4)));
    }
    vel.x = center.x - pos.x; // moves fire particles upward toward center
    vel.z = center.x - pos.z; // moves fire particles upward toward center
    // Gives a small chance of having a fire particle spark out of the
    // fire for a small bit to give off more depth to the fire and sparkyness
    
    if ((int) random(0,1000) > 995) {
      if (random(0,1) > 0.5) {
        pos.x += ((random(1,1)));
      } else {
        pos.x -= ((random(1,1)));
      }
      if (random(0,1) > 0.5) {
        pos.z += ((random(1,1)));
      } else {
        pos.z -= ((random(1,1)));
      }
    }
    if ((int) random(0,1000) > 995 && (life < 10)) {
      life--;
      pos.y += (vel.y*pow(dt,random(0.2,0.4)));
    }
    if ((int) random(0,1000) > 995 && (life < 10)) {
      pos.y += (vel.y*pow(dt,random(0.2,0.4)));
    }
    // Adds more speed to the particles near the end of their
    // life to add a more inward shape at the top of the fire
    
    if (life < 10) {
      if (abs(center.x - pos.x) > 3) {
        pos.x += (center.x - pos.x)*dt*random(2,3);
      }
      if (abs(center.z - pos.z) > 3) {
        pos.z += (center.x - pos.x)*dt*random(2,3);
      }
    }
    
    life--;
  }
}
