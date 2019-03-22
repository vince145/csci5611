// vince145_PRM_motionPlanning by Matthew Vincent, vince145
// for CSCI 5611 at the University of Minnesota Twin Cities
//
//
//
//////////////////////////////////////////////////////////////////
// TODO: 
//
//   - 
//
//////////////////////////////////////////////////////////////////

import java.util.Collections;

boolean sampleRandomTiles = true;
boolean continuousPathFinding = false;
boolean debug = false;
boolean extraObstacles = false;
boolean middleObstacle = true;
boolean rayCollision = false;
boolean drawAllPaths = true;

float boardSize = 400;
float edgeMaxDistance = boardSize/10; // boardSize/10
int numberOfSampledPoints = 1000;

float w = 800;
float h = 600;
float dt = 0.001;
int PRMTimer = 0;

Environment board = new Environment(w*0.5, h*0.5, boardSize);

void setup() {
  size(800, 600, P3D);
  fill(255);
  board.PRM();
}

void draw() {
  lights();
  background(0, 0, 0);
  board.drawEnvironment();
  
  if (continuousPathFinding) {
    if (PRMTimer == 50) {
      PRMTimer = 0;
      board.PRM();
    } else {
      PRMTimer++;
    }
  }
  if (keyPressed == true) {
    handleInput(key);
  }
  
}

void handleInput(char input) {
  switch (input) {
    case ' ': board = new Environment(w*0.5, h*0.5, boardSize);
              board.PRM();
              break;
    case '1': middleObstacle = true;
              extraObstacles = false;
              board = new Environment(w*0.5, h*0.5, boardSize);
              board.PRM();
              break;
    case '2': middleObstacle = true;
              extraObstacles = true;
              board = new Environment(w*0.5, h*0.5, boardSize);
              board.PRM();
              break;
    default:
              break;
  }
}

public class Vector {
  float x;
  float y;
  
  Vector(float newX, float newY) {
    x = newX;
    y = newY;
  }
  
  void scaler(float scalerValue) {
    x = x * scalerValue;
    y = y * scalerValue;
  }
  
  Vector scalerNC(float scalerValue) {
    Vector resultVector = new Vector(x*scalerValue, y*scalerValue);
    return resultVector;
  }
  
  void addV(Vector addVector) {
    x = x + addVector.x;
    y = y + addVector.y;
  }
  
  void divide(float divideValue) {
    if (divideValue != 0) {
      x = (float) x / (float) divideValue;
      y = (float) y / (float) divideValue;
    }
  }
  
  Vector divideNC(float scalerValue) {
    if (scalerValue != 0) {
      float newX = ((float) x)/ (float) scalerValue;
      float newY = ((float) y)/ (float) scalerValue;
      Vector resultVector = new Vector(newX, newY);
      return resultVector;
    } else {
      Vector resultVector = new Vector(x, y);
      return resultVector;
    }
  }
  
  float magnitude() {
    return sqrt((float) (((x*x)+(y*y))));
  }
  
  void normalizeV() {
    float mag = sqrt((float) (x*x)+(y*y));
    if (mag != 0) {
      x = x/(mag);
      y = y/(mag);
    }
  }
  // Calculates distance from point startV to .this point.
  Vector d(Vector startV) {
    Vector distanceVector = new Vector(x-startV.x, y-startV.y);
    return distanceVector;
  }
  
  float dotProd(Vector startV) {
    float dotProduct = (x * startV.x) + (y * startV.y);
    return dotProduct;
  }
  /*
  Vector crossProd(Vector b) {
    Vector resultVector = new Vector((y)*(b.z)-(z)*(b.y),
                                     -1*((x)*(b.z)-(z)*(b.x)),
                                     (x)*(b.y)-(y)*(b.x));
    return resultVector;
  }
  */
  void reset() {
    x = 0;
    y = 0;
  }
}


class Environment {
  ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
  Tile[][] tiles;
  CircleBoy circleBoy;
  float size;
  float centerX;
  float centerY;
  ArrayList<Milestone> circleBoyPath = new ArrayList<Milestone>();
  ArrayList<Edge> dEdges = new ArrayList<Edge>();
  
