// CSci-5609 Mt. St. Helens 3D Processing Visualization Assignment
// Original authors:  Sarit Ghildayal and Jung Nam, Univ. of Minnesota 2014


// bounds for the x and y dimensions of the regular grid that the data are sampled on
int xDim = 240;
int yDim = 346;

// the gridded data are stored in these arrays in column-major order.  that means the entire
// x=0 column is listed first in the array, then the entire x=1 column, and so on.  this is
// a typical way to store data that conceptually fit within a 2D array in a regular 1D array.
// there are helper functions at the bottom of this file that let you access the data directly
// by (x, y) locations in the array, so you don't have to worry too much about this if you
// don't want.
PVector[] beforePoints;
PVector[] beforeNormals;
PVector[] afterPoints;
PVector[] afterNormals;

// can be switched with the arrow keys
int displayMode = 1;

// each unit is 10 meters
// model centered around x,y and lowest z (height) value is 0
float xMin = -469.44;   
float xMax = 465.52792;
float yMin = -678.8792; 
float yMax = 674.9551;
float minElevation = 0;
float maxElevation = 199.51196;

// camera variables
float minDist = 200;
float maxDist = 1500;

// for transition
float dt;
boolean active;
int startMode = 1;
int finMode;

void setup() {
  size(1280, 900, P3D);  // Use the P3D renderer for 3D graphics
  
  // load in .csv files
  Table beforeTable = loadTable("beforeGrid240x346.csv", "header"); 
  Table afterTable = loadTable("afterGrid240x346.csv", "header"); 
  
  //initialize Point Cloud data arrays
  beforePoints = new PVector[xDim*yDim];
  afterPoints = new PVector[xDim*yDim];
  
  // fill before and after arrays with PVector point cloud data points
  for (int i = 0; i < beforeTable.getRowCount(); i++) {
    beforePoints[i] = new PVector(beforeTable.getRow(i).getFloat("x"), 
                                  beforeTable.getRow(i).getFloat("y"), 
                                  beforeTable.getRow(i).getFloat("z"));
  }
  for (int i = 0; i < afterTable.getRowCount(); i++) {
    afterPoints[i] = new PVector(afterTable.getRow(i).getFloat("x"), 
                                 afterTable.getRow(i).getFloat("y"), 
                                 afterTable.getRow(i).getFloat("z"));
  } 
  
  //Initialize and fill arrays of the before and after data normals
  beforeNormals = new PVector[xDim*yDim];
  afterNormals = new PVector[xDim*yDim];
  calculateNormals();  // function defined on the bottom
}


