static class Expressions{
  
  /*public static boolean mouthIsOpen(){
    return mouth_amplitude > 0.5f;
  }
  
  public static boolean eyeIsOpen(){
    return mouth_amplitude > 0.5f;
  }*/
  
  public static float verticalAmplitude(FShape shape){
    /*if (shape instanceof RealFace){
      
    }*/
    if (shape != null) {
      int size = shape.getContour().size();
      PVector a = null;
      PVector b = null;
      int aux;
      if((size/4)%1 != 0) aux = (int)Math.ceil(size/4);  
      else aux = (int)Math.ceil((size/4)+1);
      a = shape.getContour().get(aux);
      b = shape.getContour().get(aux + (size/2));

      return dist(a.x, a.y, b.x, b.y);
    }
    return -1;
  }
  
  public static boolean isOpen(FShape shape){
    if (verticalAmplitude(shape) > 2) return true;
    return false;
  }
  
  /**
    * Checks if the eyebrow is lifted
    * side = 0: left eyebrow
    * side = 1: right eyebrow
    */
  //public static boolean eyebrowIsLifted(RealEyebrow eyebrow, int side) {return true;}
  public static boolean eyebrowIsLifted(RealEyebrow eyebrow, int side){
    if (eyebrow != null) {
      if (eyebrow.getFace().getCenter().y - eyebrow.getTop().y);
      
      switch (side){
        case 0: //left
          /*int size = eyebrow.getContour().size();
          PVector a = null;
          PVector b = null;
          if((size/4)%1 != 0) a = eyebrow.getContour().get((int)Math.ceil(size/4));
          else b = eyebrow.getContour().get((int)Math.ceil((size/4)+1));
          float d = dist(a.x, a.y, b.x, b.y);
          if (d > 2) return true;*/
          break;
        case 1: //right
          /*int size = shape.getContour().length;
          PVector a = null;
          PVector b = null;
          if((size/4)%1 != 0) a = shape.getContour()[(int)Math.ceil(size/4)];
          else b = shape.getContour()[(int)Math.ceil((size/4)+1)];
          float d = dist(a.x, a.y, b.x, b.y);
          if (d > 2) return true;*/
          break;
      }
    }
    return false;
  }
  
  public static PVector centerOf(ArrayList<PVector> contour, float w, float h){
    if (contour != null){
      /**PVector max = contour[0];
      PVector min = contour[0];**/
      PVector max = new PVector(0,0);
      PVector min = new PVector(w, h);
      for (PVector point : contour){
        if (point.x > max.x) max.x = point.x;
        if (point.y > max.y) max.y = point.y;
        if (point.x < min.x) min.x = point.x;
        if (point.y < min.y) min.y = point.y;
      }
      return new PVector(min.x + ((max.x - min.x) / 2), min.y + ((max.y - min.y) / 2));//new Point(min.x + d/2, min.y + d/2);
    }
    return null;
  }
  
  public static float distance(FShape a, FShape b){
    println("FShape a = " + a.getCenter());
    println("FShape b = " + b.getCenter());
    println(dist(a.getCenter().x, a.getCenter().y, b.getCenter().x, b.getCenter().y));
    return dist(a.getCenter().x, a.getCenter().y, b.getCenter().x, b.getCenter().y);
  }
  
  public static float distance(PVector a, PVector b){
    return dist(a.x, a.y, b.x, b.y);
  }
  
  /**
    * Distance in centimeters from the camera
    */
  //calibrationFactor = 2900 en las pruebas
  public static float distanceFromCamera(float calibrationFactor, float reference){
    return calibrationFactor / reference;
  }
  
  public static float rotationOf(RealFace face){
    PVector line = PVector.sub(face.getCenter(),face.getChin());
    return PVector.angleBetween(line, new PVector(10,0));
  }
  
  public static PVector makeRelative(PVector v, PVector center){
    return PVector.sub(v, center);
  }
}
