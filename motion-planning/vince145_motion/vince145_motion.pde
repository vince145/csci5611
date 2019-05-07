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
