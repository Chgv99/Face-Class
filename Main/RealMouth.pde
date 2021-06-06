class RealMouth extends FShape{
  
  RealFace face;
  
  public RealMouth(){
    
  }
  
  public void setFace(RealFace face){
    this.face = face;
  }
  
  public boolean isOpen(){
    return Expressions.isOpen(this);
  }
  
  public RealMouth copy(){
    PVector[] contour = new PVector[this.contour.length];
    arrayCopy(this.contour, contour);
    
    RealMouth newMouth = new RealMouth();
    newMouth.setPoints(contour);
    return newMouth;
  }
  
}
