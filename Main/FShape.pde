class FShape{
  
  protected ArrayList<PVector> contour;
  protected PVector center;
  //protected PShape contourShape;
  
  public FShape(){}
  
  public FShape(ArrayList<PVector> points){
    contour = points;
  }
  
  public void setPoints(ArrayList<PVector> contour, float w, float h){
    setContour(contour);
    setCenter(Expressions.centerOf(contour, w, h));
  }
  
  public ArrayList<PVector> getContour(){
    return contour;
  }
  
  public void setContour(ArrayList<PVector> contour){
    this.contour = contour;
  }
  
  public PVector getCenter(){
    return center;
  }
  
  public void setCenter(PVector center){
    this.center = center;
  }
  
  public PVector getTop(){
    return new PVector();
  }
  
  //TODO: calculate the top and bottom points
  public float verticalAmplitude(){
    //return Expressions.distance(contour[0], contour[0]);
    PVector[] minMax = Expressions.getMinMax(contour, width, height);
    return minMax[1].y - minMax[0].y;
  }
  /*
  public PVector[] getShape(){
    return contour;
  }
  
  public void setShape(){
    
  }*/
}
