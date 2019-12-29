// 1 m = 20 pixels

import java.util.PriorityQueue;
import java.util.Comparator;

// Toggle graph view
boolean graph;

ArrayList<WayPoint> wPoints;
ArrayList<Edge> edges;  // List of all edges
ArrayList<Edge> path;   // List for shortest path
PriorityQueue<WayPoint> fringe;   // Priority Queue for Dijkstra
Player player;
Obstacle obst;
float t;
float dt;
int currEdge;

void setup(){
  size(1000,1000, P2D);
  graph = true;
  dt = 0;
  
  // Set up inital objects
  player = new Player(320, 680, 0, 0);
  obst = new Obstacle(500, 500, 60);
  
  // Sample in Configuration Space
  wPoints = new ArrayList<WayPoint>();
  // Add starting point
  wPoints.add(new WayPoint(player.x, player.y,0));
  AddPoints();
  // Add finishishing point
  wPoints.add(new WayPoint(680, 320, wPoints.size()));

  // Build PRM
  edges = new ArrayList<Edge>();
  ConnectEdges();
  
  // Add weights to each node
  fringe = new PriorityQueue<WayPoint>(wPoints.size());
  wPoints.get(0).weight = 0;
  fringe.add(wPoints.get(0));
  CalcWeights(fringe.poll(), 0);
  
  // Ensure a path was made
  if(wPoints.get(wPoints.size()-1).parent == null){ Reset(); }
  
  // Connect path
  path = new ArrayList<Edge>();
  ShortestPath(wPoints.get(wPoints.size()-1));
  currEdge = path.size()-1;
}

void AddPoints(){
  for(int i = 0; i < 5; i++){
    float x = random(300, 700);
    float y = random(300, 700);
    if(obst.x-(obst.r) < x && x < obst.x+(obst.r) &&
       obst.y-(obst.r) < y && y < obst.y+(obst.r)){}
    else { wPoints.add(new WayPoint(x, y, i+1)); }   
  }
}

void ConnectEdges(){
  for(int i = 0; i < wPoints.size(); i++){
    WayPoint p1 = wPoints.get(i);
    if(obst.x-obst.r < p1.x && p1.x < obst.x+obst.r &&
       obst.y-obst.r < p1.y && p1.y < obst.y+obst.r){}
    else{
      for(int j = 0; j < wPoints.size(); j++){
        // Check if points are equal
        if (i == j){}
        else {
          WayPoint p2 = wPoints.get(j);
          
          // Check if points connect w/o obstacle intersection
          float xdir = p2.x - p1.x;
          float ydir = p2.y - p1.y;
          float mag = sqrt((p1.x*p2.x) + (p1.y*p2.y));
          xdir /= mag; ydir/= mag;
          t = 20000;
          Ray ray = new Ray(p1.x, p1.y, xdir, ydir);
          
          boolean invalid = obst.intersect(ray, p2);
          if (invalid){}
          else{ edges.add(new Edge(p1, p2));
                p1.neighbors.add(new Edge(p1, p2)); }
        }
      }
    }
  }
}

void CalcWeights(WayPoint p, float total){
  total = p.weight;
  if(p.id == wPoints.size()-1){}
  else{
    p.visited = true;
    for (int i = 0; i < p.neighbors.size(); i++){
      Edge neighbor = p.neighbors.get(i);
      if (neighbor.p2.visited){}
      else {
        float newDist =  neighbor.dist + p.weight;
        if (newDist < neighbor.p2.weight){
          neighbor.p2.weight = newDist;
          neighbor.p2.parent = p;
        }
        fringe.add(p.neighbors.get(i).p2);
      }
    }
    if(fringe.size() > 0){
      CalcWeights(fringe.poll(), total);
    }
  }
}

void ShortestPath(WayPoint p){
  if(p.id == 0){}
  else{ 
    path.add(new Edge(p, p.parent));
    p.parent.closest = p; 
    ShortestPath(p.parent);
  }
}

void update(){
  if(dt >= 1) {
    dt = 0;
    if(currEdge == 0){
      currEdge = path.size()-1;
    } else {
      currEdge -= 1;
    }
  }
  else{
    Edge e = path.get(currEdge);
    player.x = lerp(e.p2.x, e.p1.x, dt);
    player.y = lerp(e.p2.y, e.p1.y, dt);
    dt += .01;
  }
}
     
      
      
      
      
