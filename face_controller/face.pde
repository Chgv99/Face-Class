/** TODO
  * Devolver coordenadas de los elementos faciales (boca, ojos)
  * Para ello deberá usarse una coordenada relativa al
  * centro de la cara (center), para mayor facilidad de uso.
  **/

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



//Detectores
CascadeClassifier face;
//Máscara del rostro
Facemark fm;
//Nombres
String faceFile, modelFile;

PShape face_shape;



//FILTER STATE
int filter;

class Face{
  
  Point[] contour = new Point[27];
  
  private Capture cam;
  private CVImage img;
  
  PGraphics maskImage;
  
  //FACE
  Point v1, v2, v3, v4;  //Face vertices
  Point center;
  
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
  
  private float upper_offset;
  private float lower_offset;
  private float left_offset;
  private float right_offset;
  
  public Face(PApplet parent, String camera, float upper_offset, float lower_offset,  float left_offset, float right_offset){
    //Cámara
    cam = null;
    while (cam == null) {
      //cam = new Capture(this, width , height-60, "");
      cam = new Capture(parent, width , height, camera);
      //cam = new Capture(parent, width , height);
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
    fm = org.opencv.face.Face.createFacemarkKazemi();
    fm.loadModel(dataPath(modelFile));
    
    for (int i = 0; i < 27; i++){
      contour[i] = new Point(0,0);
    }
    
    //Variables
    this.upper_offset = upper_offset;
    this.lower_offset = lower_offset;
    this.left_offset = left_offset;
    this.right_offset = right_offset;
  }
  
  private void Process(boolean display){
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
      if (display) image(img,0,0);
      
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
  
  public Point GetCenter(){
    return center;
  }
  
  public float GetMouthAmplitude(){
    return mouth_amplitude;
  }
  
  public boolean MouthIsOpen(){
    return mouth_amplitude > 0.5f;
  }
  
  public void GetCrop(int x, int y){
    maskImage = createGraphics(width,height);
    maskImage.beginDraw();
    //maskImage.triangle(30, 480, 256, 30, 480, 480);
    maskImage.beginShape();
    //int i = 0;
    for(Point p : contour){
      //print(i);
      maskImage.vertex((float)p.x, (float)p.y);
      //i++;
    }
    
    maskImage.endShape(CLOSE);
    maskImage.endDraw();
    // apply mask
    img.mask(maskImage);
    //smoothenEdges(img);
    image(img, x - (float)center.x, y - (float)center.y);
  }
  
  private float distance(int x_1, int y_1, int x_2, int y_2){
    return sqrt(pow(x_1 - x_2, 2) + pow(y_1 - y_2, 2));
  }
  
  private ArrayList<MatOfPoint2f> detectFacemarks(PImage i) {
    ArrayList<MatOfPoint2f> shapes = new ArrayList<MatOfPoint2f>();
    CVImage im = new CVImage(i.width, i.height);
    im.copyTo(i);
    MatOfRect faces = new MatOfRect();
    org.opencv.face.Face.getFacesHAAR(im.getBGR(), faces, dataPath(faceFile)); 
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
  
    Point max = new Point(0,0);
    Point min = new Point(width,height);
    
    for (int i = 0; i < p.length; i++) {
      Point pt = p[i];
      face_shape.vertex((float)pt.x+o.x, (float)pt.y+o.y);
      //ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
      if (i == 42) {
        //Right eye's leftmost vertex
        stroke(255,0,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 5, 5);
        right_eye_left_x = (int)(pt.x+o.x);
        right_eye_left_y = (int)(pt.y+o.y);
      } else if (i == 36) {
        stroke(255,0,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 5, 5);
        left_eye_left_x = (int)(pt.x+o.x);
        left_eye_left_y = (int)(pt.y+o.y);
      /*} else if (i == 48) {
        stroke(255,0,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        mouth_x = (int)(pt.x+o.x);
        mouth_y = (int)(pt.y+o.y);*/
      /*} else if (i == 18) {
        stroke(0,255,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        v1 = new Point(pt.x+o.x,pt.y+o.y);
        //(int)(pt.y+o.y);
      
      } else if (i == 25) {
        stroke(0,255,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        v2 = new Point(pt.x+o.x,pt.y+o.y);
      } else if (i == 5) {
        stroke(0,255,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        v3 = new Point(pt.x+o.x,pt.y+o.y);
      } else if (i == 11) {
        stroke(0,255,0);
        if (outlines) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        v4 = new Point(pt.x+o.x,pt.y+o.y);*/
      } else if (i == 50) {
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        mouth_max_x = (int)(pt.x+o.x);
        mouth_max_y = (int)(pt.y+o.y);
      } else if (i == 58) {
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        mouth_min_x = (int)(pt.x+o.x);
        mouth_min_y = (int)(pt.y+o.y);
      } else {
        stroke(255);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 1, 1);
      }
      /*if ((pt.x+o.x) > max.x) max.x = (float)(pt.x+o.x);
      if ((pt.y+o.y) > max.y) max.y = (float)(pt.y+o.y);
      if ((pt.x+o.x) < min.x) min.x = (float)(pt.x+o.x);
      if ((pt.y+o.y) < min.y) min.y = (float)(pt.y+o.y);*/
    }
    
    for(int i = 0; i < 17; i++){
      contour[i] = new Point(p[i].x+o.x, p[i].y+o.y);
      stroke(255,0,255);
      if (debug) ellipse((float)p[i].x+o.x, (float)p[i].y+o.y, 8, 8);
      if ((p[i].x+o.x) > max.x) max.x = (float)(p[i].x+o.x);
      if ((p[i].y+o.y) > max.y) max.y = (float)(p[i].y+o.y);
      if ((p[i].x+o.x) < min.x) min.x = (float)(p[i].x+o.x);
      if ((p[i].y+o.y) < min.y) min.y = (float)(p[i].y+o.y);
    }
    
    int j = 17;
    for (int i = 26; i >= 17; i--){
      float forehead_factor = face_distance_units * upper_offset;
      contour[j] = new Point(p[i].x+o.x, p[i].y+o.y - forehead_factor);
      stroke(0,0,0);
      if (debug) ellipse((float)p[i].x+o.x, (float)p[i].y+o.y - forehead_factor, 5, 5);
      stroke(255,0,255);
      if (debug) ellipse((float)p[i].x+o.x, (float)p[i].y+o.y, 8, 8);
      j++;
      if ((p[i].x+o.x) > max.x) max.x = (float)(p[i].x+o.x);
      if ((p[i].y+o.y - forehead_factor) > max.y) max.y = (float)(p[i].y+o.y - forehead_factor);
      if ((p[i].x+o.x) < min.x) min.x = (float)(p[i].x+o.x);
      if ((p[i].y+o.y - forehead_factor) < min.y) min.y = (float)(p[i].y+o.y - forehead_factor);
    }
    face_shape.endShape(CLOSE);
    popStyle();
    
    center = new Point(min.x + ((max.x - min.x) / 2), min.y + ((max.y - min.y) / 2));//new Point(min.x + d/2, min.y + d/2);
    
    if (debug) {
      pushStyle();
      stroke(200,127,0);
      noFill();
      ellipse((float)max.x, (float)max.y, 10, 10);
      stroke(0,127,200);
      ellipse((float)min.x, (float)min.y, 10, 10);
      fill(0,255,0);
      stroke(0,255,0);
      line((float)max.x, (float)max.y, (float)min.x, (float)min.y);
      //int d = (int) distance((int)max.x, (int)max.y, (int)min.x, (int)min.y);
      ellipse((float)center.x, (float)center.y, 3, 3);
      popStyle();
    }
  }
  
  private void smoothenEdges(PImage img){
    //Mat mat = toMat(img);
    //Columna
    for (int i = 0; i < img.width; i++){
      //Fila
      for (int j = 0; j < img.height; j++){
        int loc = i + j * img.width;
        /*img.pixels[loc] = color(red(img.get(i,j)),
                                green(img.get(i,j)),
                                blue(img.get(i,j)),
                                //map(min(i,j), 
                                //    0, 
                                //    (face_d*1.75)/3, 
                                //    0, 
                                //    255)
                                i*j
                                );*/
          if (i <= img.width/2 && j <= img.height/2) {
            //Superior izquierdo //1.5
            img.pixels[loc] = color(red(img.get(i,j)),green(img.get(i,j)),blue(img.get(i,j)),i*j);
          } else if (i > img.width/2 && j <= img.height/2) {
            //Superior derecho
            img.pixels[loc] = color(red(img.get(i,j)),green(img.get(i,j)),blue(img.get(i,j)),(img.width-i)*j*(50f/face_distance_units));
            //img.pixels[loc] = color(255,0,0);
          } else if (i > img.width/2 && j > img.height/2) {
            //Inferior derecho
            img.pixels[loc] = color(red(img.get(i,j)),green(img.get(i,j)),blue(img.get(i,j)),(img.width-i)*(img.height-j)*(50f/face_distance_units));
          } else if (i <= img.width/2 && j > img.height/2) {
            //Inferior izquierdo
            img.pixels[loc] = color(red(img.get(i,j)),green(img.get(i,j)),blue(img.get(i,j)),i*(img.height-j)*(50f/face_distance_units));
          }
          
      }
    }
    img.updatePixels();
    //return img;
  }
}
