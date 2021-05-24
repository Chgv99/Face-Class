/** TODO
  * Devolver coordenadas de los elementos faciales (boca, cejas)
  * Para ello deberá usarse una coordenada relativa al
  * centro de la cara (center), para mayor facilidad de uso.
  * Extraer el concepto de DEBUG de esta clase (se está usando
  * un booleano de la clase superior).
  * Introducir métodos SetNatural...() para modificar
  * valores naturales.
  * No se detecta bien el levantamiento de ceja.
  * Asegurar enlaces del readme.
  * Documentar clases nuevas.
  * Devolver información acerca de las cejas.
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

class Face{
  
  Point[] contour = new Point[27];
  
  private Capture cam;
  private CVImage img;
  
  PGraphics maskImage;
  
  //FACE
  //Point v1, v2, v3, v4;  //Face vertices
  Point center;
  private float face_distance_units, face_distance_cm;
  private float upper_offset;
  private float lower_offset;
  private float left_offset;
  private float right_offset;
  
  //Eyebrows
  private Point left_eyebrow_n;
  private Point right_eyebrow_n;
  
  private ArrayList<Point> left_eyebrow;
  private ArrayList<Point> right_eyebrow;
  private int buffer_size;
  
  //EYES
  //PImage left_eye, right_eye;
  //int left_eye_left_x, left_eye_left_y, right_eye_left_x, right_eye_left_y, eyeb_y;
  private Point[] left_eye = new Point[9];
  private Point[] right_eye = new Point[9];
  
  //MOUTH
  //float alpha_product;
  PImage mouth;
  private int mouth_x, mouth_y, mouth_min_x, mouth_max_x, mouth_min_y, mouth_max_y;
  private float mouth_amplitude;
  private float mouth_threshold;
  
  private float left_eyebrow_height;
  private float right_eyebrow_height;
  
  private ArrayList<Point> left_eyebrow_buffer;
  private ArrayList<Point> right_eyebrow_buffer;
  private float cal_buffer_size = -1;
  
  /**
    * Constructor overload that allows to enable or
    * disable an initial calibration for better results.
    * Calls main constructor and then executes the
    * calibration.
    **/
  public Face(PApplet parent, boolean calibration, int cal_threshold, String camera, float upper_offset, float lower_offset,  float left_offset, float right_offset){
    this(parent, camera, upper_offset, lower_offset, left_offset, right_offset);
    if (calibration) {
      left_eyebrow_buffer = new ArrayList();
      right_eyebrow_buffer = new ArrayList();
      cal_buffer_size = cal_threshold;
    }
  }
  
  /**
    * Main constructor.
    **/
  public Face(PApplet parent, String camera, float upper_offset, float lower_offset,  float left_offset, float right_offset){
    //Camera
    cam = null;
    while (cam == null) cam = new Capture(parent, width , height, camera);
    cam.start(); 
    
    //OpenCV
    //Loads OPENCV library
    System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    println(Core.VERSION);
    img = new CVImage(cam.width, cam.height);
    
    //Detectors and mask model
    faceFile = "haarcascade_frontalface_default.xml";
    //faceFile = "new_cascades_cuda/haarcascade_frontalface_alt_tree.xml";
    modelFile = "face_landmark_model.dat";
    fm = org.opencv.face.Face.createFacemarkKazemi();
    fm.loadModel(dataPath(modelFile));
    
    //Face contour shape for cropping.
    for (int i = 0; i < 27; i++){
      contour[i] = new Point(0,0);
    }
    
    //Variables
    this.upper_offset = upper_offset;
    this.lower_offset = lower_offset;
    this.left_offset = left_offset;
    this.right_offset = right_offset;
    
    /** Natural variables. (default values) 
      * These are the natural values of a 
      * face at "rest". These will change 
      * after calibrating.**/
    left_eyebrow_n = new Point(-40,-90);
    right_eyebrow_n = new Point(40,-90);
    
    //Buffers that help getting rid of
    //spurious pulses.
    left_eyebrow = new ArrayList();
    right_eyebrow = new ArrayList();
    buffer_size = 1;
  }
  
  private void Process(boolean display){
    if (cam.available()) {
      background(0);
      cam.read();
      
      //Get image from cam
      img.copy(cam, 0, 0, cam.width, cam.height, 
      0, 0, img.width, img.height);
      img.copyTo();
      
      //Input image
      if (display) image(img,0,0);
      
      //Fiducial point detection
      ArrayList<MatOfPoint2f> shapes = detectFacemarks(cam);
      PVector origin = new PVector(0, 0);
      
      for (MatOfPoint2f sh : shapes) {
          Point [] pts = sh.toArray();
          drawFacemarks(pts, origin);
          //shape(face_shape);
      }
      
      //Face distance reference (from drawFacemarks()) 
      if (left_eye != null & right_eye != null) face_distance_units = distance((int)left_eye[1].x,(int)left_eye[1].y,(int)right_eye[1].x,(int)right_eye[1].y);
      face_distance_cm = 2900 / face_distance_units;
      mouth_amplitude = distance(mouth_max_x, mouth_max_y, mouth_min_x, mouth_min_y) / face_distance_units;
    }
    
    if (cal_buffer_size > -1) Calibrate();
  }
  
  /** Calibration consists of a process in which
    * the program stores multiple values of the
    * desired parts of the face and at the end
    * calculates the mean. **/
  public void Calibrate(){
    println("calibrating");
    // If the buffer is full
    if (CalibrateAux()){
      float leb_x = 0;
      float leb_y = 0;
      float reb_x = 0;
      float reb_y = 0;
      for (int i = 0; i < left_eyebrow_buffer.size(); i++){
        //println(left_eyebrow_buffer.get(i) + ", ");
        leb_x += left_eyebrow_buffer.get(i).x;
        leb_y += left_eyebrow_buffer.get(i).y;
        reb_x += right_eyebrow_buffer.get(i).x;
        reb_y += right_eyebrow_buffer.get(i).y;
      }
      leb_x /= cal_buffer_size;
      leb_y /= cal_buffer_size;
      reb_x /= cal_buffer_size;
      reb_y /= cal_buffer_size;
      //Points are stored relative to the center of the face
      //and divided by the face distance.
      left_eyebrow_n = new Point((leb_x - center.x) / face_distance_units, (leb_y - center.y) / face_distance_units);
      right_eyebrow_n = new Point((reb_x - center.x) / face_distance_units, (reb_y - center.y) / face_distance_units);
      println("Calibration data: ");
      println("leb: " + leb_x + ", " + leb_y);
      println("reb: " + reb_x + ", " + reb_y);
      println("Natural Left Eyebrow: " + left_eyebrow_n.x + ", " + left_eyebrow_n.y);
      println("Natural Right Eyebrow: " + right_eyebrow_n.x + ", " + right_eyebrow_n.y);
      cal_buffer_size = -1;
    }
  }
  
  private boolean CalibrateAux(){
    //println(left_eyebrow_buffer.size());
    if (left_eyebrow_buffer.size() < cal_buffer_size) {
      left_eyebrow_buffer.add(GetLeftEyebrow());
      right_eyebrow_buffer.add(GetRightEyebrow());
      return false;
    } else {
      left_eyebrow_buffer.remove(0);
      right_eyebrow_buffer.remove(0);
      left_eyebrow_buffer.add(GetLeftEyebrow());
      right_eyebrow_buffer.add(GetRightEyebrow());
      println("Calibration buffer ready");
      return true;
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
  
  public Point[] GetLeftEye(){
    return left_eye;
  }
  
  public Point[] GetRightEye(){
    return right_eye;
  }
  
  public boolean LeftEyebrowIsLifted(){
    //println(GetLeftEyebrow().x + ", " + GetLeftEyebrow().y);
    //println(GetRightEyebrow().x + ", " + GetRightEyebrow().y);
    println("left_eyebrow.y = " + GetLeftEyebrow().y); //Media de puntos restados al centro sin dividir por la unidad de cara
    println("left_eyebrow_n.y = " + left_eyebrow_n.y);  //Media de puntos restados al centro divididos por la unidad de cara
    println(abs((float)GetLeftEyebrow().y  - (float)left_eyebrow_n.y));
    return (abs((float)GetLeftEyebrow().y  - (float)left_eyebrow_n.y)) > 1;
  }
  
  public boolean RightEyebrowIsLifted(){
    //return GetRightEyebrow().y - right_eyebrow_n.y > 5;
    
    println("left_eyebrow.y = " + GetRightEyebrow().y); //Media de puntos restados al centro sin dividir por la unidad de cara
    println("left_eyebrow_n.y = " + right_eyebrow_n.y);  //Media de puntos restados al centro divididos por la unidad de cara
    println(abs((float)GetRightEyebrow().y  - (float)right_eyebrow_n.y));
    return (abs((float)GetRightEyebrow().y  - (float)right_eyebrow_n.y)) > 1;
  }
  
  public Point GetLeftEyebrow(){
    if (left_eyebrow.size() < buffer_size) return left_eyebrow.get(0);
    else {
      float aux_x = 0;
      float aux_y = 0;
      for (int i = 0; i < left_eyebrow.size(); i++){
        //println(left_eyebrow.get(i) + ", ");
        aux_x += left_eyebrow.get(i).x;
        aux_y += left_eyebrow.get(i).y;
      }
      aux_x /= buffer_size;
      aux_y /= buffer_size;
      println("aux_x: " + aux_x / buffer_size + " aux_y: " + aux_y / buffer_size);
      println("end of buffer (left_eyebrow) size: " + buffer_size);
      //noLoop();
      return new Point((aux_x - center.x) / face_distance_units, (aux_y - center.y) / face_distance_units);
    }
  }
  
  public Point GetRightEyebrow(){
    if (right_eyebrow.size() < buffer_size) return right_eyebrow.get(0);
    else {
      float aux_x = 0;
      float aux_y = 0;
      for (int i = 0; i < right_eyebrow.size(); i++){
        aux_x += right_eyebrow.get(i).x;
        aux_y += right_eyebrow.get(i).y;
      }
      aux_x /= buffer_size;
      aux_y /= buffer_size;
      return new Point((aux_x - center.x) / face_distance_units, (aux_y - center.y) / face_distance_units);
    }
  }
  
  private void AddLeftEyebrow(Point point){
    if (left_eyebrow.size() < buffer_size) {
      left_eyebrow.add(point);
    } else {
      left_eyebrow.remove(0);
      left_eyebrow.add(point);
    }
  }
  
  private void AddRightEyebrow(Point point){
    if (right_eyebrow.size() < buffer_size) {
      right_eyebrow.add(point);
    } else {
      right_eyebrow.remove(0);
      right_eyebrow.add(point);
    }
  }
  
  public float GetMouth(){
    return -1;
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
  
  public void SetNaturalLeftEyebrow(Point point){
    left_eyebrow_n = point;
  }
  
  public void SetNaturalRightEyebrow(Point point){
    right_eyebrow_n = point;
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
    
    Point left_eyebrow_aux = new Point();
    Point right_eyebrow_aux = new Point();
    
    for (int i = 0; i < p.length; i++) {
      Point pt = p[i];
      face_shape.vertex((float)pt.x+o.x, (float)pt.y+o.y);
      //ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
      if (i == 19) {
        //Left eyebrow
        stroke(0,0,255);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 5, 5);
        left_eyebrow_aux = new Point((float)pt.x+o.x, (float)pt.y+o.y);
      } else if (i == 24) {
        //Right eyebrow
        stroke(0,0,255);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 5, 5);
        right_eyebrow_aux = new Point((float)pt.x+o.x, (float)pt.y+o.y);
      } else if (i == 42) {
        //Right eye's leftmost vertex
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        //right_eye_left_x = (int)(pt.x+o.x);
        //right_eye_left_y = (int)(pt.y+o.y);
        right_eye[1] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 43) {
        //Right eye's leftmost vertex
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        right_eye[2] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 44) {
        //Right eye's leftmost vertex
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        right_eye[4] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 45) {
        //Right eye's leftmost vertex
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        right_eye[5] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 46) {
        //Right eye's leftmost vertex
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        right_eye[6] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 47) {
        //Right eye's leftmost vertex
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        right_eye[8] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 36) {
        stroke(255,0,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        //left_eye_left_x = (int)(pt.x+o.x);
        //left_eye_left_y = (int)(pt.y+o.y);
        left_eye[1] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 37) {
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        left_eye[2] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 38) {
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        left_eye[4] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 39) {
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        left_eye[5] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 40) {
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        left_eye[6] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
      } else if (i == 41) {
        stroke(255,255,0);
        if (debug) ellipse((float)pt.x+o.x, (float)pt.y+o.y, 3, 3);
        left_eye[8] = new Point((int)(pt.x+o.x), (int)(pt.y+o.y));
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
    left_eye[3] = new Point(left_eye[2].x + ((left_eye[4].x - left_eye[2].x) / 2), left_eye[2].y + ((left_eye[4].y - left_eye[2].y) / 2));
    left_eye[7] = new Point(left_eye[6].x + ((left_eye[8].x - left_eye[6].x) / 2), left_eye[6].y + ((left_eye[8].y - left_eye[6].y) / 2));
    left_eye[0] = new Point(left_eye[7].x + ((left_eye[3].x - left_eye[7].x) / 2), left_eye[3].y + ((left_eye[7].y - left_eye[3].y) / 2));
    
    right_eye[3] = new Point(right_eye[2].x + ((right_eye[4].x - right_eye[2].x) / 2), right_eye[2].y + ((right_eye[4].y - right_eye[2].y) / 2));
    right_eye[7] = new Point(right_eye[6].x + ((right_eye[8].x - right_eye[6].x) / 2), right_eye[6].y + ((right_eye[8].y - right_eye[6].y) / 2));
    right_eye[0] = new Point(right_eye[7].x + ((right_eye[3].x - right_eye[7].x) / 2), right_eye[3].y + ((right_eye[7].y - right_eye[3].y) / 2));
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
    AddLeftEyebrow(new Point(left_eyebrow_aux.x - center.x, left_eyebrow_aux.y - center.y));
    AddRightEyebrow(new Point(right_eyebrow_aux.x - center.x, right_eyebrow_aux.y - center.y));
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
