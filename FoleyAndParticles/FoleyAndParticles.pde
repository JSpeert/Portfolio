// Controller between different parts of the program

import ddf.minim.*;
Minim minim;

float dt;
int t = second();

// Different modes
boolean StartScreen;
boolean Mode1;
boolean Mode2;

ArrayList<Particle> particles;

void setup(){
  size(1920, 1080, P2D);
  minim = new Minim(this);
  
  textureMode(NORMAL);
  
  setupStartScreen();
  StartScreen = true;
  Mode1 = Mode2 = false;
}

void draw() {
  if (StartScreen) {
    background(0,0,0);
    drawStartScreen();
  } else if (Mode1) {
    Mode1();
  } else if (Mode2) {
    Mode2();
  }
}

void keyPressed() {
  if (StartScreen) {
    keyPressedStartScreen();
  } else if (Mode1) {
    keyPressedMode1();
  } else if (Mode2) {
    keyPressedMode2();
  }  
}

void mousePressed() {
  if (StartScreen) {
    mousePressedStartScreen();
  } else if (Mode1) {
    mousePressedMode1();
  } else if (Mode2) {
    mousePressedMode2();
  }
}

class Particle {
  float x, y;
  float xv, yv;
  float xa, ya;
  boolean active;
  
  Particle(float xloc, float yloc, 
           float xvel, float yvel,
           float xacc, float yacc,
           boolean a) {
    x  = xloc; y  = yloc;
    xv = xvel; yv = yvel;
    xa = xacc; ya = yacc;
    
    active = a;
  }
}
