import peasy.*;         // import camera library

PeasyCam cam;
PImage img;

float dt;
float gravity = 9.8;

// Check for top points
boolean top = true;

// Texture Mode
boolean text = false;

// Spring Constants
float k1 = 1500; float k2 = 1500;
float kv1 = 500;  float kv2 = 500;

// Drag Constants
boolean drag = false;
float pcd = .001; 
float vx_air = 0;
float vy_air = -1000;
float vz_air = 0;

// Arrays to hold balls and strings
Ball[] balls;
string[] strings;
string[] cstrings;  // cross strings


void setup(){
  size(1920, 1080, P3D);
  surface.setTitle("HW2: Cloth");
  dt = .001;
  cam = new PeasyCam(this, 500, 500, -50, 1000.0);
  cam.setSuppressRollRotationMode();
  img = loadImage("flannel.jpg");
  balls = new Ball[20*20];
  strings = new string[20*20];
  cstrings = new string[20*20];
  for(int y = 0; y < 20; y++){
    for(int x = 0; x < 20; x++){
      if (y < 1){
        balls[x+(y*20)] = new Ball(250+(x*35), 250, -50,
                                   0, 0, 0,
                                   3, 200);
      } else {
        balls[x+(y*20)] = new Ball(250+(x*35), 250+(y*15), -50-(y*15),
                                   0, 0, 0,
                                   3, (200 - ((y-1)*10)));
      }
    }
  }
  for(int y = 1; y < 20; y++){
    for(int x = 0; x < 20; x++){
      strings[x+(y*20)] = new string(balls[x+(y*20)],
                                     balls[x+((y-1)*20)], 
                                     35);
    }
  }
  for(int y = 0; y < 20; y++){
    for(int x = 0; x < 19; x++){
        cstrings[x+(y*19)] = new string(balls[x+(y*20)],
                                        balls[x+1+(y*20)],
                                        25);
    }
  }
}

void update_S(string s, boolean top){
  Ball b1 = s.b1; Ball b2 = s.b2;
  float ex = b2.xpos - b1.xpos;
  float ey = b2.ypos - b1.ypos;
  float ez = b2.zpos - b1.zpos;
  float l = sqrt(pow(ex,2) +
                 pow(ey,2) +
                 pow(ez,2));
  s.strLen = l;
  // Normalize
  ex /= l; 
  ey /= l; 
  ez /= l;
  float vx1 = ex * b1.xvel; float vx2 = ex * b2.xvel;
  float vy1 = ey * b1.yvel; float vy2 = ey * b2.yvel;
  float vz1 = ez * b1.zvel; float vz2 = ez * b2.zvel;
  float v1 = vx1 + vy1 + vz1; float v2 = vx2 + vy2 + vz2;
  
  float stringF = (-k1 * (s.restLen - l)) - (kv1 * (v1 - v2));

  b1.xvel += (stringF * ex * dt);
  b1.yvel += (stringF * ey * dt) + (gravity * b1.mass * dt);
  b1.zvel += (stringF * ez * dt);
  
  b1.xpos += b1.xvel * dt; 
  b1.ypos += b1.yvel * dt; 
  b1.zpos += b1.zvel * dt; 
  if (!top){
    b2.xvel -= stringF * ex * dt;
    b2.yvel -= stringF * ey * dt;
    b2.zvel -= stringF * ez * dt;
    
    b2.xpos += b2.xvel * dt;
    b2.ypos += b2.yvel * dt;
    b2.zpos += b2.zvel * dt;
  } else {
    b2.xvel = 0;
    b2.yvel = 0;
    b2.zvel = 0;
  }

  s.b1 = b1;
  s.b2 = b2;
}

void update_CS(string cs){
  Ball b1 = cs.b1; Ball b2 = cs.b2;
  float ex = b2.xpos - b1.xpos;
  float ey = b2.ypos - b1.ypos;
  float ez = b2.zpos - b1.zpos;
  float l = sqrt(pow(ex,2) +
                 pow(ey,2) +
                 pow(ez,2));
  cs.strLen = l;
  ex /= l; 
  ey /= l; 
  ez /= l; 
  float vx1 = ex * b1.xvel; float vx2 = ex * b2.xvel;
  float vy1 = ey * b1.yvel; float vy2 = ey * b2.yvel;
  float vz1 = ez * b1.zvel; float vz2 = ez * b2.zvel;
  float v1 = vx1 + vy1 + vz1; float v2 = vx2 + vy2 + vz2;
  
  float stringF = (-k2 * (cs.restLen - l)) - (kv2 * (v1 - v2));

  b1.xvel += stringF * ex * dt; b2.xvel -= stringF * ex * dt;
  b1.yvel += stringF * ey * dt; b2.yvel -= stringF * ey * dt;
  b1.zvel += stringF * ez * dt; b2.zvel -= stringF * ez * dt;
  cs.b1 = b1;
  cs.b2 = b2;
}