  Environment(float startX, float startY, float startSize) {
    centerX = startX;
    centerY = startY;
    size = startSize;
    
    // Setup agent
    circleBoy = new CircleBoy(centerX-(size/2)+(size/40),centerY+(size/2)-(size/40), size/40);
    
    // Set Obstacles
    if (middleObstacle) {
      obstacles.add(new Obstacle(centerX, centerY, size/5));
    }
    if (extraObstacles) {
      obstacles.add(new Obstacle(centerX-(size/2)+(size/20), centerY-(size/2)+(size/20), size/10));
      obstacles.add(new Obstacle(centerX-(size/2)+(size/20)*2*(2), centerY-(size/2)+(size/20)*2*(1), size/10));
      obstacles.add(new Obstacle(centerX-(size/2)+(size/20)*2*(2), centerY-(size/2)+(size/20)*2*(2), size/10));
      obstacles.add(new Obstacle(centerX-(size/2)+(size/20)*2*(3.5), centerY-(size/2)+(size/20)*1*(1), size/10));
      obstacles.add(new Obstacle(centerX-(size/2)+(size/20)*2*(3.5), centerY-(size/2)+(size/20)*2*(2), size/10));
      obstacles.add(new Obstacle(centerX-(size/2)+(size/20)*2*(3.5), centerY-(size/2)+(size/20)*2*(3), size/10));
    }
    
    // Setup default tiles
    int tileN = (int) size/10;
    tiles = new Tile[tileN][tileN];
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        tiles[i][j] = new Tile(i, j, 0, centerX-(size*0.5)+(i*size/20)+size/40, centerY-(size*0.5)+(j*size/20)+size/40);
      }
    }
    
    
    // Set obstacle tiles from collision with obstacles
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        for (int k = 0; k < obstacles.size(); k++) {
          float dist = abs((obstacles.get(k).getX() - tiles[i][j].getXR()));
          dist += abs((obstacles.get(k).getY() - tiles[i][j].getYR()));
          if (dist <= obstacles.get(k).getSize()/2) {
            tiles[i][j].setType(2);
          }
        }
      }
    }
    
    // Set goal tiles
    tiles[19][0].setType(1);
    
    // Set start tile
    tiles[0][19].setType(4);
  }
  
  void drawEnvironment() {
    // Draws Environment tiles
    fill(100,100,100);
    square(centerX-(size*0.5), centerY-(size*0.5), size);
    stroke(150,150,150);
    // Draw base layer of tiles
    /*
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        square(centerX-(size*0.5)+(i*size/20), centerY-(size*0.5)+(j*size/20), size/20);
      }
    }
    */
    
    // Draws all edges for testing purposes if turned on
    if (drawAllPaths) {
      stroke(200, 15);
      for (int i = 0; i < dEdges.size(); i++) {
        float Ax = dEdges.get(i).getA().getX();
        float Ay = dEdges.get(i).getA().getY();
        float Bx = dEdges.get(i).getB().getX();
        float By = dEdges.get(i).getB().getY();
        line (Ax, Ay, Bx, By);
      }
    }
    
    // Draw special tiles on top of base layer
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        int tileType = tiles[i][j].getType();
        switch (tileType) {
          case 0: 
                  break;
          case 1: stroke(255,255,0);
                  square(centerX-(size*0.5)+(i*size/20), centerY-(size*0.5)+(j*size/20), size/20);
                  break;
          case 2: stroke(255,0,0);
                  //square(centerX-(size*0.5)+(i*size/20), centerY-(size*0.5)+(j*size/20), size/20);
                  break;
          case 3: stroke(0,255,0);
                  square(centerX-(size*0.5)+(i*size/20), centerY-(size*0.5)+(j*size/20), size/20);
                  break;
          case 4: stroke(0,0,255);
                  square(centerX-(size*0.5)+(i*size/20), centerY-(size*0.5)+(j*size/20), size/20);
                  break;
          default:
                  break;
        }
      }
    }
    pushMatrix();
    translate(0,0,1);
    strokeWeight(5);
    for (int i = 0; i < circleBoyPath.size(); i++) {
        int milestoneType = circleBoyPath.get(i).getType();
        switch (milestoneType) {
          case 0: 
                  break;
          case 1: stroke(255,255,0);
                  point(circleBoyPath.get(i).getX(), circleBoyPath.get(i).getY());
                  break;
          case 2: stroke(255,0,0);
                  point(circleBoyPath.get(i).getX(), circleBoyPath.get(i).getY());
                  break;
          case 3: stroke(0,255,0);
                  point(circleBoyPath.get(i).getX(), circleBoyPath.get(i).getY());
                  break;
          case 4: stroke(0,0,255);
                  point(circleBoyPath.get(i).getX(), circleBoyPath.get(i).getY());
                  break;
          default:
                  break;
        }
    }
    popMatrix();
    strokeWeight(1);
    // Outline of Environment
    stroke(255,0,0);
    line(centerX-(size*0.5), centerY-(size*0.5), centerX+(size*0.5), centerY-(size*0.5));
    line(centerX+(size*0.5), centerY-(size*0.5), centerX+(size*0.5), centerY+(size*0.5));
    line(centerX+(size*0.5), centerY+(size*0.5), centerX-(size*0.5), centerY+(size*0.5));
    line(centerX-(size*0.5), centerY+(size*0.5), centerX-(size*0.5), centerY-(size*0.5));
    for (int i = 0; i < obstacles.size(); i++) {
      obstacles.get(i).drawObstacle();
    }
    pushMatrix();
    translate(0,0,2);
    circleBoy.update();
    circleBoy.drawCircleBoy();
    popMatrix();
    
    text("Frame rate: " + int(frameRate), centerX-(size*0.5), centerY+(size*0.5)+(size*0.05));
    

  }
  
  void setPathType(int milestoneIndex, int newType) {
    circleBoyPath.get(milestoneIndex).setType(newType);
  }
  
  ArrayList<Milestone> getPath() {
    return circleBoyPath;
  }
  
  
  void PRM() {
    
    ArrayList<Milestone> milestones = new ArrayList<Milestone>();
    ArrayList<Edge> paths = new ArrayList<Edge>();
    
    
    // Sample random points
    for (int i = 0; i < numberOfSampledPoints; i++) {
      // Randomly sample configurations
      float randomX =  random(centerX - size * 0.5, centerX + size * 0.5);
      float randomY =  random(centerY - size * 0.5, centerY + size * 0.5);
      // Test configurations for collisions
      if (obstacles.size() > 0) {
        boolean milestoneValid = true;
        for (int k = 0; k < obstacles.size() && milestoneValid; k++) {
          float dist = abs((randomX - obstacles.get(k).getX()));
          dist += abs((randomY - obstacles.get(k).getY()));
          if (dist < obstacles.get(k).getSize() * 0.7) {
            milestoneValid = false;
          }
        }
        if (milestoneValid) {
          milestones.add(new Milestone(randomX, randomY, 0));
        }
      } else {
        milestones.add(new Milestone(randomX, randomY, 0));
      }
    }
    milestones.add(new Milestone(circleBoy.getX(), circleBoy.getY(), 0));
    milestones.add(new Milestone(centerX-(size*0.5)+(19*size/20)+size/40, centerY-(size*0.5)+(0*size/20)+size/40, 1));
    
    if (debug) {
      println("milestones = " + milestones.size());
    }
    
    // Straight lines connect neighboring milestones
    for (int i = 0; i < milestones.size(); i++) {
      for (int j = 0; j < milestones.size(); j++) {
        float dist = abs((milestones.get(j).getX() - milestones.get(i).getX()));
        dist += abs((milestones.get(j).getY() - milestones.get(i).getY()));
        if (dist < edgeMaxDistance && dist > 0) {
          if (rayCollision) {
            //paths.add(new Edge(milestones.get(i), milestones.get(j), dist));
            // Ray - sphere intersection checks
            boolean addEdge = true;
            for (int k = 0; k < obstacles.size(); k++) {
              // A = origin tile
              // B = end tile
              // C = obstacle center point
              // r = sphere radius
              Vector tileA = new Vector(milestones.get(i).getX(), milestones.get(i).getY());
              Vector tileB = new Vector(milestones.get(j).getX(), milestones.get(j).getY());
              Vector edgeDirection = tileB.d(tileA);
              float edgeDirectionMag = edgeDirection.magnitude();
              edgeDirection.divide(edgeDirectionMag);
              Vector obstacleCenter = new Vector(obstacles.get(k).getX(), obstacles.get(k).getY());
              Vector oc = tileA.d(obstacleCenter);
              edgeDirection.scaler(2);
              float a = 1;
              float b = edgeDirection.dotProd(oc);
              float c = oc.dotProd(oc) - pow(obstacles.get(k).getSize(), 2);
              float discrim = b * b - 4*a*c;
              
              if (discrim < 0) {
                 //addEdge = false;
              }
            }
            if (addEdge) {
              paths.add(new Edge(milestones.get(i), milestones.get(j), dist));
            }
          } else {
            paths.add(new Edge(milestones.get(i), milestones.get(j), dist));
          }
        }

      }
    }
    if (debug) {
      println("paths = " + paths.size());
    }
    int circleBoyTile = 0;
    float minDist = 999999;
    
    // Finds the tile closest to the circleBoy
    for (int i = 0; i < milestones.size(); i++) {
      
      float dist = abs(milestones.get(i).getX() - circleBoy.getX());
      dist += abs(milestones.get(i).getY() - circleBoy.getY());
      
      /*
      if (debug) {
        println(dist);
      }
      */
      if (dist < minDist) {
        minDist = dist;
        circleBoyTile = i;
      }
    }
    if (debug) {
      println("circleboytile i = " + milestones.get(circleBoyTile).getX());
      println("circleboytile j = " + milestones.get(circleBoyTile).getY());
    }
    
    
    
    dijkstraResult djikstraR = dijkstra(milestones, paths, milestones.get(circleBoyTile));
    float closestGoalDist = 999999;
    int closestGoal = 0;
    
    
    for (int i = 0; i < milestones.size(); i++) {
      if (milestones.get(i).getType() == 1) {
        if (debug) {
          println("djikstraR.dist[" + i + "] = " + djikstraR.dist[i]);
        }
        if (djikstraR.dist[i] < closestGoalDist) {
          closestGoalDist = djikstraR.dist[i];
          closestGoal = i;
          if (debug) {
            println("goal added");
          }
        }
      }
    }
    
    if (debug) {
      for (int i = 0; i < milestones.size(); i++) {
        if (djikstraR.prev[i] != null) {
          println("djikstraR.dist[" + i + "] = " + djikstraR.dist[i] + "    currentI = " + (i/20) + ", currentJ = " + (i%20) + "    prevI = " + djikstraR.prev[i].getX() + ", prevJ = " + djikstraR.prev[i].getY());
        } else {
          println("djikstraR.dist[" + i + "] = " + djikstraR.dist[i] + "    NULL");
        }
      }
    }
    
    circleBoyPath.add(milestones.get(closestGoal));
    
    if (debug) {
      println("closest goal i = " + milestones.get(closestGoal).getX());
      println("closest goal j = " + milestones.get(closestGoal).getY());
    }
    if (sampleRandomTiles) {
      Milestone pathTile = milestones.get(circleBoyTile);
      if (djikstraR.prev[closestGoal] != null) {
        pathTile = djikstraR.prev[closestGoal];
      }
      while (pathTile != null) {
        circleBoyPath.add(pathTile);
        if (debug) {
          if (pathTile.getPrev() != null) {
            println("currentI = " + pathTile.getX() + " currentJ = " + pathTile.getY() + ",    prevI = " + pathTile.getPrev().getX() + " prevJ = " + pathTile.getPrev().getY());
          } else {
            println("currentI = " + pathTile.getX() + " currentJ = " + pathTile.getY() + ",   prev = NULL");
          }
        }
        pathTile = pathTile.getPrev();
      }
    }
    
    if (debug && !sampleRandomTiles) {
      if (djikstraR.prev[closestGoal] != null) {
        println("djikstraR.dist[" + closestGoal + "] = " + djikstraR.dist[closestGoal] + "    currentI = " + (closestGoal/20) + ", currentJ = " + (closestGoal%20) + "    prevI = " + djikstraR.prev[closestGoal].getX() + ", prevJ = " + djikstraR.prev[closestGoal].getY());
      } else {
        println("djikstraR.dist[" + closestGoal + "] = " + djikstraR.dist[closestGoal] + "    NULL");
      }
    }
    
    
    dEdges = paths;
    Collections.reverse(circleBoyPath);
  } 
  
}

