import java.lang.*;

PlayerFace player_face;

void setup() {
  size(640, 480);
  debug = false;
  outlines = false;
  smooth = true;
  filter = 0;
  
  player_face = new PlayerFace(this);
}

void draw() {  
  player_face.Process();
  
  if (player_face.MouthIsOpen()){
    pushStyle();
    fill(255,0,0);
    rect(50,50,width/2, height/2);
    popStyle();
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