void draw() {
  float cameraDistance = lerp(minDist, maxDist, float(mouseY)/height);
  camera(cameraDistance,cameraDistance,cameraDistance, 0,0,0, 0,0,-1);
  directionalLight(255, 255, 255,  1, -0.5, -0.5);
  
  background(0);  // reset background to black
  pushMatrix();
  rotateZ(radians(0.25*mouseX));
  if (displayMode == 1) {  // point cloud before  // Step One
      stroke(0,0,255);    // set stroke to blue
      for(int i = 0; i < xDim*yDim; i++){
        point(beforePoints[i].x, beforePoints[i].y, beforePoints[i].z);
      }
  } 
  else if (displayMode == 2) {  // point cloud after  // Step One
      stroke(255,0,0);    // set stroke to red
      for(int i = 0; i < xDim*yDim; i++){
        point(afterPoints[i].x, afterPoints[i].y, afterPoints[i].z);
      }
  } 
  else if (displayMode == 3) {  // mesh before  // Step Three
    noStroke();
    fill(0,0,255);
    for(int j = 0; j< xDim-1; j++){
      int l = j * yDim;
      beginShape(TRIANGLE_STRIP);
        for(int i = 0; i < yDim; i++){
          // add normal 1 w/ normal()
          normal(beforeNormals[i+l].x, beforeNormals[i+l].y, beforeNormals[i+l].z);
          // add vertex 1 w/ vertex()
          vertex(beforePoints[i+l].x, beforePoints[i+l].y, beforePoints[i+l].z);
          
          normal(beforeNormals[i+l+yDim].x, beforeNormals[i+l+yDim].y, beforeNormals[i+l+yDim].z);
          // add vertex 1 w/ vertex()
          vertex(beforePoints[i+l+yDim].x, beforePoints[i+l+yDim].y, beforePoints[i+l+yDim].z);
      }
      endShape();
    }
  } 
  else if (displayMode == 4) {  // mesh after  // Step Three
    noStroke();
    fill(255,0,0);
    for(int j = 0; j< xDim-1; j++){
      int l = j * yDim;
      beginShape(TRIANGLE_STRIP);
        for(int i = 0; i < yDim; i++){
          // add normal 1 w/ normal()
          normal(afterNormals[i+l].x, afterNormals[i+l].y, afterNormals[i+l].z);
          // add vertex 1 w/ vertex()
          vertex(afterPoints[i+l].x, afterPoints[i+l].y, afterPoints[i+l].z); 
          
          // add normal 2 w/ normal()
          normal(afterNormals[i+l+yDim].x, afterNormals[i+l+yDim].y, afterNormals[i+l+yDim].z);
          // add vertex 2 w/ vertex()
          vertex(afterPoints[i+l+yDim].x, afterPoints[i+l+yDim].y, afterPoints[i+l+yDim].z);
      }
      endShape();
    }   
  } 
  else if (displayMode == 5) {  // lines from before to after  // Step Four
    for(int i = 0; i < xDim*yDim; i++){
      if (beforePoints[i].z < afterPoints[i].z){
        stroke(0, 0, 255);
      }
      else {
        stroke(255, 0, 0);
      }
        
      line(beforePoints[i].x, beforePoints[i].y, beforePoints[i].z,
           afterPoints[i].x, afterPoints[i].y, afterPoints[i].z);
    }
  }
  else if (displayMode == 6) {  // your choice  // Step Five
      if (startMode == 1) {
        if (dt <= 10){
          stroke(lerpColor(color(0, 0, 255), color(255,0,0), dt/10));
          for(int i = 0; i < xDim*yDim; i++) {
              point(lerp(beforePoints[i].x, afterPoints[i].x, dt/10),
                    lerp(beforePoints[i].y, afterPoints[i].y, dt/10),
                    lerp(beforePoints[i].z, afterPoints[i].z, dt/10));
          }
          dt += .5;
        }
        if (dt >= 10) {
          displayMode = 2;
        }
      }
      else if (startMode == 2) {
        if (dt >= 0){
          stroke(lerpColor(color(0, 0, 255), color(255,0,0), dt/10));
          for(int i = 0; i < xDim*yDim; i++) {
              point(lerp(beforePoints[i].x, afterPoints[i].x, dt/10),
                    lerp(beforePoints[i].y, afterPoints[i].y, dt/10),
                    lerp(beforePoints[i].z, afterPoints[i].z, dt/10));
          }
          dt -= .5;
        }
        if (dt <= 0) {
          displayMode = 1;
        }
      }
      else if (startMode == 3) {
        if (dt <= 10){
          noStroke();
          fill(lerpColor(color(0,0,255),color(255,0,0),dt/10));
          for(int j = 0; j< xDim-1; j++){
            int l = j * yDim;
            beginShape(TRIANGLE_STRIP);
              for(int i = 0; i < yDim; i++){
                // add normal 1 w/ normal()
                float newNormX1 = lerp(beforeNormals[i+l].x, afterNormals[i+l].x, dt/10.0);
                float newNormY1 = lerp(beforeNormals[i+l].y, afterNormals[i+l].y, dt/10.0);
                float newNormZ1 = lerp(beforeNormals[i+l].z, afterNormals[i+l].z, dt/10.0);
                normal(newNormX1, newNormY1, newNormZ1);
                // add vertex 1 w/ vertex()
                float newVertX1 = lerp(beforePoints[i+l].x, afterPoints[i+l].x, dt/10.0);
                float newVertY1 = lerp(beforePoints[i+l].y, afterPoints[i+l].y, dt/10.0);
                float newVertZ1 = lerp(beforePoints[i+l].z, afterPoints[i+l].z, dt/10.0);
                vertex(newVertX1, newVertY1, newVertZ1);
                
                // add normal 2 w/ normal()
                float newNormX2 = lerp(beforeNormals[i+l+yDim].x, afterNormals[i+l+yDim].x, dt/10.0);
                float newNormY2 = lerp(beforeNormals[i+l+yDim].y, afterNormals[i+l+yDim].y, dt/10.0);
                float newNormZ2 = lerp(beforeNormals[i+l+yDim].z, afterNormals[i+l+yDim].z, dt/10.0);
                normal(newNormX2, newNormY2, newNormZ2);
                // add vertex 2 w/ vertex()
                float newVertX2 = lerp(beforePoints[i+l+yDim].x, afterPoints[i+l+yDim].x, dt/10.0);
                float newVertY2 = lerp(beforePoints[i+l+yDim].y, afterPoints[i+l+yDim].y, dt/10.0);
                float newVertZ2 = lerp(beforePoints[i+l+yDim].z, afterPoints[i+l+yDim].z, dt/10.0);
                vertex(newVertX2, newVertY2, newVertZ2);
            }
            endShape();
          }
          dt += .5;
        }
        if (dt >= 10) {
          displayMode = 4;
        }
    }
    else if (startMode == 4) {
        if (dt >= 0){
          noStroke();
          fill(lerpColor(color(0,0,255),color(255,0,0),dt/10));
          for(int j = 0; j< xDim-1; j++){
            int l = j * yDim;
            beginShape(TRIANGLE_STRIP);
              for(int i = 0; i < yDim; i++){
                // add normal 1 w/ normal()
                float newNormX1 = lerp(beforeNormals[i+l].x, afterNormals[i+l].x, dt/10.0);
                float newNormY1 = lerp(beforeNormals[i+l].y, afterNormals[i+l].y, dt/10.0);
                float newNormZ1 = lerp(beforeNormals[i+l].z, afterNormals[i+l].z, dt/10.0);
                normal(newNormX1, newNormY1, newNormZ1);
                // add vertex 1 w/ vertex()
                float newVertX1 = lerp(beforePoints[i+l].x, afterPoints[i+l].x, dt/10.0);
                float newVertY1 = lerp(beforePoints[i+l].y, afterPoints[i+l].y, dt/10.0);
                float newVertZ1 = lerp(beforePoints[i+l].z, afterPoints[i+l].z, dt/10.0);
                vertex(newVertX1, newVertY1, newVertZ1);
                
                // add normal 2 w/ normal()
                float newNormX2 = lerp(beforeNormals[i+l+yDim].x, afterNormals[i+l+yDim].x, dt/10.0);
                float newNormY2 = lerp(beforeNormals[i+l+yDim].y, afterNormals[i+l+yDim].y, dt/10.0);
                float newNormZ2 = lerp(beforeNormals[i+l+yDim].z, afterNormals[i+l+yDim].z, dt/10.0);
                normal(newNormX2, newNormY2, newNormZ2);
                // add vertex 2 w/ vertex()
                float newVertX2 = lerp(beforePoints[i+l+yDim].x, afterPoints[i+l+yDim].x, dt/10.0);
                float newVertY2 = lerp(beforePoints[i+l+yDim].y, afterPoints[i+l+yDim].y, dt/10.0);
                float newVertZ2 = lerp(beforePoints[i+l+yDim].z, afterPoints[i+l+yDim].z, dt/10.0);
                vertex(newVertX2, newVertY2, newVertZ2);
            }
            endShape();
          }
          dt -= .5;
        }
        if (dt <= 0) {
          displayMode = 3;
        }
    }
  }
  popMatrix();
}


