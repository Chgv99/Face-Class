class RealEye extends FShape{
  
  RealFace face;
  
  public RealEye(){
    
  }
  
  public void setFace(RealFace face){
    this.face = face;
  }
  
  public boolean isOpen(){
    return Expressions.isOpen(this);
  }
  
  public RealEye copy(){
    PVector[] contour = new PVector[this.contour.length];
    arrayCopy(this.contour, contour);
    
    RealEye newEye = new RealEye();
    newEye.setPoints(contour);
    return newEye;
  }
  
}