void drag(string s1, string s2){
  Ball b1 = s1.b1; Ball b2 = s1.b2;
  Ball b3 = s2.b1; Ball b4 = s2.b2;
  float vx = ((b1.xvel + b2.xvel + b3.xvel + b4.xvel)/4)-vx_air;
  float vy = ((b1.yvel + b2.yvel + b3.yvel + b4.yvel)/4)-vy_air;
  float vz = ((b1.zvel + b2.zvel + b3.zvel + b4.zvel)/4)-vz_air;
  PVector v = new PVector(vx, vy, vz);
  PVector r1 = new PVector(b1.xpos, b1.ypos, b1.zpos);
  PVector r2 = new PVector(b2.xpos, b2.ypos, b2.zpos);
  PVector r3 = new PVector(b3.xpos, b3.ypos, b3.zpos);
  PVector r4 = new PVector(b4.xpos, b4.ypos, b4.zpos);
  
  PVector n1 = (r2.sub(r1)).cross(r3.sub(r1)).normalize();
  PVector n2 = (r2.sub(r4)).cross(r3.sub(r1)).normalize();
  PVector n = (n1.add(n2)).div(2);
  
  PVector van = n.mult(((v.mag()*v.dot(n))/(2*n.mag())));
  PVector dragF = (van.mult(pcd)).div(-4);
  
  b1.xvel += dragF.x * dt; b2.xvel += dragF.x * dt;
  b1.yvel += dragF.y * dt; b2.yvel += dragF.y * dt;
  b1.zvel += dragF.z * dt; b2.zvel += dragF.z * dt;
  
  b3.xvel += dragF.x * dt; b4.xvel += dragF.x * dt;
  b3.yvel += dragF.y * dt; b4.yvel += dragF.y * dt;
  b3.zvel += dragF.z * dt; b4.zvel += dragF.z * dt;
  
  s1.b1 = b1; s1.b2 = b2;
  s2.b1 = b3; s2.b2 = b4;
}

void draw(){
  background(255,255,255);
  lights();

  for(int i = 0; i < 10; i ++){
    for(int y = 1; y < 20; y++){
      if(y > 1){ top = false; }
      for(int x = 0; x < 20; x++){
        string s1 = strings[x+(y*20)];
        update_S(s1, top);
        if (x < 19){
          if(drag){
            string s2 = strings[x+1+(y*20)];
            drag(s1, s2);
          }
          string cs = cstrings[x+(y*19)];
          update_CS(cs);
        }
      }
    }
    top = true;
  }
 
 noStroke();
 textureMode(NORMAL);
 for(int y = 1; y < 20; y++){
    for(int x = 0; x < 19; x++){
      string s1 = strings[x+(y*20)]; 
      string s2 = strings[x+1+(y*20)];
      if (x < 19){
        string cs = cstrings[x+(y*19)];
        line(cs.b1.xpos, cs.b1.ypos, cs.b1.zpos, cs.b2.xpos, cs.b2.ypos, cs.b2.zpos);
      }
      line(s1.b1.xpos, s1.b1.ypos, s1.b1.zpos, s1.b2.xpos, s1.b2.ypos, s1.b2.zpos);
      beginShape(TRIANGLE_STRIP);
      if (text){
        texture(img);
      } else {
        if(y % 2 == 0){
          fill(255,0,0);
        } else {
          fill(0, 0, 0);
        }
      }

      vertex(s1.b2.xpos, s1.b2.ypos, s1.b2.zpos, 0, 0);
      vertex(s1.b1.xpos, s1.b1.ypos, s1.b1.zpos, 0, 1);
      vertex(s2.b2.xpos, s2.b2.ypos, s2.b2.zpos, 1, 0);
      vertex(s2.b1.xpos, s2.b1.ypos, s2.b1.zpos, 1, 1);
      
      endShape();
    }
 }
}

class string{
  Ball b1;
  Ball b2;
  float restLen;
  float strLen;
  
  string(Ball b, Ball bb, float rl){
    b1 = b;
    b2 = bb;
    restLen = rl;
    strLen = sqrt(pow(b1.xpos-b2.xpos, 2) +
                  pow(b1.ypos-b2.ypos, 2) +
                  pow(b2.zpos-b2.zpos, 2));
  }
}
class Ball{
  float xpos, ypos, zpos;
  float xvel, yvel, zvel;
  float radius;
  float mass;
  
  Ball(float x, float y, float z,
       float xv, float yv, float zv,
       float r,float m){
    xpos = x; ypos = y; zpos = z;
    xvel = xv; yvel = yv; zvel = zv;
    radius = r;
    mass = m;
  }
}

void Reset(){
  for(int y = 0; y < 20; y++){
    for(int x = 0; x < 20; x++){
      if (y < 1){
        balls[x+(y*20)] = new Ball(250+(x*35), 250+(y*35), -50,
                                   0, 0, 0,
                                   3, 200);
      } else {
        balls[x+(y*20)] = new Ball(250+(x*35), 250+(y*15), -50-(y*15),
                                   0, 0, 0,
                                   3, (200 - ((y-1)*10)));
      }
    }
  }
  for(int y = 1; y < 20; y++){
    for(int x = 0; x < 20; x++){
      strings[x+(y*20)] = new string(balls[x+(y*20)],
                                     balls[x+((y-1)*20)], 
                                     35);
    }
  }
  for(int y = 0; y < 20; y++){
    for(int x = 0; x < 19; x++){
        cstrings[x+(y*19)] = new string(balls[x+(y*20)],
                                        balls[x+1+(y*20)],
                                        25);
    }
  }
}

void keyPressed() {
  if (keyCode == 32){
    Reset();
  }
  if (keyCode == ENTER){
    drag = !drag;
    println("Drag: ", drag);
  }
  if (keyCode == SHIFT){
    text = !text;
  }
  if (keyCode == UP){
    vy_air -= 10;
    println(vy_air);
  }
  if (keyCode == DOWN){
    vy_air += 10;
    println(vy_air);
  }
}