// Helper functions for accessing the point data by (x, y) location
PVector getBeforePoint(int x, int y) { 
  PVector beforeVec = beforePoints[(x*yDim)+y];
  return new PVector(beforeVec.x, beforeVec.y, beforeVec.z);
}

PVector getAfterPoint(int x, int y) {
  PVector afterVec = afterPoints[(x*yDim)+y];
  return new PVector(afterVec.x, afterVec.y, afterVec.z);
}


// Helper functions for accessing the normal data by (x, y) location
PVector getBeforeNormal(int x, int y) { 
  PVector beforeVec = beforeNormals[(x*yDim)+y];
  return new PVector(beforeVec.x, beforeVec.y, beforeVec.z);
}

PVector getAfterNormal(int x, int y) {
  PVector afterVec = afterNormals[(x*yDim)+y];
  return new PVector(afterVec.x, afterVec.y, afterVec.z);
}



void keyPressed() {
  if (key == '1') {
    displayMode = 1;
  }
  if (key == '2') {
    displayMode = 2;
  }
  if (key == '3') {
    displayMode = 3;
  }
  if (key == '4') {
    displayMode = 4;
  }
  if (key == '5') {
    displayMode = 5;
  }
  if (key == '6') {
    if (displayMode == 1) {
      dt = 0;
      startMode = 1;
      finMode = 2;
    }
    else if (displayMode == 2) {
      dt = 10;
      startMode = 2;
      finMode = 1;
    }
    else if (displayMode == 3) {
      dt = 0;
      startMode = 3;
      finMode = 4;
    }
    else if (displayMode == 4) {
      dt = 10;
      startMode = 4;
      finMode = 1;
    }
    displayMode = 6;
  }      
}


