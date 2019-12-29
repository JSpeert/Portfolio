// Start Screen
float blinker_count = 10000;

float TitleWidth = 1000; float TitleHeight = 200;
float buttonWidth = 800; float buttonHeight = 100;

void setupStartScreen() {
  particles = new ArrayList<Particle>();
  for (int i = 0; i < blinker_count; i++) {
    particles.add(new Particle(0,0,0,0,0,0,true));
  }
}

void drawStartScreen() {
  // Use particles to create a flashy background
  for (int i = 0; i < blinker_count; i++) {
    Particle p = particles.get(i);
    p.x = random(width); p.y = random(height);
    float scale = random(5);
    fill(random(255),random(255),random(255));
    quad(p.x,p.y, p.x,p.y+scale, p.x+scale,p.y+scale, p.x+scale,p.y);
  }
  
  pushMatrix();
  translate(width/2,200);
  strokeWeight(10);
  // Title
  stroke(random(255),random(255),random(255));
  fill(0,0,0);
  //fill(random(255),random(255),random(255));
  quad(-TitleWidth/2,-TitleHeight/2, 
       -TitleWidth/2, TitleHeight/2,
        TitleWidth/2, TitleHeight/2,
        TitleWidth/2,-TitleHeight/2);
  fill(random(255),random(255),random(255));
  textSize(125);
  textAlign(CENTER);
  text("Foley & Particles",0,50);

  noStroke();
  // Mode 1 - Snow
  translate(0,350);
  fill(150,150,150);
  quad(-buttonWidth/2,-buttonHeight/2, 
       -buttonWidth/2, buttonHeight/2,
        buttonWidth/2, buttonHeight/2,
        buttonWidth/2,-buttonHeight/2);
  fill(255,255,255);
  textSize(100);
  text("Snow",0,40);
        
  // Mode 2 - Water
  translate(0,200);
  fill(0,0,150);
  quad(-buttonWidth/2,-buttonHeight/2, 
       -buttonWidth/2, buttonHeight/2,
        buttonWidth/2, buttonHeight/2,
        buttonWidth/2,-buttonHeight/2);
  fill(0,0,255);
  text("Water",0,40);
  
 /* // Mode 3 - Sound Manipulation
  translate(0,200);
  fill(255,0,0);
  quad(-buttonWidth/2,-buttonHeight/2, 
       -buttonWidth/2, buttonHeight/2,
        buttonWidth/2, buttonHeight/2,
        buttonWidth/2,-buttonHeight/2);
  fill(125,0,0);
  text("Hard",0,40); */ 
  popMatrix(); 
}

void keyPressedStartScreen() {
  
}

void mousePressedStartScreen() {
  // Clicked on Snow
  if(((width/2)-(buttonWidth/2)) < pmouseX &&
       pmouseX < ((width/2)+(buttonWidth/2)) &&
       500 < pmouseY && pmouseY < 600) {
       setup_snow();
       StartScreen = false;
       Mode1 = true;
  }
  
  // Clicked on Water
  if(((width/2)-(buttonWidth/2)) < pmouseX && 
       pmouseX < ((width/2)+(buttonWidth/2)) &&
       700 < pmouseY && pmouseY < 800) {
       setup_water();  
       StartScreen = false;
       Mode2 = true;
  }
}
