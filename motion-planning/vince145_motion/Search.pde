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
