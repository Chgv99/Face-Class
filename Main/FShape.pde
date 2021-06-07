class FShape{
  
  PImage crop;
  
  protected PVector[] contour;
  protected PVector center;
  //protected PShape contourShape;
  protected float camSize;
  
  public FShape(){}
  
  public FShape(PVector[] points){
    contour = points;
    this.camSize = camSize;
  }
  
  public float getCamSize(){
    return camSize;
  }
  
  public void setPoints(PVector[] contour, PImage img, int cam_x, int cam_y){
    setContour(contour);
    setCenter(Expressions.centerOf(contour/*, w, h*/));
    setCrop(img, cam_x, cam_y);
  }
  
  public void setCrop(PImage img, int cam_x, int cam_y) {
    PGraphics maskImage = createGraphics(cam_x, cam_y);  //640, 480
    crop = img.copy();
    maskImage.beginDraw();
    maskImage.beginShape();
    for(PVector p : contour){
      maskImage.vertex(p.x, p.y);
    }
    
    maskImage.endShape(CLOSE);
    maskImage.endDraw();
    // apply mask
    crop.mask(maskImage);
    
  }
  
  public PImage getCrop(){
    println("fshape crop: " + crop);
    return crop;
  }
  
  public PVector[] getContour(){
    return contour;
  }
  
  public void setContour(PVector[] contour){
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
    PVector[] minMax = Expressions.getMinMax(contour);
    return minMax[1].y - minMax[0].y;
  }
  
  /*
  public PVector[] getShape(){
    return contour;
  }
  
  public void setShape(){
    
  }*/
}
