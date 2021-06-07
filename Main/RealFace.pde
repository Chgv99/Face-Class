class RealFace extends FShape{
  
  float reference;
  float forehead;
  
  RealEyebrow leftEyebrow;
  RealEyebrow rightEyebrow;
  RealEye leftEye;
  RealEye rightEye;
  RealMouth mouth;
  
  //PVector[] vertical;
  //PVector chin;
  
  public RealFace(){
    
  }
  
  public RealFace(RealEyebrow leftEyebrow, RealEyebrow rightEyebrow, RealEye leftEye, RealEye rightEye, RealMouth mouth, PImage img){
    this(leftEyebrow, rightEyebrow, leftEye, rightEye, mouth);
  }
  
  public RealFace(RealEyebrow leftEyebrow, RealEyebrow rightEyebrow, RealEye leftEye, RealEye rightEye, RealMouth mouth){
    this.leftEyebrow = leftEyebrow;
    this.rightEyebrow = rightEyebrow;
    this.leftEye = leftEye;
    this.rightEye = rightEye;
    this.mouth = mouth;
    setReference();
    setVertical();
  }
  
  @Override
  public void setPoints(PVector[] contour, PImage img, int cam_x, int cam_y){
    setContour(contour);
    setCenter(Expressions.centerOf(contour));
    setCrop(img, cam_x, cam_y);
    setReference();
  }
  
  public RealFace copy(PImage img, int cam_x, int cam_y){
    //println("img reference " + img);
    //this.img = img;
    PVector[] contour = new PVector[this.contour.length];
    arrayCopy(this.contour, contour);
    RealFace faceCopy = new RealFace(leftEyebrow.copy(img, cam_x, cam_y), rightEyebrow.copy(img, cam_x, cam_y), leftEye.copy(img, cam_x, cam_y), rightEye.copy(img, cam_x, cam_y), mouth.copy(img, cam_x, cam_y), img);
    faceCopy.setPoints(contour, img, (int)cam_x, (int)cam_y);
    return faceCopy;
  }
  
  public void print(){
    println("Face: ", this);
    if (contour != null) {
      println("Contour: ");
      for (PVector p : contour){
        println(p.x + ", " + p.y);
      }
    } else {
      println("Contour: null");
    }
    if (leftEyebrow != null && rightEyebrow != null) println("Eyebrows: " + leftEyebrow + ", " + rightEyebrow);
    else println("Eyebrows: null");
    if (leftEye != null && rightEye != null) println("Eye: " + leftEye + ", " + rightEye);
    else println("Eyes: null");
    if (mouth != null) println("Mouth: " + mouth);
    else println("Mouth: null");
    /*if (chin != null) println("Chin: " + chin);
    else println("Chin: null");*/
  }
  
  public float getReference(){
    return reference;
  }
  
  public void setReference(){
    if (leftEye.getCenter() != null && rightEye.getCenter() != null){
      reference = Expressions.distance(leftEye, rightEye);
    } else {
      reference = -1;
    }
  }
  
  public PVector[] getVertical(){
    return null;
  }
  
  public void setVertical(){
    reference = Expressions.distance(leftEye, rightEye);
  }
  
  public RealEyebrow getLeftEyebrow(){
    return leftEyebrow;
  }
  
  public void setLeftEyebrow(RealEyebrow leftEyebrow, float camSize){
    this.leftEyebrow = leftEyebrow;
    leftEyebrow.setFace(this, camSize);
  }
  
  public RealEyebrow getRightEyebrow(){
    return rightEyebrow;
  }
  
  public void setRightEyebrow(RealEyebrow rightEyebrow, float camSize){
    this.rightEyebrow = rightEyebrow;
    rightEyebrow.setFace(this, camSize);
  }
  
  public RealEye getLeftEye(){
    return leftEye;
  }
  
  public void setLeftEye(RealEye leftEye, float camSize){
    this.leftEye = leftEye;
    leftEye.setFace(this, camSize);
  }
  
  public RealEye getRightEye(){
    return rightEye;
  }
  
  public void setRightEye(RealEye rightEye, float camSize){
    this.rightEye = rightEye;
    rightEye.setFace(this, camSize);
  }
  
  public RealMouth getMouth(){
    return mouth;
  }
  
  public void setMouth(RealMouth mouth, float camSize){
    this.mouth = mouth;
    mouth.setFace(this, camSize);
  }
  
  /*public PVector getChin(){
    return chin;
  }*/
  
  /*public void setChin(RealMouth mouth){
    chin = contour[0];
  }*/
  
  /*public PImage getImage(){
    //println("img crop copy: " + img);
    return img;
  }*/
}
