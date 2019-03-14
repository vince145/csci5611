// fire particle system by Matthew Vincent, vince145
// for CSCI 5611 at the University of Minnesota Twin Cities
//
//
// PeasyCam 3D user interactive camera library is used.
// The PeasyCam library was made by Jonathan Feinberg
// http://mrfeinberg.com/peasycam/
//
// Code for drawing cylinders from Jan Vantomme
// http://vormplus.be/blog/article/drawing-a-cylinder-with-processing
// Cylinders were used as decorative shapes to appear as
// wooden logs in the wooden raft that is on fire.
//
// Code for update frequency, sampling space, general setup
// for particle systems, and textures adapted from
// Stephen Guy's lectures.
//
//
//////////////////////////////////////////////////////////////////
// TODO: 
//
//   -Add more realistic lighting to the fire to make it more
//    appealing.
//   -Add more realistic water around the raft.
//   -Add better textures to maek the fire look nicer.
//   -Adjust fire physics to make it more robust
//   -Add more functionality to the vector class for dot product,
//    cross product, and more for future use.
//
//////////////////////////////////////////////////////////////////

import peasy.*;
import java.util.*;


// Setting up global variables and classes to be used in
// the draw function.
PeasyCam cam; // Main instance of PeasyCam used for program
int particleLimit = 100000;
ArrayList<Particle> particles = new ArrayList<Particle>();
float x;
float y;
float z;
float xStart = 0;
float yStart = 0;
float zStart = 0;
PImage fire01;
PImage fire02;
PImage fire03;
float dt = 0.01;
SortByZ particleSorterZ;

void setup() {
  particleSorterZ = new SortByZ();
  size(800, 600, P3D);
  // Setup PeasyCam
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(800);
  // Load textures
  fire01 = loadImage("fireT01.png");
  fire02 = loadImage("fireT02.png");
  fire03 = loadImage("fireT03.png");
  noStroke();
}

void draw() {
  // Setup lights to make the textures not
  // have shadows on them from behind.
  lights();
  directionalLight(255,255,255,-100,-90,0);
  directionalLight(255,255,255,100,-90,0);
  directionalLight(255,255,255,0,-90,100);
  directionalLight(255,255,255,0,-90,-100);
  background(226, 237, 255); // Blue sky background
  drawFloor(); // Draws seafloor
  drawWood(1); // Draws wooden raft
  noFill();
  
  // Adds random amount of particles to fire to give
  // more realistic fire look, less boxy.
  for (int i = 0; i<(int) random(20,30); i++) {
    particles.add(new Particle());
  }
  drawFireParticles();

  text("Frame rate: " + int(frameRate), -200, -150);
  text("# of Particles: " + particles.size(), -200, -100);
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

// Draws a seafloor
void drawFloor() {
  pushMatrix();
  noStroke();
  fill(66,134,244);
  translate(0,21,0);
  box(1000,-10,1000);
  popMatrix();
}

// Draws a 
void drawWood(int shape) {
  pushMatrix();
  noStroke();
  fill(175,102,45);
  if (shape == 0) {
    translate(-0,20,0);
    drawCylinder(10,10,60);
    translate(20,0,0);
    drawCylinder(10, 10, 60);
    translate(-40,0,0);
    drawCylinder(10,10,60);
  } else if (shape == 1) {
    translate(-3,15,0);
    drawCylinder(10,5,30);
    translate(-10,0,0);
    drawCylinder(10,5,30);
    translate(20,0,0);
    drawCylinder(10,5,30);
    translate(10,0,0);
    drawCylinder(10,5,30);
    
  }
  popMatrix();
}
  
// from http://vormplus.be/blog/article/drawing-a-cylinder-with-processing
void drawCylinder(int sides, float r, float h) {
  pushMatrix();
  float angle = 360 / sides;
  float halfHeight = h/2;
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos(radians(i*angle)) * r;
    float y = sin(radians(i*angle)) * r;
    vertex(x,y, -halfHeight);
  }
  endShape(CLOSE);
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos(radians(i*angle)) * r;
    float y = sin(radians(i*angle)) * r;
    vertex(x,y, halfHeight);
  }
  endShape(CLOSE);
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides+1; i++) {
    float x = cos(radians(i*angle)) * r;
    float y = sin(radians(i*angle)) * r;
    vertex(x,y, halfHeight);
    vertex(x,y,-halfHeight);
  }
  endShape(CLOSE);
  popMatrix();
}

// Draw function for fire particle system handling
// particle textures, particle rotations, particle shapes,
// generation, and death.
void drawFireParticles() {
  float[] camPos = cam.getPosition();
  Vector camVector = new Vector(camPos[0], camPos[1], camPos[2]);
  Collections.sort(particles, new SortByZ()); // Sorts particles
  for (int i = 0; i < particles.size(); i++) {
    x = particles.get(i).getX();
    y = particles.get(i).getY();
    z = particles.get(i).getZ();
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
  Particle() {
    center = new Vector(0,5,0);
    pos = new Vector(center.x + random(-15,15),
                     center.y + random(-2, 5),
                     center.z + random(-15,15));
    vel = center.d(pos);
    vel.y -= 35;
    acc = new Vector(0,vel.y/10,0);
    life = 75;
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
  
  // Handles the position, velocity, life, and acceleration of the particles
  // while adding in randomness to the particles to give a better appearence
  // of fire.
  void update(float dt) {
    // Handles velocity while adding some random movements.
    pos.x += (vel.x*dt)*random(1,1.5) + (dt*(1*random(-2,2)));
    pos.z += (vel.z*dt)*random(1,1.5) + (dt*(1*random(-2,2)));
    pos.y += (vel.y*dt)*0.90 + ((1/2)*acc.y*dt*dt) + ((0.05 * acc.y) * random(2));
    vel.x = center.x - pos.x; // moves fire particles upward toward center
    vel.z = center.x - pos.z; // moves fire particles upward toward center
    // Gives a small chance of having a fire particle spark out of the
    // fire for a small bit to give off more depth to the fire and sparkyness
    if ((int) random(0,1000) > 995) {
      if (random(0,1) > 0.5) {
        pos.x += ((random(1,5)));
      } else {
        pos.x -= ((random(1,5)));
      }
      if (random(0,1) > 0.5) {
        pos.z += ((random(1,5)));
      } else {
        pos.z -= ((random(1,5)));
      }
    }
    // Adds more speed to the particles near the end of their
    // life to add a more inward shape at the top of the fire
    if (life < 20) {
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
