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
