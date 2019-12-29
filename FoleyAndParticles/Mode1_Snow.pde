// Mode 1: Snow

AudioPlayer wind;

float snowflake_count = 8000;

PImage mountain;
PImage snowflake;

Yeti yeti;

void setup_snow(){
  // Load wind SFX
  wind = minim.loadFile("Wind.mp3");
  wind.loop();
  
  // Load images/textures
  mountain = loadImage("Mountain.jpg");
  snowflake = loadImage("Snowflake.png");
  yeti = new Yeti();
  yeti.upload_gif();
  
  dt = 1;
  
  // Initialize particles for the scene
  particles = new ArrayList<Particle>();
  for (int i = 0; i < snowflake_count; i++) {
    particles.add(new Particle(random(width), random(height),
                               random(-1,1),  random(1), 0, 0, false));
  }
  
  frameRate(30);
}
  
void update_snow() {
  for (int i = 0; i < particles.size(); i++) {
    Particle p = particles.get(i);
    p.xa = random(-1,1); p.ya = random(-.25,1) + random(1);
    p.xv += p.xa * dt; p.yv += p.ya * dt;
    if (p.xv < -2) {
      p.xv = -2;
    }
    if (p.xv > 2) {
      p.xv = 2;
    }
    if (p.yv < -.25) {
      p.yv = .1;
    }
    if (p.yv > 2) {
      p.yv = 2;
    }
    
    p.x  += p.xv * dt; p.y  += p.ya * dt;
    if ((p.y > height)) {
      reset_snow(p);
    }
  }
} 

void reset_snow(Particle p) {
  p.x = random(width);
  p.y = 0;
  p.xv = random(-1,1);
  p.yv = random(1);
}

void Mode1() {
  // Load Background
  beginShape();
    texture(mountain);
    vertex(0,0, 0,0);
    vertex(0,height, 0,1);
    vertex(width,height, 1,1);
    vertex(width,0, 1,0);
  endShape();
  
  // Signal the yeti!!!
  if (yeti.running) {
    // Play Sounds Upon KeyFrames
    if (frameCount%24 == 4) {
      yeti.steps[0].play();
      yeti.steps[0].rewind();
    } else if (frameCount%24 == 14) {
      yeti.steps[1].play();
      yeti.steps[1].rewind();
    }
    yeti.update();
    
    // Draw the yeti
    pushMatrix();
    translate(yeti.x, yeti.y);
    scale(2.5);
    image(yeti.images[frameCount%24], 0, 0);
    popMatrix();
  }
  
  // Particle System
  update_snow();
  fill(255,255,255);
  for (int i = 0; i < particles.size(); i++) {
    Particle p = particles.get(i);
    pushMatrix();
    translate(p.x, p.y);
    beginShape();
      texture(snowflake);
      vertex(p.x-5, p.y-5, 0,0);
      vertex(p.x-5, p.y+5, 0,1);
      vertex(p.x+5, p.y+5, 1,1);
      vertex(p.x+5, p.y-5, 1,0);
    endShape();
    popMatrix();
  }
  
  // Back Button
  if (0 < mouseX && mouseX < 100 &&
      0 < mouseY && mouseY < 100) {
    fill(255,0,0);
    quad(0,0, 0,100, 100,100, 100,0);
    fill(255,255,255);
    textSize(75);
    text("<-",50,75);
  }
}

void keyPressedMode1() {
  if (keyCode == 32) {
    yeti.reset();
    yeti.running = true;
  }
}

void mousePressedMode1() {
  if (0 < pmouseX && pmouseX < 100 &&
      0 < pmouseY && pmouseY < 100) {
    wind.close();
    yeti.steps[0].close();
    yeti.steps[1].close();
    setupStartScreen();
    Mode1 = false;
    StartScreen = true;
  }
}

class Yeti {
  float x, y;
  boolean running;
  AudioPlayer[] steps;
  PImage[] images;
  
  Yeti() {
    x = width;
    y = height-548;
    running = false;
    
    steps = new AudioPlayer[2];
    steps[0] = minim.loadFile("Step1.mp3");
    steps[1] = minim.loadFile("Step2.mp3");
    
    images = new PImage[24];
  }
  
  void update() {
    x -= 40;
    if (x < -350) {
      reset();
    }
  }
  
  void reset() {
    x = width;
    running = false;
  }
  
  void upload_gif(){
    yeti.images[0] = loadImage("Yeti/frame_00_delay-0.03s.png");
    yeti.images[1] = loadImage("Yeti/frame_01_delay-0.03s.png");
    yeti.images[2] = loadImage("Yeti/frame_02_delay-0.03s.png");
    yeti.images[3] = loadImage("Yeti/frame_03_delay-0.03s.png");
    yeti.images[4] = loadImage("Yeti/frame_04_delay-0.03s.png");
    yeti.images[5] = loadImage("Yeti/frame_05_delay-0.03s.png");
    yeti.images[6] = loadImage("Yeti/frame_06_delay-0.03s.png");
    yeti.images[7] = loadImage("Yeti/frame_07_delay-0.03s.png");
    yeti.images[8] = loadImage("Yeti/frame_08_delay-0.03s.png");
    yeti.images[9] = loadImage("Yeti/frame_09_delay-0.03s.png");
    yeti.images[10] = loadImage("Yeti/frame_10_delay-0.03s.png");
    yeti.images[11] = loadImage("Yeti/frame_11_delay-0.03s.png");
    yeti.images[12] = loadImage("Yeti/frame_12_delay-0.03s.png");
    yeti.images[13] = loadImage("Yeti/frame_13_delay-0.03s.png");
    yeti.images[14] = loadImage("Yeti/frame_14_delay-0.03s.png");
    yeti.images[15] = loadImage("Yeti/frame_15_delay-0.03s.png");
    yeti.images[16] = loadImage("Yeti/frame_16_delay-0.03s.png");
    yeti.images[17] = loadImage("Yeti/frame_17_delay-0.03s.png");
    yeti.images[18] = loadImage("Yeti/frame_18_delay-0.03s.png");
    yeti.images[19] = loadImage("Yeti/frame_19_delay-0.03s.png");
    yeti.images[20] = loadImage("Yeti/frame_20_delay-0.03s.png");
    yeti.images[21] = loadImage("Yeti/frame_21_delay-0.03s.png");
    yeti.images[22] = loadImage("Yeti/frame_22_delay-0.03s.png");
    yeti.images[23] = loadImage("Yeti/frame_23_delay-0.03s.png");
  }
}
