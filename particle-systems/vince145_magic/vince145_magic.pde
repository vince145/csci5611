// magic barrier particle system by Matthew Vincent, vince145
// for CSCI 5611 at the University of Minnesota Twin Cities
//
//
// PeasyCam 3D user interactive camera library is used.
// The PeasyCam library was made by Jonathan Feinberg
// http://mrfeinberg.com/peasycam/
//
// RGB rainbow adapted from Jim Bumgardner and his
// tutorial on how to cycle colors using sin waves.
// The RGB rainbow was adapted with the lifecycle of
// the magic barrier/sphere's particles.
// https://krazydad.com/tutorials/makecolors.php
//
// Physics code for water collision with spheres, update
// frequency, sampling spheres, and general setup
// for particle systems adapted from Stephen Guy's lectures.
//
//
//////////////////////////////////////////////////////////////////
// TODO: 
//
//   - Add water particle collision with sphere dropping
//   - Add better water particle collision with
//     good wizard.
//   - Add functionality to rotate the evil wizard by user input
//   - Add bounds to the evil wizard's movement preventing movement
//     outside of grass floor and going onto brick floor.
//   - Update water movement physics / normalization
//   - Add vector class
//   - Add movement of particles in sphere/barrier state to look
//     like ribbons moving along the surface area of sphere. Add
//     sampling restrictions to sphere / hemisphere to do this.
//   - Add color gradient that isn't dependent on particle life
//     but rather the position of the particles to make rainbow
//     waves or rainbow ribbons
//
//////////////////////////////////////////////////////////////////

import peasy.*;
import java.util.*;

// Setting up global variables and classes to be used in
// the draw function.
PeasyCam cam; // Main instance of PeasyCam used for program
float xStart = 0;
float yStart = 0;
float zStart = 0;
float floorY = 200;
float dt = 0.01;
int keyPressCooldown;
boolean keyPressReady;
Shape magicSphere = new Shape(0);
Shape water = new Shape(5);
EvilWizard badGuy = new EvilWizard();

void setup() {
  size(800, 600, P3D);
  // Setup PeasyCam
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(0);
  cam.setMaximumDistance(1000);
  textSize(32);
}


// Lights, background, floor, the good and evil wizard,
// and multiple particle systems are drawn to simulate
// a sort of wizard battle. The good wizard is able to
// create a magical sphere in which he can drop to the ground
// to make a barrier which protects him from the evil wizard's
// ability to shoot a stream of water particles.
//
// Pressing 1 initates a transition for the good wizard's
// magic sphere/barrier particle system.
//
// Pressing space generates a stream of particles for the
// evil wizard's water particle system that flies
// towards the good wizard.
//
// The evil wizard is able to be moved around by pressing the
// w, a, s, d keys in the direction associated with the starting
// direction of the PeasyCam.
//
void draw() {
  lights();
  background(0, 0, 0); // Black background
  drawFloor(); // Draws a large grass floor with center brick square.
  drawWizard(magicSphere.getShape()); // Draws the good wizard model
  badGuy.drawEvilWizard(); // Draws the evil wizard model
  stroke(255);
  magicSphere.drawShape(dt); // Draws the good wizard's magic sphere/barrier
  water.drawShape(dt); // Draws the evil wizard's water stream
  // Code segment below handles user input
  // Handles user input to generate good wizard's particle system
  if (keyPressed == true && key == '1' && keyPressReady) {
    magicSphere.transition();
    keyPressCooldown = 10;
    keyPressReady = false;
  }
  // Restricts the user from rapidly transitioning
  // between the magic sphere/barrier while allowing
  // some particles to generate before transitioning.
  if (keyPressCooldown == 0) {
    keyPressReady = true;
  } else {
    keyPressCooldown--;
  }
  // Handles user input to generate the evil wizard's particle system
  // and the evil wizard's movement around the floor.
  if (keyPressed == true && key == 32) {
    water.addWater();
  } else if (keyPressed == true) {
    badGuy.move(key);
  }
  // Displays total number of particles used in particle systems
  // and the frame rate in the sketch.
  int PC = magicSphere.getParticleCount() + water.getParticleCount();
  text("Frame rate: " + int(frameRate), -200, -150);
  text("# of Particles: " + PC, -200, -100, 0);
}


// Function used to draw a grass floor with
// a center brick platform using push/pop
// matrix to avoid translations/fills
// affecting other parts of the sketch
void drawFloor() {
  pushMatrix();
  noStroke();
  translate(0,200,0);
  fill(33,186,51); // Green
  box(1500,-5,1500); // Grass floor
  fill(255,100,100); // Brownish
  box(500,-10,500); // Brick floor
  popMatrix();
}

