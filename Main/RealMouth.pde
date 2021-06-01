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
  
}