class Edge {
  Milestone A;
  Milestone B;
  float cost;
  
  Edge(Milestone startA, Milestone startB, float startCost) {
    A = startA;
    B = startB;
    cost = startCost;
  }
  
  Milestone getA() {
    return A;
  }
  
  Milestone getB() {
    return B;
  }
  
  float getCost() {
    return cost;
  }
}

class Tile {
  int type;
  int x;
  int y;
  float xR;
  float yR;
  Tile prev;
  
  Tile(int startX, int startY, int startType, float startXR, float startYR) {
    type = startType;
    x = startX;
    y = startY;
    xR = startXR;
    yR = startYR;
  }
  
  void setType(int newType) {
    type = newType;
  }
  
  int getType() {
    return type;
  }
  
  int getX() {
    return x;
  }
  
  int getY() {
    return y;
  }
  
  float getXR() {
    return xR;
  }
  float getYR() {
    return yR;
  }
  void setPrev(Tile newPrev) {
    prev = newPrev;
  }
  Tile getPrev() {
    return prev;
  }
  boolean compare(Tile A) {
    if (A == null) {
      return false;
    }
    if (this.x == A.getX() && this.y == A.getY()) {
      return true;
    } else {
      return false;
    }
  }
}

class Milestone {
  int type;
  float x;
  float y;
  Milestone prev;
  