// Function used to draw the good wizard
// with shifting eye colors based on the
// good wizard's particle system's current
// state. Developed using push/pop matrix
// to avoid transitions/fills affecting
// other parts of the sketch
void drawWizard(int state) {
  pushMatrix();
  noStroke();
  translate(10,190,-100);
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

// Class used to handle the evil wizard's
// model drawing and movement while also
// storing its position as a starting
// point for water particle system.
class EvilWizard {
  float x;
  float y;
  float z;
  
  EvilWizard() {
    x = 0;
    y = 0;
    z = 500;
  }
  
  float getX() {
    return x;
  }
  float getY() {
    return y;
  }
  float getZ() {
    return z;
  }
  // Takes keyboard input to move the model
  void move(char direction) {
    switch (direction) {
      case 'w': z-=3;
              break;
      case 's': z+=3;
              break;
      case 'd': x+=3;
              break;
      case 'a': x-=3;
              break;
      default:
              break;
    }
  }
  // Draws evil wizard model using pop/push matrix
  void drawEvilWizard() {
    pushMatrix();
    noStroke();
    translate(x,y+190,z);
    fill(255);
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
    fill(255,0,0);
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

// Class used to handle individual particles
// in the particle system and their physics,
// color, generation, sampling, life, and updates.
class Particle {
  float x; // x pos on coordinate sys
  float y; // y pos on coordinate sys
  float z; // z pos on coordinate sys
  float vx; // velocity in x axis
  float vy; // velocity in y axis
  float vz; // velocity in z axis
  float a; // acceleration in y axis
  float life; // lifetime counter for particle
  float[] rgb; // contains hexadecimal rgb values for particles
  float t; 
  
  // Default construction of a particle for sampling a white 
  // sphere at the start location specified globally.
  Particle() {
    rgb = new float[3];
    for (int i = 0; i<3; i++) {
      rgb[i] = 255;
    }
    float r = 50;
    float x1 = random(-1,1);
    float x2 = random(-1,1);
    x = xStart + r*x1*sqrt(1-(x1*x1)-(x2*x2));
    y = yStart + r*x2*sqrt(1-(x1*x1)-(x2*x2));
    z = zStart + (r - r*((x1*x1)+(x2*x2)));
    vx = 0;
    vy = 0;
    vz = 0;
    a = 0;
    life = 50;
  }
  
  // Primary construction function for a particle that
  // constructs a particle based on shapeType specified
  // allowing for different characteristics to take place.
  // shapeType 0 = no shape formed for particle system
  // shapeType 1 = magic sphere formed for particle system
  // shapeType 2 = magic barrier formed for particle system
  // shapeType 3 = transition state between magic sphere
  //               and magic barrier shapes
  // shapeType 4 = magic barrier decay phase allowing particles
  //               to die out and not generate new ones.
  // shapeType 5 = spherical sampling for water particle system
  //               that arcs toward the good wizard
  Particle(float shapeType) {
    if (shapeType == 1) { // Sphere
      life = 50;
      rgb = new float[3];
      for (int i = 0; i<3; i++) {
        rgb[i] = 255;
      }
      // Spherical sampling math, generates surface
      float r = 50;
      float x1 = random(-1,1);
      float x2 = random(-1,1);
      x = xStart + r*(2*x1*sqrt(1-(x1*x1)-(x2*x2)));
      y = yStart + r*(2*x2*sqrt(1-(x1*x1)-(x2*x2)));
      z = zStart + r*((1 - 2*((x1*x1)+(x2*x2))));
      // Removes particles generated outside of sphere
      if (((x*x)+(y*y)) < 1) {
        life = 0;
      }
      // Sets particle's initial velocities and acceleration
      vx = 0;
      vy = 0;
      vz = 0;
      a = 0;
    } else if (shapeType == 2) { // Barrier
      life = 50;
      rgb = new float[3];
      for (int i = 0; i<3; i++) {
        rgb[i] = 0;
      }
      // Spherical sampling math, generates surface
      float r = 250;
      float x1 = random(-1,1);
      float x2 = random(-1,1);
      x = xStart + r*(2*x1*sqrt(1-(x1*x1)-(x2*x2)));
      y = 200 + r*(2*x2*sqrt(1-(x1*x1)-(x2*x2)));
      z = zStart + r*((1 - 2*((x1*x1)+(x2*x2))));
      // Removes particles below floor to construct
      // hemisphere / barrier shape.
      if (y >= floorY) {
        life = -5;
      }
      // Sets particle's initial velocities and acceleration
      vx = 0;
      vy = 0;
      vz = 0;
      a = 0;
    } else if (shapeType == 5) { // Water
      life = 120; // longer life for more bouncing
      // Spherical sampling math
      float r = 20;
      float x1 = random(-1,1);
      float x2 = random(-1,1);
      x = badGuy.getX() + r*(2*x1*sqrt(1-(x1*x1)-(x2*x2)));
      y = badGuy.getY() + r*(2*x2*sqrt(1-(x1*x1)-(x2*x2)));
      z = badGuy.getZ() + r*((1 - 2*((x1*x1)+(x2*x2))));
      // Sets particle's initial velocities and acceleration
      vx = (10-x);
      vz = (-100 - z);
      vy = (90 - y);
      a = 9.8;
    }
  }
  // Returns life of the particle remaining
  float getLife() {
    return life;
  }
  // Returns x coordinate of the particle
  float getX() {
   return x;
  }
  // Returns y coordinate of the particle
  float getY() {
    return y;
  }
  // Returns z coordinate of the particle
  float getZ() {
    return z;
  }
  // Returns the average velocity of the
  // particle to check if it is stationary
  // at the edge of the barrier after transitiong
  // from the sphere
  float getVAverage() {
    return ((abs(vz)+abs(vx)+abs(vy))/3);
  }
  // Sets the stroke of the particle to be a rainbow
  // color depending on the life remaining in the particle
  // by using sin waves and differing phases for x, y, and z
  // with hexadecimal rgb.
  void setParticleColor() {
    stroke(rgb[0], rgb[1], rgb[2]);
    rgb[0] = (sin(0.3*(life%50))*127+128)%255;
    rgb[1] = (sin(0.3*(life%50)+2)*127+128)%255;
    rgb[2] = (sin(0.3*(life%50)+4)*127+128)%255;
  }
  // Adjusts the particle's velocities in shape 2, the transition
  // between the sphere and barrier. The new velocities should
  // start out with the sphere dropping to the ground.
  void startTransition(float newVX, float newVY, float newVZ) {
    vx = newVX;
    vy = newVY;
    vz = newVZ;
    a = 9.8;
  }
  // Adjusts the particle's physics in shape 2, the transition
  // between the sphere and barrier. The positions are updated
  // with the time step and velocity until the particles
  // reach the radius of the hemisphere. The particles are
  // setup to sit still after they have reached the edge of the
  // barrier for the transition to finish. Also handles collisions
  // with the floor to initiate explosion of particles.
  void transitionUpdate(float dt) {
    // Updates particle's position
    x += (dt * vx);
    z += (dt * vz);
    y += (dt * vy) + ((1/2)*a*dt*dt);
    // Updates particle's velocity
    vy += a*dt;
    // Handles floor collision during which
    // the particle is assigned random x, y, and z
    // velocities dependant on the sphere's falling
    // velocity. The random velocities assigned should
    // give the appearence of an explosion sending the
    // particles to the edge of the barriers.
    if (y >= floorY) {
      y = floorY - 5;
      if (random(0,1) > 0.5) {
        vx = random(-0.5*vy,vy*1.5);
      } else {
        vx = -random(-0.5*vy,vy*1.5);
      }
      if (random(0,1) > 0.5) {
        vz = random(-0.5*vy,vy*1.5);
      } else {
        vz = -random(-0.5*vy,vy*1.5);
      }
      vy = -random(0,vy*1.5);
    }
    // Handles when particles reach hemisphere surface
    // and sets them to rest.
    if (((x*x)+((y-200)*(y-200))+(z*z)) >= (250*250)) {
      vx = 0;
      vz = 0;
      vy = 0;
      a = 0;
    }
    // Handles particle life during transition.
    // Since the same particles are used from the sphere
    // with no new generated particles during the explosion
    // the life counts down to preserve color changing.
    // The life is reset to 50 to continue the color cycle
    // of the particles during transitioning.
    life--;
    if (life == 0) {
      life = 50;
    }
  }
   
  // Handles particle's life cycle.
  void update() {
    life--;
  }
  
  // Handles the physics of the water particle system, including
  // particle collision with the barrier and floor. SHAPE 5
  void updateWater(float dt) {
    // Handles updating the life, position, and velocity of water particles.
    life--;
    x += (vx * dt);
    y += (vy * dt) + (1/2)*a*dt*dt;
    z += (vz * dt);
    vy += (a * dt) * 80;
    
    // Handles water particle collision with the floor
    // bouncing them off with less speed.
    if (y >= 195) {
      y = 190;
      vy = vy * -0.7;
    }
    // Handles water particle collision with barrier.
    int barrierState = magicSphere.getShape();
    if (barrierState == 2 || barrierState == 4) {
      float dist = sqrt(pow((x-0),2)+pow((y-200),2)+pow((z-0),2));
      if (dist < 250) {
        float[] normal = new float[]{x-0,y-200,z-0};
        for (int i = 0; i<3; i++) {
          normal[i] = normal[i] / dist;
        }
        x = 0 + normal[0]*250*1.05;
        y = 200 + normal[1]*250*1.05;
        z = 0 + normal[2]*250*1.05;
        if (x < 0) {
          vx = (vx + normal[0])*normal[0] * 0.7;
        } else {
          vx = -(vx + normal[0])*normal[0] * 0.7;
        }
        vy = -(vy + normal[1])*normal[1] * 0.7;
        if (z < 0) {
          vz = (vz + normal[2])*normal[2] * 0.7;
        } else {
          vz = -(vz + normal[2])*normal[2] * 0.7;
        }
      }
    }
    // Somewhat handles water particle collision with
    // good wizard
    if (abs(x) < 50 && z > -50 && z < -120) {
      life = -5;
    }
  }
    
}

// Class used to handle different particle systems,
// their drawing, and setting up transitions. Uses
// java's arraylist system to add new particles and
// remove them without leaving gaps in the arraylist
// for an effective particle system.
//
// Multiple particle systems are allowed for creation
// in which an int is associated with each one.
// shapeType 0 = no shape formed for particle system
// shapeType 1 = magic sphere formed for particle system
// shapeType 2 = magic barrier formed for particle system
// shapeType 3 = transition state between magic sphere
//               and magic barrier shapes
// shapeType 4 = magic barrier decay phase allowing particles
//               to die out and not generate new ones.
// shapeType 5 = spherical sampling for water particle system
//               that arcs toward the good wizard
class Shape {
  int shapeType; // Designates the type of particle system
  float x; // x center point for particle system
  float y; // y center point for particle system
  float z; // z center point for particle system
  ArrayList<Particle> particles = new ArrayList<Particle>();
  int particleCount; // int of total number of particles in system
  int particlesSitting; // number of particles at edge of barrier in transition
  int barrierDuration; // timer for how long the barrier should stay alive
  
  // General constructor for particle system setting the shapeType.
  Shape(int startingShape) {
    shapeType = startingShape;
    particleCount = 0;
    x = 0;
    y = 0;
    z = 0;
  }
  
  // Returns the current state of the particle system
  int getShape() {
    return shapeType;
  }
  
  // Sets the current state of the particle system
  void setShape(int newShape) {
    shapeType = newShape;
  }
  
  // Returns the number of particles in the system
  int getParticleCount() {
    return particleCount;
  }
  
  // Switch statement to draw the appropriate shape for
  // each different particle system.
  void drawShape(float dt) {
    switch (shapeType) {
      case 0: 
              break;
      case 1: drawSphere();
              break;
      case 2: drawBarrier();
              break;
      case 3: drawTransition(dt);
              break;
      case 4: drawBarrierRemoval();
              break;
      case 5: drawWater(dt);
              break;
      default:
              break;
    }
    //text("# of Particles: " + particleCount, -200, -100, 0);
    //text(str(particlesSitting), -200, -200, 0);
  }
  
  // Draw function for the sphere state of the good wizard's
  // magic.
  // PARTICLES GENERATE / DIE
  void drawSphere() {
    strokeWeight(3);
    // Generates new particles each frame
    for (int i = 0; i<200; i++) {
      particles.add(new Particle(1));
      particleCount++;
    }
    for (int i = 0; i < particleCount; i++) {
      // Draws each particle as a point
      particles.get(i).setParticleColor(); // rainbow color
      x = particles.get(i).getX();
      y = particles.get(i).getY();
      z = particles.get(i).getZ();
      point(particles.get(i).getX(),particles.get(i).getY(),particles.get(i).getZ());
      particles.get(i).update(); // updates life
      // Removes particles after they have died reaching 0 life.
      if (particles.get(i).getLife() <= 0) {
        particles.remove(i);
        particleCount--;
      }
    }
  }
  
  // Draw function for the barrier state of the good wizard's
  // magic.
  // PARTICLES GENERATE / DIE
  void drawBarrier() {
    strokeWeight(3);
    // Generates new particles each frame
    for (int i = 0; i<400; i++) {
      particles.add(new Particle(2));
      particleCount++;
    }
    for (int i = 0; i < particleCount; i++) {
      // Draws each particle as a point
      particles.get(i).setParticleColor(); // rainbow color
      x = particles.get(i).getX();
      y = particles.get(i).getY();
      z = particles.get(i).getZ();
      point(particles.get(i).getX(),particles.get(i).getY(),particles.get(i).getZ());
      particles.get(i).update(); // updates life
      // Removes particles after they have died reaching 0 life.
      if (particles.get(i).getLife() <= 0) {
        particles.remove(i);
        particleCount--;
      }
    }
    // Handles the barrier's duration it stays up until
    // it disappers.
    barrierDuration--;
    if (barrierDuration <= 0) {
      shapeType = 4;
    }
  }
  
  // Draw function for the transition from sphere to barrier for
  // the good wizard's magic. 
  // PARTICLES DO NOT DIE / GENERATE. PARTICLES MOVE
  void drawTransition(float dt) {
    strokeWeight(3);
    particlesSitting = 0;
    for (int i = 0; i < particleCount; i++) {
      // Draws each particle as a point
      particles.get(i).setParticleColor(); // rainbow color
      x = particles.get(i).getX();
      y = particles.get(i).getY();
      z = particles.get(i).getY();
      point(particles.get(i).getX(),particles.get(i).getY(),particles.get(i).getZ());
      particles.get(i).transitionUpdate(dt); // physics
      // Counts if particle is not moving
      if (particles.get(i).getVAverage() < 100) {
        particlesSitting++;
      }
    }
    // Handles the transition from sphere to barrier by
    // counting how many particles are sitting at the edge
    // of the hemisphere.
    if (particlesSitting >= (0.3 * particleCount)) {
      barrierDuration = 300;
      shapeType = 2;
    }
  }
  
  // Draw function for the barrier state of the wizard's
  // magic allowing the particles to die.
  // PARTICLES DO NOT GENERATE, PARTICLES DIE
  void drawBarrierRemoval() {
    strokeWeight(3);
    for (int i = 0; i < particleCount; i++) {
      // Draws each particle as a point
      particles.get(i).setParticleColor(); // rainbow color
      x = particles.get(i).getX();
      y = particles.get(i).getY();
      z = particles.get(i).getZ();
      point(particles.get(i).getX(),particles.get(i).getY(),particles.get(i).getZ());
      particles.get(i).update(); // updates life
      // Handles death of particles when their life reaches 0
      if (particles.get(i).getLife() <= 0) {
        particles.remove(i);
        particleCount--;
      }
    }
    // Handles transition to no particle system active
    // after all particles from barrier die.
    if (particleCount == 0) {
      shapeType = 0;
    }
  }
  
  // Draws water particle system for evil wizard's magic
  // DOES NOT GENERATE PARTICLES. PARTICLES DIE / MOVE
  void drawWater(float dt) {
    strokeWeight(2);
    stroke(0,0,255); // blue
    for (int i = 0; i < particleCount; i++) {
      // Draws each particle as a point
      x = particles.get(i).getX();
      y = particles.get(i).getY();
      z = particles.get(i).getZ();
      point(particles.get(i).getX(),particles.get(i).getY(),particles.get(i).getZ());
      particles.get(i).updateWater(dt);
      // Handles particle death when their life reaches 0
      if (particles.get(i).getLife() <= 0) {
        particles.remove(i);
        particleCount--;
      }
    }
  }
  // Function that adds particles to the water particle
  // system after an user presses space.
  // GENERATES PARTICLES
  void addWater() {
    for (int i = 0; i<50; i++) {
      particles.add(new Particle(5));
      particleCount++;
    }
  }
  
  // Function that initiates transition from no sphere,
  // to sphere, or sphere to transitioning to dome.
  // User input's 1 to cast good wizard's spell in which
  // this function handles that input in the particle system.
  void transition() {
    switch (shapeType) {
      case 0: shapeType = 1;
              break;
      case 1: shapeType = 3;
              for (int i = 0; i < particleCount; i++) {
                particles.get(i).startTransition(0.0, 500.0, 0.0);
              }
              break;
      case 2: 
              break;
      case 3: 
              break;
      case 4:
              break;
      case 5:
              break;
      default:
              break;
    }
  }
}
  
