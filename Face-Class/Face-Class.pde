/**Terminar barbilla
*  Inclinación de la cabeza
*  Punto superior (relativo a la inclinación)
*  de las cejas (para las expresiones).
*  Hacer que faceController.getFace().getCenter()
*  sea equivalente a hacer faceController.getCenter()????
*  Fix mouth (rebuild)*/

import java.lang.*;
import cvimage.*;
import org.opencv.core.*;
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

//Copy test
RealEye leftEyeCopy;
RealEye rightEyeCopy;
RealFace faceCopy;

PImage img1;
PVector img1Pos;   

//float resFactor;

void setup() {
  size(640, 480);
  debug = false;
  outlines = false;
  smooth = true;
  cal_i = 0;
  
  //resFactor = 0.5;
  
  position = new Point(width/2, height/2);
  
  //player_face = new Face(this, "DroidCam Source 3", 0.5f, 0.2f, 0.1f, 0.1f);
  //faceController = new FaceController(this, "DroidCam Source 3", 0.25);
  faceController = new FaceController(this, "Trust Webcam", 0.25);
  //faceController.process();
  /*println("Initial values:");
  println("Face Center: " + faceController.getFace().getCenter());
  println("Left Eyebrow (Relative): " + (playerFace.getLeftEyebrow().getTop().x) +
          ", " + (playerFace.getLeftEyebrow().getTop().y));
  println("Right Eyebrow (Relative): " + (playerFace.getRightEyebrow().getTop().x) +
          ", " + (playerFace.getRightEyebrow().getTop().y));
  //println("left eye: " + faceController.getLeftEye());
  println("Left Eye (Relative): " + (faceController.getLeftEye().getCenter().x - faceController.getFace().getCenter().x) +
          ", " + (faceController.getLeftEye().getCenter().y - faceController.getFace().getCenter().y));
  println("Right Eye (Relative): " + (faceController.getRightEye().getCenter().x - faceController.getFace().getCenter().x) +
          ", " + (faceController.getRightEye().getCenter().y - faceController.getFace().getCenter().y));
  */
}

void draw() {  
  background(0);
  boolean available = faceController.process(debug);
  //faceController.print();
  /*if (leftEyeCopy != null && rightEyeCopy != null && faceCopy != null) {
    println("Copy of face: " + faceCopy.getCenter().x + ", " + faceCopy.getCenter().y);
    println("Copy of left eye: " + leftEyeCopy.getCenter().x + ", " + leftEyeCopy.getCenter().y);
    println("Copy of right eye: " + rightEyeCopy.getCenter().x + ", " + rightEyeCopy.getCenter().y);
    println("draw face copy reference: " + faceCopy);
    image(img1, img1Pos.x, img1Pos.y);
  }*/
  //println(faceController.getFace());
  
  //faceController.getFace().print();
  //println(faceController.getFace().getContour());
  PImage img = faceController.getFaceCrop();
  float imgRatio = faceController.getFace().getCropRatio();
  float w = 125;
  float h = w / imgRatio;
  //println("img: " + img);
  //image(img, (float)position.x - faceController.getCenter().x, (float)position.y - faceController.getCenter().y, w, h);
  image(img, (float)position.x - w/2, (float)position.y - h/2, w, h);
  
  
  /*
  faceController.process();
  PImage face = faceController.getFaceCrop();
  PImage faceMouth = faceController.getMouthCrop();
  PImage faceLEye = faceController.getLeftEyeCrop();
  PImage faceREye = faceController.getRightEyeCrop();
  image(face, width/2, height/2, face.width*3, face.height*3);
  //image(faceMouth, random(0, width), random(0, height), faceMouth.width*3, faceMouth.height*3);
  //image(faceLEye, random(0, width), random(0, height), faceLEye.width*3, faceLEye.height*3);
  //image(faceREye, random(0, width), random(0, height), faceREye.width*3, faceREye.height*3);
  */
  
  //println(img);
  /*float fRef = faceController.getReference();
  println("face ref: " + fRef);
  float camSize = faceController.getCamSize();
  PVector cResized = new PVector(faceController.getCenter().x/faceController.getCamSize(),faceController.getCenter().y/faceController.getCamSize());
  //float cropSize = camSize * fRef;
  PVector camDim = faceController.getCamDimensions();
  PVector camRedimDim = new PVector(camDim.x / fRef * 2, camDim.y / fRef * 2); //convertir el 2 en variable a seleccionar
  
  
  //image(img, (float)position.x - faceController.getCenter().x / faceController.getCamSize(), (float)position.y - faceController.getCenter().y / faceController.getCamSize(), 640, 480);
  //image(img, (float)position.x - (camRedimDim.x / 2), (float)position.y - (camRedimDim.y / 2) - faceController.getCenter().y, camRedimDim.x, camRedimDim.y);
  image(img, (float)position.x - faceController.getCenter().x, (float)position.y - faceController.getCenter().y, camRedimDim.x, camRedimDim.y);
  */
  
  if (faceCopy != null) {
    /*println("Copy of face: " + faceCopy.getCenter().x + ", " + faceCopy.getCenter().y);
    println("draw face copy reference: " + faceCopy);
    println(img1);*/
    image(img1, img1Pos.x, img1Pos.y);
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
    if (keyCode == ' '){
      faceCopy = faceController.copyFace();
      //println("espacio");
      //println(faceCopy.getCrop());
      img1 = faceCopy.getCrop();
      img1Pos = new PVector(random(0,100),random(0,100));
      //println(faceCopy);
      //leftEyeCopy = faceController.getLeftEye().copy();
      //rightEyeCopy = faceController.getRightEye().copy();
    }
  }
}
