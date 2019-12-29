import peasy.*;
PeasyCam cam;

ArrayList<Strand> strands;

void setup(){
  size(1000,1000,P3D);
  cam = new PeasyCam(this, 500, 500, -250, 1000);
  
  strands = new ArrayList<Strand>();
  
  for (int i = 0; i < 5000; i++){
    strands.add(new Strand(random(width), 1000, random(-1000,0)));
  }
}

void draw(){
  background(0,125,255);
  fill(120,92,19);
  pushMatrix();
  translate(0,1000,-1000);
  rotateX(radians(90));
  quad(0,0, 0,1000, 1000,1000, 1000,0);
  popMatrix();
  pushMatrix();
  for(int i = 0; i < strands.size()-1; i++){
    strands.get(i).update(mouseX, mouseY, 1, (mouseX-pmouseX), (mouseY-pmouseY), 1);
    Strand s = strands.get(i);
    color c = s.c;
    

    fill(c);
    stroke(c);
    int segs = s.segments.size()-2;
    float[] rotations = cam.getRotations();
    beginShape(TRIANGLE_STRIP);
    for(int j = 0; j < s.segments.size()-1; j++){
      Segment seg = s.segments.get(j);
      pushMatrix();
      //translate(seg.pos.x, seg.pos.y, seg.pos.z);
      //rotate(rotations[1]);
      //rotate(rotations[0]);
      vertex(seg.pos.x+5*((segs-j)/segs), seg.pos.y, seg.pos.z);
      vertex(seg.pos.x-5*((segs-j)/segs), seg.pos.y, seg.pos.z);
      popMatrix();
    }
    endShape();
  }
  popMatrix();
}

class Vec{
  float x;
  float y;
  float z;
  
  Vec(float xx, float yy, float zz){
    x = xx; y = yy; z = zz;
  }
  
  Vec cross(Vec v){
    float xx = (y*v.z) - (z*v.y);
    float yy = (z*v.x) - (x*v.z);
    float zz = (x*v.y) - (y*v.x);
    return new Vec(xx, yy, zz);
  }
  
  float dot(Vec v){
    return ((x*v.x) + (y*v.y) + (z*v.z));
  }
  
  Vec add(Vec v){
    float x1 = x + v.x; float y1 = y + v.y; float z1 = z + v.z;
    return new Vec(x1, y1, z1);
  }
  
  Vec sub(Vec v){
    float x1 = x - v.x; float y1 = y - v.y; float z1 = z - v.z;
    return new Vec(x1, y1, z1);
  }
  
  Vec mult(float n){
    float x1 = x * n; float y1 = y * n; float z1 = z * n;
    return new Vec(x1, y1, z1);
  }
  
  Vec div(float n){
    float x1 = x/n; float y1 = y/n; float z1 = z/n;
    return new Vec(x1, y1, z1);
  }
  
  float mag(){
    return sqrt(pow(x,2) + pow(y,2) + pow(z,2));
  }
  
  Vec normalize(){
    float m = this.mag();
    return new Vec(x/m, y/m, z/m);
  }
}

class Segment{
  Vec pos;
  
  Segment(float xloc, float yloc, float zloc){
          pos = new Vec(xloc,yloc,zloc);
          }
    
}

class Strand{
  Vec pos;
  color c;
  ArrayList<Segment> segments;
  
  Strand(float xloc, float yloc, float zloc){
         pos = new Vec(xloc,yloc,zloc);
         c = color(0, random(125,255), 0);
         segments = new ArrayList<Segment>();
         int segs = (int) random(5,7);
         
         for (int i = 0; i < segs; i++){
           segments.add(new Segment(pos.x, pos.y-2*i, pos.z));
         }
         
         // set the ground as the anchor
         segments.get(0).pos.x = pos.x;
         segments.get(0).pos.y = pos.y;
         segments.get(0).pos.z = pos.z;
         
  }
  
  void update(float fx1, float fy1, float fz1,
              float fx2, float fy2, float fz2){
  // Apply wind forces
    float wind = noise(frameCount/100.0)-.5;
    // Skip the anchor segment (0)
    for (int i = 1; i < segments.size(); i++){
      Segment seg = segments.get(i);
      seg.pos.y -= (segments.size()-i)/2;
      seg.pos.x += i*wind*4;
      seg.pos.z += i*wind*4;
      
      // Include user-interaction:
        // Blades accelerated by wind from mouse
      float dist = dist(fx1, fy1, seg.pos.x, seg.pos.y);
      if (dist < 20) {
        seg.pos.x += fx2*(10/dist);
        seg.pos.y += fy2*(10/dist);
        seg.pos.z += fz2*(10/dist);
      }
      segments.set(i,seg); 
    } 
    
  // Apply spring forces
    for (int i = 0; i < segments.size()-1; i++){
      Segment seg1 = segments.get(i);
      Segment seg2 = segments.get(i+1);
      Vec link = (seg1.pos).sub(seg2.pos);
      float dist = dist(seg1.pos.x, seg1.pos.y, seg1.pos.z,
                        seg2.pos.x, seg2.pos.y, seg2.pos.z);
      if (dist > 50){
        link = link.normalize();
        link = link.mult(-50);
        
        segments.get(i+1).pos.x = seg1.pos.x + link.x;
        segments.get(i+1).pos.y = seg1.pos.y + link.y;
        segments.get(i+1).pos.z = seg1.pos.z + link.z;
      } 
    } 
  }
}

void Reset(){
  strands = new ArrayList<Strand>();
  
  for (int i = 0; i < 5000; i++){
    strands.add(new Strand(random(width), 1000, random(-1000,0)));
  }
}

void keyPressed(){
  if(keyCode == 32){
    Reset();
  }
}