void draw(){
  background(255, 255, 255);
  strokeWeight(1);
  stroke(0,0,0);
  rect(300,300, 400,400);
  update();
  
  for(int i = 0; i < wPoints.size(); i++){
    ellipse(wPoints.get(i).x,wPoints.get(i).y, 2,2);     
  }
  if (graph) {
    for(int i = 0; i < edges.size(); i++){
      Edge e = edges.get(i);
      line(e.p1.x, e.p1.y, e.p2.x, e.p2.y);
    }
    stroke(255,0,0);
    strokeWeight(3);
    for(int i = 0; i < path.size(); i++){
      Edge e = path.get(i);
      line(e.p1.x, e.p1.y, e.p2.x, e.p2.y);
    }
  }
  strokeWeight(3);
  stroke(255,0,0);
  ellipse(player.x, player.y, 20, 20);
  
  stroke(0,0,255);
  ellipse(obst.x, obst.y, 2*(obst.r-20), 2*(obst.r-20));
}





class WayPoint implements Comparable<WayPoint>{
  int compareTo(WayPoint p1){
    return round(weight - p1.weight);
  }
  
  boolean equals(WayPoint p){
    if(this.id == p.id) return true;
    if(p.getClass() != this.getClass()) return false;
    else return true;
  }
  
  float x;
  float y;
  float weight;
  int id;
  boolean visited;
  ArrayList<Edge> neighbors;
  WayPoint closest;
  WayPoint parent;
  
  WayPoint(float xloc, float yloc, int i){
    x = xloc; y = yloc; id = i;
    weight = 9999;
    visited = false;
    neighbors = new ArrayList<Edge>();
  }
}

class Edge implements Comparable<Edge> {
  int compareTo(Edge e1){
    return round(dist - e1.dist);
  }
  
  WayPoint p1;
  WayPoint p2;
  float dist; 
  
  Edge(WayPoint p, WayPoint pp){
    p1 = p;
    p2 = pp;
    
    dist = dist(p1.x,p1.y, p2.x,p2.y);
  }
}

class Player{
  float x;
  float y;
  float xv;
  float yv;
  
  Player(float xloc, float yloc, float xvel, float yvel){
    x  = xloc; y = yloc;
    xv = xvel; yv = yvel;
  }
}

class Ray{
  float x;
  float y;
  float xd;
  float yd;
  
  Ray(float xloc, float yloc, float xdir, float ydir){
    x =  xloc; y =  yloc;
    xd = xdir; yd = ydir;
  }
}

class Obstacle{
  float x;
  float y;
  float r;
  
  Obstacle(float xloc, float yloc, float radius){
    x = xloc; y = yloc;
    r = radius;
  }
  
  boolean intersect(Ray ray, WayPoint p){
    float ocX = ray.x - x;
    float ocY = ray.y - y;

    float a = dot(ray.xd,ray.yd, ray.xd,ray.yd);
    float b = 2 * dot(ocX,ocY, ray.xd,ray.yd);
    float c = dot(ocX,ocY, ocX,ocY) - pow(r,2);
    float disc = b*b - 4*a*c;
    
    if (disc < 0) return false;
    else {
      disc = sqrt(disc);
      float t0 = -b - disc;
      float t1 = -b + disc;
      if (t0 < t1) { t = t0; }
      else { t = t1; }
      
      if (t < 0 || t > dist(ray.x,ray.y, p.x,p.y)) return false;
      else return true;
    }
  }
}

float dot(float x1, float y1, float x2, float y2){
  return (x1*x2 + y1*y2);
}

void Reset() {
  // Set up inital objects
  player = new Player(320, 680, 0, 0);
  obst = new Obstacle(500, 500, 60);
  
  // Sample in Configuration Space
  wPoints = new ArrayList<WayPoint>();
  // Add starting point
  wPoints.add(new WayPoint(player.x, player.y,0));
  AddPoints();
  // Add finishishing point
  wPoints.add(new WayPoint(680, 320, wPoints.size()));

  // Build PRM
  edges = new ArrayList<Edge>();
  ConnectEdges();
  
  // Add weights to each node
  fringe = new PriorityQueue<WayPoint>(wPoints.size());
  wPoints.get(0).weight = 0;
  fringe.add(wPoints.get(0));
  CalcWeights(fringe.poll(), 0);
  
  // Ensure a path was made
  if(wPoints.get(wPoints.size()-1).parent == null){ Reset(); }
  
  // Connect path
  path = new ArrayList<Edge>();
  ShortestPath(wPoints.get(wPoints.size()-1));
}

void keyPressed(){
  if (keyCode == 32){
    graph = !graph;
  }
  
  if(keyCode == SHIFT){
    Reset();
  }
}
