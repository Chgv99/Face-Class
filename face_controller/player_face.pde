import processing.video.*;
import cvimage.*;
import org.opencv.core.*;

//Detectores
import org.opencv.objdetect.CascadeClassifier;
//Máscara del rostro
import org.opencv.face.Face;
import org.opencv.face.Facemark;

import java.nio.*;
import org.opencv.core.Mat;
import org.opencv.core.CvType;

Capture cam;
CVImage img;

//Detectores
CascadeClassifier face;
//Máscara del rostro
Facemark fm;
//Nombres
String faceFile, modelFile;

PShape face_shape;

// DEBUG
boolean debug, outlines, smooth;

//FILTER STATE
int filter;

class PlayerFace{
  
  Point[] points;
  
  //EYES
  PImage left_eye, right_eye;
  int left_eye_left_x, left_eye_left_y, right_eye_left_x, right_eye_left_y, eyeb_y;
  private float face_distance_units, face_distance_cm;
  
  //MOUTH
  //float alpha_product;
  PImage mouth;
  private int mouth_x, mouth_y, mouth_min_x, mouth_max_x, mouth_min_y, mouth_max_y;
  private float mouth_amplitude;
  private float mouth_threshold;
  
  public PlayerFace(PApplet parent){
    //size(640, 480);
    //Cámara
    cam = null;
    while (cam == null) {
      //cam = new Capture(this, width , height-60, "");
      cam = new Capture(parent, width , height, "DroidCam Source 3");
    }
    
    cam.start(); 
    
    //OpenCV
    //Carga biblioteca core de OpenCV
    System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    println(Core.VERSION);
    img = new CVImage(cam.width, cam.height);
    
    //Detectores
    faceFile = "haarcascade_frontalface_default.xml";
    //Modelo de máscara
    modelFile = "face_landmark_model.dat";
    fm = Face.createFacemarkKazemi();
    fm.loadModel(dataPath(modelFile));
  }
  
  private void Process(){
    if (cam.available()) {
      background(0);
      cam.read();
      
      //Get image from cam
      img.copy(cam, 0, 0, cam.width, cam.height, 
      0, 0, img.width, img.height);
      img.copyTo();
      
      //Face distance reference (from drawFacemarks()) 
      face_distance_units = distance(left_eye_left_x,left_eye_left_y,right_eye_left_x,right_eye_left_y);
      face_distance_cm = 2900 / face_distance_units;
      mouth_amplitude = distance(mouth_max_x, mouth_max_y, mouth_min_x, mouth_min_y) / face_distance_units;
      
      //Imagen de entrada
      //image(img,0,0);
      
      pushStyle();
      //rect(0, height-40, width, 40);
      fill(0,0,0,127);
      rect(width-10-205, 10, 205, 20); //aumentar de 15 en 15?
      popStyle();
      
      textAlign(RIGHT);
      textSize(10);
      text("[D] Debug  [O] Outlines  [S] Smoothness", width-15, 25);
      
      if (debug) {
        pushStyle();
        fill(0,0,0,127);
        rect(10, 10, 250, 35); //aumentar de 15 en 15?
        popStyle();
        textAlign(LEFT);
        textSize(10);
        text("Face Distance: " + nf(face_distance_cm,0,2) + " cm (" + nf(face_distance_units,0,2) + " units)" ,15, 25);
        text("Mouth Amplitude: " + mouth_amplitude, 15, 40);
      }
      
      //Detección de puntos fiduciales
      ArrayList<MatOfPoint2f> shapes = detectFacemarks(cam);
      PVector origin = new PVector(0, 0);
      
      for (MatOfPoint2f sh : shapes) {
          Point [] pts = sh.toArray();
          drawFacemarks(pts, origin);
          //shape(face_shape);
      }
    }
  }
  
  public float GetDistance(){
    return face_distance_units;
  }
  
  public float GetDistanceInCm(){
    return face_distance_cm;
  }
  
  public boolean MouthIsOpen(){
    return mouth_amplitude > 0.5f;
  }
  
  private float distance(int x_1, int y_1, int x_2, int y_2){
    return sqrt(pow(x_1 - x_2, 2) + pow(y_1 - y_2, 2));
  }
  
  private ArrayList<MatOfPoint2f> detectFacemarks(PImage i) {
    ArrayList<MatOfPoint2f> shapes = new ArrayList<MatOfPoint2f>();
    CVImage im = new CVImage(i.width, i.height);
    im.copyTo(i);
    MatOfRect faces = new MatOfRect();
    Face.getFacesHAAR(im.getBGR(), faces, dataPath(faceFile)); 
    if (!faces.empty()) {
      fm.fit(im.getBGR(), faces, shapes);
    }
    return shapes;
  }
  
  private void drawFacemarks(Point [] p, PVector o) {
    pushStyle();
    noStroke();
    //fill(255,0,0);
    noFill();
    face_shape = createShape();
    face_shape.beginShape();
    int i = 0;
    for (Point pt : p) {
      face_shape.vertex((float)pt.x+o.x, (float)pt.y+o.y);
      //ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
      if (i == 42) {
        //Right eye's leftmost vertex
        stroke(255,0,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 5, 5);
        right_eye_left_x = (int)(pt.x+o.x);
        right_eye_left_y = (int)(pt.y+o.y);
      } else if (i == 36) {
        stroke(255,0,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 5, 5);
        left_eye_left_x = (int)(pt.x+o.x);
        left_eye_left_y = (int)(pt.y+o.y);
      } else if (i == 18) {
        stroke(0,255,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        eyeb_y = (int)(pt.y+o.y);
      /*} else if (i == 48) {
        stroke(255,0,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        mouth_x = (int)(pt.x+o.x);
        mouth_y = (int)(pt.y+o.y);*/
      } else if (i == 50) {
        stroke(255,255,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        mouth_max_x = (int)(pt.x+o.x);
        mouth_max_y = (int)(pt.y+o.y);
      } else if (i == 58) {
        stroke(255,255,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        mouth_min_x = (int)(pt.x+o.x);
        mouth_min_y = (int)(pt.y+o.y);
      } else {
        stroke(255);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 1, 1);
      }
      i++;
    }
    face_shape.endShape(CLOSE);
    popStyle();
  }
}
