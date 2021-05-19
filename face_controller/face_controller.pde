import java.lang.*;

Face player_face;

Point position;

// DEBUG
boolean debug, outlines, smooth;

void setup() {
  size(640, 480);
  debug = false;
  outlines = false;
  smooth = true;
  filter = 0;
  
  position = new Point(width/2, height/2);
  
  player_face = new Face(this, "DroidCam Source 3", 0.5f, 0.2f, 0.1f, 0.1f);
}

void draw() {  
  player_face.Process(debug);
  
  pushStyle();
  //rect(0, height-40, width, 40);
  fill(0,0,0,127);
  rect(width-10-205, 10, 205, 20); //aumentar de 15 en 15?
  popStyle();
  
  textAlign(RIGHT);
  textSize(10);
  text("[D] Debug  [O] Outlines  [S] Smoothness", width-15, 25);
  
  if (debug) {
    /*pushStyle();
    //fill(0,0,0,127);
    fill(0,0,0);
    //rect(0,0,width, height);
    popStyle();*/
    pushStyle();
    fill(0,0,0,127);
    rect(10, 10, 250, 50); //aumentar de 15 en 15?
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
    text("Mouth Amplitude: " + player_face.GetMouthAmplitude(), 15, 55);
  } else player_face.GetCrop((int)position.x,(int)position.y);
  
  stroke(255,0,0);
  //line(width/2, 0, width/2, height);
  //line(0, height/2, width, height/2);
  
  if (player_face.MouthIsOpen()){
    pushStyle();
    fill(255,0,0);
    noStroke();
    rect((float)position.x-25, (float)position.y,50, 500);
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
      smooth = !smooth;
    }
  }
}
