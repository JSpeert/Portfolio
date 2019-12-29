// Mode 2: Water

AudioPlayer water_start, water_run, water_end;

float water_count = 8000;

PImage bathroom;
PImage faucet;
PImage bathtub;
PImage dropplet;

boolean water_running;

void setup_water() {
  water_start = minim.loadFile("WaterStart.mp3");
  water_run = minim.loadFile("WaterRun.mp3");
  water_end = minim.loadFile("WaterEnd.mp3");
      
  bathroom = loadImage("Bathroom.jpg");
  faucet = loadImage("Faucet.png");
  bathtub = loadImage("Bathtub.png");
  dropplet = loadImage("Drop.png");
  
  water_running = false;
  dt = 1;
  
  particles = new ArrayList<Particle>();
  for (int i = 0; i < water_count; i++) {
    particles.add(new Particle(random(820,847), random(185,height),
                               0,  0, 0, 0, false));
  }
  frameRate(60);
}

void update_water(Particle p) {
  p.xa = random(-.5,.5); p.ya += random(5);
  p.xv += p.xa * dt; p.yv += p.ya * dt;
  
  // User Interaction
  /* float dist = dist(p.x, p.y, mouseX, mouseY);
  if (dist < 20) {
    p.xv += (p.x - mouseX);
    p.yv += (p.y - mouseY);
  } */
  
  if (p.xv < -1 || 1 < p.xv ) {
    p.xv = 0;
  }

  if (p.yv > 3) {
    p.yv = 3;
  }
    
  p.x += p.xv * dt; p.y += p.yv * dt;

  if (p.y > height-10) {
    if (water_running) {
      reset_water(p);
    } else {
      reset_water(p);
      p.active = false;
    }
  }
}

void reset_water(Particle p) {
  if (water_running){
    p.active = true;
  }
  p.x = random(820,847);
  p.y = 185;
  p.xv = 0;
  p.yv = 0;
}

void Mode2() {
  // Draw background
  beginShape();
    texture(bathroom);
    vertex(0,0, 0,0);
    vertex(0,height, 0,1);
    vertex(width,height, 1,1);
    vertex(width,0, 1,0);
  endShape();

  // Draw faucet
  pushMatrix();
  translate(5*width/6,0);
  scale(.25);
  image(faucet,0,0);
  popMatrix();
  
  // Draw bathtub
  pushMatrix();
  translate(-30,(3*height/4)+30);
  scale(3);
  image(bathtub,0,0);
  popMatrix();
  
  // Particle System
  for (int i = 0; i < particles.size(); i++) {
    Particle p = particles.get(i);
    for (int x = 0; x < 5; x++){
      update_water(p);
    }
    if (p.active) {
      pushMatrix();
      translate(p.x, p.y);
      beginShape();
        texture(dropplet);
        vertex(p.x-5, p.y-5, 0,0);
        vertex(p.x-5, p.y+5, 0,1);
        vertex(p.x+5, p.y+5, 1,1);
        vertex(p.x+5, p.y-5, 1,0);
      endShape();
      popMatrix();
    }
  }
  
  // Back button
  if (0 < mouseX && mouseX < 100 &&
      0 < mouseY && mouseY < 100) {
    fill(255,0,0);
    quad(0,0, 0,100, 100,100, 100,0);
    fill(255,255,255);
    textSize(75);
    text("<-",50,75);
  }
}

void keyPressedMode2() {
  if (keyCode == 32) {
    water_running = !water_running;
    if (water_running) {
      water_end.rewind();
      water_end.pause();
      water_start.play();
      water_run.loop();
    } else {
      water_start.rewind();
      water_run.rewind();
      water_start.pause();
      water_run.pause();
      water_end.play();
    }
  }
}

void mousePressedMode2() {
  if (0 < pmouseX && pmouseX < 100 &&
      0 < pmouseY && pmouseY < 100) {
    water_start.close();
    water_run.close(); 
    water_end.close(); 
    setupStartScreen();
    Mode2 = false;
    StartScreen = true;
  }  
}