  Milestone(float startX, float startY, int startType) {
    type = startType;
    x = startX;
    y = startY;
  }
  
  void setType(int newType) {
    type = newType;
  }
  
  int getType() {
    return type;
  }
  
  float getX() {
    return x;
  }
  
  float getY() {
    return y;
  }
  
  void setPrev(Milestone newPrev) {
    prev = newPrev;
  }
  Milestone getPrev() {
    return prev;
  }
  boolean compare(Milestone A) {
    if (A == null) {
      return false;
    }
    if (this.x == A.getX() && this.y == A.getY()) {
      return true;
    } else {
      return false;
    }
  }
}

class Obstacle {
  float x;
  float y;
  float size;
  
  Obstacle(float startX, float startY, float startSize) {
    this.x = startX;
    this.y = startY;
    this.size = startSize;
  }
  
  float getX() {
    return x;
  }
  
  float getY() {
    return y;
  }
  
  float getSize() {
    return size;
  }
  void drawObstacle() {
    pushMatrix();
    fill(100,0,0);
    stroke(255,0,0);
    translate(0,0,1);
    ellipse(this.x, this.y, this.size, this.size);
    popMatrix();
  }
}

class CircleBoy {
  Vector pos;
  Vector vel;
  float size;
  int pathIndex = 0;
  
