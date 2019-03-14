// horizontal_bouncing_ball by Matthew Vincent, vince145
// for CSCI 5611 at the University of Minnesota Twin Cities
// Physics code and update frequency adapted from Stephen Guy's ball physics.
float radius = 40;
float floor = 400; float wall = 400;
float y_velocity = 0; float y_position = 100;
float x_velocity = 60; float x_position = 100;
boolean colorShift = false;
boolean collision = false;
float r = 255; float b = 255; float g = 255;

void setup() {
  size(400, 400, P3D);
}

void shiftColor() {
  if (abs(x_velocity) > 5) {
    r = random(255);
    g = random(255);
    b = random(255);
  }
}

void physics(float dt) {
  float acceleration = 9.8; // applies gravity to the ball
  
  // updates the y position of the ball and applies
  // an friction sort of element to the ball
  // when it hits the bottom of the window.
  y_velocity = y_velocity + (acceleration * dt);
  y_position = y_position + (y_velocity * dt) +(acceleration * 0.5 * dt * dt);
  if (y_position + (radius * 1.07) > floor) {
    // radius * 1.05 is added to make the ball not appear as it is
    // falling into the floor too much as it approaches 0 y velocity.
    // The small bit of ball below the floor gives the ball a kind of squished
    // feel. There is limitations to this design if the radius of the ball is
    // massively increased, then the ball would appear as it bounces too early or
    // is floating a bit above the floor.
    y_position = floor - (radius * 1.07);
    y_velocity *= -.95;
    x_velocity *= .95;
    if (colorShift) {
      shiftColor();
    }
  }
  
  // updates the x position of the ball and applies
  // an friction sort of element to the ball
  // when it hits the left and right side of the
  // window.
  x_position = x_position + x_velocity * dt;
  if (x_position + radius > wall) {
    x_position = wall - radius;
    x_velocity *= -.95;
    if (colorShift) {
      shiftColor();
    }
  } else if (x_position - radius < 0) {
    x_position = radius;
    x_velocity *= -.95;
    if (colorShift) {
      shiftColor();
    }
  }
}

void draw() {
  lights(); noStroke();
  background(0, 0, 0); // Black background
  
  // Resets ball to starting state
  if (keyPressed == true && key == 32) {
    y_velocity = 0;
    y_position = 100;
    x_velocity = 60;
    x_position = 100;
  } else if (keyPressed == true && key == '1'
             && colorShift) {
    colorShift = false;
  } else if (keyPressed == true && key == '2'
             && !colorShift) {
    colorShift = true;
    r = 255;
    g = 255;
    b = 255;
  }
  
  // Draws ball
  fill(r,g,b);
  physics(.15);
  translate(x_position,y_position,0);
  sphere(radius);
}
