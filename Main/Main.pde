/**Terminar barbilla
*  Inclinación de la cabeza
*  Punto superior (relativo a la inclinación)
*  de las cejas (para las expresiones).
*  Hacer que faceController.getFace().getCenter()
*  sea equivalente a hacer faceController.getCenter()????
*  Fix mouth (rebuild)*/

import java.lang.*;

FaceController faceController;
RealFace playerFace;

float calibrationFactor;

Point position;

// DEBUG
boolean debug, outlines, smooth;

Point[] left_points;

float left_eyebrow_x;
float left_eyebrow_y;
float right_eyebrow_x;
float right_eyebrow_y;
int cal_i;

void setup() {
  println("Setup (Main)");
  size(640, 480);
  debug = false;
  outlines = false;
  smooth = true;
  cal_i = 0;
  
  position = new Point(width/2, height/2);
  
  //player_face = new Face(this, "DroidCam Source 3", 0.5f, 0.2f, 0.1f, 0.1f);
  faceController = new FaceController(this, true, 20, "DroidCam Source 3", 0.5f, 0.2f, 0.1f, 0.1f);
  faceController.Process(false);
  println("Initial values:");
  println("Face Center: " + faceController.getFace().getCenter());
  /**println("Left Eyebrow (Relative): " + (playerFace.getLeftEyebrow().getTop().x) +
          ", " + (playerFace.getLeftEyebrow().getTop().y));
  println("Right Eyebrow (Relative): " + (playerFace.getRightEyebrow().getTop().x) +
          ", " + (playerFace.getRightEyebrow().getTop().y));**/
  //println("left eye: " + faceController.getLeftEye());
  println("Left Eye (Relative): " + (faceController.getLeftEye().getCenter().x - faceController.getFace().getCenter().x) +
          ", " + (faceController.getLeftEye().getCenter().y - faceController.getFace().getCenter().y));
  println("Right Eye (Relative): " + (faceController.getRightEye().getCenter().x - faceController.getFace().getCenter().x) +
          ", " + (faceController.getRightEye().getCenter().y - faceController.getFace().getCenter().y));
  
}

void draw() {  
  faceController.Process(debug);
  
  pushStyle();
  fill(0,0,0,127);
  rect(width-10-205, 10, 205, 20); //aumentar de 15 en 15?
  popStyle();
  
  textAlign(RIGHT);
  textSize(10);
  text("[D] Debug  [O] Outlines  [S] Smoothness", width-15, 25);
  
  PVector leftEye = new PVector();
  PVector rightEye = new PVector();
  
  //Get eyes relatively from the center of the face
  //leftEye = Expressions.makeRelative(faceController.getLeftEye().getCenter(), faceController.getFace().getCenter());
  //rightEye = Expressions.makeRelative(faceController.getRightEye().getCenter(), faceController.getFace().getCenter());
  leftEye = faceController.getLeftEye().getCenter();
  rightEye = faceController.getRightEye().getCenter();
  if (debug) {
    pushStyle();
    fill(0,0,0,127);
    rect(10, 10, 250, 110); //aumentar de 15 en 15?
    popStyle();
    textAlign(LEFT);
    textSize(10);
    text("Face Distance: " + nf(faceController.getDistanceFromCamera(),0,2) +
         " cm (" + nf(faceController.getFace().getReference(),0,2) + " units)", 
         15, 
         25);
    text("Face Center: " + nf(faceController.getCenter().x,0,2) +
         ", " + nf(faceController.getCenter().y,0,2), 
         15, 
         40);
    text("Left Eyebrow (Relative): " + 
          nf(Expressions.makeRelative(faceController.getLeftEyebrow().getTop(), faceController.getCenter()).x,0,2) +
          ", " + 
          nf(Expressions.makeRelative(faceController.getLeftEyebrow().getTop(), faceController.getCenter()).y,0,2) + 
          "(" + Expressions.eyebrowIsLifted(faceController.getLeftEyebrow(), 0) + ")",
          15,
          55);
    text("Right Eyebrow (Relative): " + 
          nf(Expressions.makeRelative(faceController.getRightEyebrow().getTop(), faceController.getCenter()).x,0,2) +
          ", " + 
          nf(Expressions.makeRelative(faceController.getRightEyebrow().getTop(), faceController.getCenter()).y,0,2) + 
          "(" + Expressions.eyebrowIsLifted(faceController.getRightEyebrow(), 1) + ")",
          15,
          70);
    text("Left Eye (Relative): " + nf(faceController.getRightEye().getCenter().x,0,2) +
          ", " + nf(faceController.getRightEye().getCenter().y,0,2),
          15,
          85);
    text("Right Eye (Relative): " + nf(faceController.getLeftEye().getCenter().x,0,2) +
          ", " + nf(faceController.getLeftEye().getCenter().y,0,2),
          15,
          100);
    text("Mouth Amplitude: " + faceController.getMouth().verticalAmplitude(), 
          15, 
          115);
  } else {
    faceController.getCrop((int)position.x,(int)position.y);
    pushStyle();
    fill(255,0,255);
    noStroke();
    //circle((float)position.x + (float)left_eye.x, (float)position.y + (float)left_eye.y, 10);
    popStyle();//faceController.;
  }
  
  //println("Mouth: ", faceController.getMouth().getContour());
  if (Expressions.isOpen(faceController.getMouth())){
    pushStyle();
    fill(255,0,0);
    noStroke();
    //rect((float)position.x-25, (float)position.y,50, 500);
    popStyle();
  }
}

void keyPressed(){
  if (key == CODED) {
    if (keyCode == UP) {
      position.y -= 5;
    }
    if (keyCode == DOWN) {
      position.y += 5;
    }
    if (keyCode == LEFT) {
      position.x -= 5;
    }
    if (keyCode == RIGHT) {
      position.x += 5;
    }
  }
}

void keyReleased(){
  if (key == CODED) {
    /*
    if (keyCode == LEFT) {
      filter--;
      if (filter < 0){
        filter = 1;
      }
    }
    if (keyCode == RIGHT) {
      filter++;
      if (filter > 1){
        filter = 0;
      }
    }*/
  } else {
    if (keyCode == 'D'){
      debug = !debug;
    }
    if (keyCode == 'O'){
      outlines = !outlines;
    }
    if (keyCode == 'S'){
      //smooth = !smooth;
      noLoop();
    }
    if (keyCode == 'L'){
      //smooth = !smooth;
      loop();
    }
  }
}