  CircleBoy(float startX, float startY, float startSize) {
    this.pos = new Vector(startX, startY);
    this.size = startSize * 2;
    this.vel = new Vector(0.0,0.0);
  }
  
  float getX() {
    return pos.x;
  }
  float getY() {
    return pos.y;
  }
  
  void drawCircleBoy() {
    pushMatrix();
    fill(255);
    stroke(50,200,50);
    translate(0,0,1);
    ellipse(this.pos.x-(size/2)+boardSize/40, this.pos.y+(size/2)-boardSize/40, this.size, this.size);
    popMatrix();
  }
  
  void update() {
    ArrayList<Milestone> path = board.getPath();
    if (pathIndex != path.size()) {
      Vector dist = new Vector(path.get(pathIndex).getX() - this.pos.x, path.get(pathIndex).getY() - this.pos.y);
      boolean printCode = false;
      
      if (printCode && debug) {
        println("path size = " + path.size());
        println("path i = " + path.get(0).getX());
        println("path j = " + path.get(0).getY());
        println("xDis = " + dist.x);
        println("yDis = " + dist.y);
      }
      
      if (abs(dist.x) + abs(dist.y) < 1) {
        if (path.get(pathIndex).getType() == 0) {
          board.setPathType(pathIndex, 3);
          pathIndex++;
        }
      }
      if (dist.magnitude() > boardSize * 0.0025) {
        dist.divide(dist.magnitude());
        dist.scaler(boardSize * 4.0);
        vel = dist;
      } else {
        dist.scaler(boardSize * 0.625);
        vel = dist;
      }
      pos.addV(vel.scalerNC(dt));
        
    }
    
  }
}

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
