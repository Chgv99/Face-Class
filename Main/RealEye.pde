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
  
}