// Utility routine for calculating the normals of the triangle mash from vertex locations
void calculateNormals() {
  int normalStep = 6;
  for (int x = 0; x < xDim; x+=1) {
    for(int y = 0; y < yDim; y+=1) {
      PVector current = beforePoints[(x*yDim)+y]; //before(x,y);
      PVector north = new PVector(current.x, current.y, current.z);
      PVector south = new PVector(current.x, current.y, current.z);
      PVector west = new PVector(current.x, current.y, current.z);
      PVector east = new PVector(current.x, current.y, current.z);
      
      if (x-normalStep >= 0) {
        PVector w = beforePoints[((x-normalStep)*yDim)+y]; //before(x-normalStep,y);
        west = new PVector(w.x,w.y,w.z);
      }
      if (x+normalStep < xDim) {
        PVector e = beforePoints[((x+normalStep)*yDim)+y]; //before(x+normalStep,y);
        east = new PVector(e.x,e.y,e.z);
      }
      if (y-normalStep >= 0) {
        PVector s = beforePoints[(x*yDim)+(y-normalStep)]; //before(x,y-normalStep);
        south = new PVector(s.x,s.y,s.z);
      }
      if (y+normalStep < yDim) {
        PVector n = beforePoints[(x*yDim)+(y+normalStep)]; //before(x,y+normalStep);
        north = new PVector(n.x,n.y,n.z);
      }
      
      PVector eastVec = PVector.sub(east,west);
      PVector northVec = PVector.sub(north,south);
      eastVec.normalize();
      northVec.normalize();
      
      PVector norm = eastVec.cross(northVec);
      norm.normalize();
      beforeNormals[(x*yDim)+y] = norm; //new PVector(0,0,1);
    }
  }
  for (int x = 0; x < xDim; x+=1) {
    for(int y = 0; y < yDim; y+=1) {
      PVector current = afterPoints[(x*yDim)+y]; //before(x,y);
      PVector north = new PVector(current.x, current.y, current.z);
      PVector south = new PVector(current.x, current.y, current.z);
      PVector west = new PVector(current.x, current.y, current.z);
      PVector east = new PVector(current.x, current.y, current.z);
      
      if (x-normalStep >= 0) {
        PVector w = afterPoints[((x-normalStep)*yDim)+y]; //before(x-normalStep,y);
        west = new PVector(w.x,w.y,w.z);
      }
      if (x+normalStep < xDim) {
        PVector e = afterPoints[((x+normalStep)*yDim)+y]; //before(x+normalStep,y);
        east = new PVector(e.x,e.y,e.z);
      }
      if (y-normalStep >= 0) {
        PVector s = afterPoints[(x*yDim)+(y-normalStep)]; //before(x,y-normalStep);
        south = new PVector(s.x,s.y,s.z);
      }
      if (y+normalStep < yDim) {
        PVector n = afterPoints[(x*yDim)+(y+normalStep)]; //before(x,y+normalStep);
        north = new PVector(n.x,n.y,n.z);
      }
      
      PVector eastVec = PVector.sub(east,west);
      PVector northVec = PVector.sub(north,south);
      eastVec.normalize();
      northVec.normalize();
      
      PVector norm = eastVec.cross(northVec);
      norm.normalize();
      afterNormals[(x*yDim)+y] = norm; //new PVector(0,0,1);
    }
  }
}
