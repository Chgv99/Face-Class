import java.lang.*;

Face player_face;

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
  size(640, 480);
  debug = false;
  outlines = false;
  smooth = true;
  cal_i = 0;
  
  position = new Point(width/2, height/2);
  
  //player_face = new Face(this, "DroidCam Source 3", 0.5f, 0.2f, 0.1f, 0.1f);
  player_face = new Face(this, true, 20, "DroidCam Source 3", 0.5f, 0.2f, 0.1f, 0.1f);
  player_face.Process(false);
  println("Initial values:");
  println("Face Center: " + player_face.GetCenter());
  println("Left Eyebrow (Relative): " + (player_face.GetLeftEyebrow().x) +
          ", " + (player_face.GetLeftEyebrow().y));
  println("Right Eyebrow (Relative): " + (player_face.GetRightEyebrow().x) +
          ", " + (player_face.GetRightEyebrow().y));
  println("Left Eye (Relative): " + (player_face.GetLeftEye()[0].x - player_face.GetCenter().x) +
          ", " + (player_face.GetLeftEye()[0].y - player_face.GetCenter().y));
  println("Right Eye (Relative): " + (player_face.GetRightEye()[0].x - player_face.GetCenter().x) +
          ", " + (player_face.GetRightEye()[0].y - player_face.GetCenter().y));
  //player_face.SetNaturalLeftEyebrow(new Point(player_face.GetLeftEyebrow(true).x, player_face.GetLeftEyebrow(true).y));
}

void draw() {  
  player_face.Process(debug);
  /*if (cal_i <= 100){
    player_face.Process(true);
    left_eyebrow_x += player_face.GetLeftEyebrow(true).x;
    left_eyebrow_y += player_face.GetLeftEyebrow(true).y;
    right_eyebrow_x += player_face.GetRightEyebrow(true).x;
    right_eyebrow_y += player_face.GetRightEyebrow(true).y;
    cal_i++;
  } else {
    println("Calibrated left eyebrow: " + left_eyebrow_x / 100 + ", " + left_eyebrow_y / 100);
    println("Calibrated right eyebrow: " + right_eyebrow_x / 100 + ", " + right_eyebrow_y / 100);
    player_face.SetNaturalLeftEyebrow(new Point(left_eyebrow_x, left_eyebrow_y));
    player_face.SetNaturalRightEyebrow(new Point(right_eyebrow_x, right_eyebrow_y));
  }*/
  
  pushStyle();
  //rect(0, height-40, width, 40);
  fill(0,0,0,127);
  rect(width-10-205, 10, 205, 20); //aumentar de 15 en 15?
  popStyle();
  
  textAlign(RIGHT);
  textSize(10);
  text("[D] Debug  [O] Outlines  [S] Smoothness", width-15, 25);
  
  Point left_eye = new Point();
  Point right_eye = new Point();
  
  //Get eyes relatively from the center of the face
  left_eye.x = player_face.GetLeftEye()[0].x - player_face.GetCenter().x;
  left_eye.y = player_face.GetLeftEye()[0].y - player_face.GetCenter().y;
  
  if (debug) {
    /*pushStyle();
    //fill(0,0,0,127);
    fill(0,0,0);
    //rect(0,0,width, height);
    popStyle();*/
    pushStyle();
    fill(0,0,0,127);
    rect(10, 10, 250, 110); //aumentar de 15 en 15?
    popStyle();
    textAlign(LEFT);
    textSize(10);
    text("Face Distance: " + nf(player_face.GetDistanceInCm(),0,2) +
         " cm (" + nf(player_face.GetDistance(),0,2) + " units)", 
         15, 
         25);
    text("Face Center: " + nf((float)player_face.GetCenter().x,0,2) +
         ", " + nf((float)player_face.GetCenter().y,0,2), 
         15, 
         40);
    text("Left Eyebrow (Relative): " + nf((float)player_face.GetLeftEyebrow().x,0,2) +
          ", " + nf((float)player_face.GetLeftEyebrow().y,0,2)+ 
          "(" + player_face.LeftEyebrowIsLifted() + ")",
          15,
          55);
    text("Right Eyebrow (Relative): " + nf((float)player_face.GetRightEyebrow().x,0,2) +
          ", " + nf((float)player_face.GetRightEyebrow().y,0,2)+
          "(" + player_face.RightEyebrowIsLifted() + ")",
          15,
          70);
    text("Left Eye (Relative): " + nf((float)left_eye.x,0,2) +
          ", " + nf((float)left_eye.y,0,2),
          15,
          85);
    right_eye.x = player_face.GetRightEye()[0].x - player_face.GetCenter().x;
    right_eye.y = player_face.GetRightEye()[0].y - player_face.GetCenter().y;
    text("Right Eye (Relative): " + nf((float)right_eye.x,0,2) +
          ", " + nf((float)right_eye.y,0,2),
          15,
          100);
    text("Mouth Amplitude: " + player_face.GetMouthAmplitude(), 
          15, 
          115);
  } else {
    player_face.GetCrop((int)position.x,(int)position.y);
    pushStyle();
    fill(255,0,255);
    noStroke();
    circle((float)position.x + (float)left_eye.x, (float)position.y + (float)left_eye.y, 10);
    popStyle();
  }
  
  if (player_face.MouthIsOpen()){
    pushStyle();
    fill(255,0,0);
    noStroke();
    rect((float)position.x-25, (float)position.y,50, 500);
    popStyle();
  }
    //if (cal_i > 100) println("Calibrated left eyebrow: " + left_eyebrow_x / 100 + ", " + left_eyebrow_y / 100); 
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
