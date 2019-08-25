abstract class Rect {
  PVector o;  //origin
  PVector d;  //direction
  //coefficients
  float a, b, c, m, q;

  Rect(PVector o, PVector d) {
    this.o = o;
    this.d = d;
    updateCoefficients();
  }
  void updateCoefficients() {
    //solving equation of a rect passing between two points
    a = d.y - o.y;
    b = o.x - d.x; 
    c = -o.x*d.y+d.x*o.y;
    m = -a/b;
    q = -c/b;
  }
  float magnitude(float x, float y){
    return sqrt(x*x + y*y);  
  }
}



class Wall extends Rect {
  Wall(PVector start, PVector end) {
    super(start, end);
  }
  void show() {
    line(o.x, o.y, d.x, d.y);
  }
  void updatePosition(float x1, float y1, float x2, float y2){
    o.set(x1,y1);
    d.set(x2,y2);
    updateCoefficients();
  }
  boolean inRange(float x, float y) {
    //We're interested only in point that are on the segment OD
    if (!(x <= max(o.x, d.x) && x >= min(o.x, d.x)))
      return false;
    if (!(y <= max(o.y, d.y) && y >= min(o.y, d.y)))
      return false;
    return true;
  }
}



class Ray extends Rect {
  //sin and cos values for degree
  float sind;
  float cosd;
  //endpoint point
  PVector endpoint = new PVector();

  Ray(PVector o, float degree) {
    super(o, new PVector(sin(radians(degree)), cos(radians(degree))));
    sind = d.x;
    cosd = d.y;
  }
  void show() {
    line(o.x, o.y, endpoint.x, endpoint.y); 
  }
  void updatePosition(float x, float y) {
    o.set(x, y);
    d.set(x + sind, y + cosd);
    updateCoefficients();
    
    if(isRightDirection())
      endpoint.set(width, m*width + q);
    else
      endpoint.set(0, q);
  }
  boolean areParallel(Wall wall) {
    m = (m == Float.POSITIVE_INFINITY || m == Float.NEGATIVE_INFINITY) ? Float.POSITIVE_INFINITY : m;
    wall.m = (wall.m == Float.POSITIVE_INFINITY || wall.m == Float.NEGATIVE_INFINITY) ? Float.POSITIVE_INFINITY : wall.m;
    if (m == wall.m)
      return true;
    return false;
  }
  boolean isRightDirection(){
    //the end point must be in the right direction, described by the vector d
    return (d.x - o.x) > 0;  
  }
  boolean isOnDirection(float x, float y){
    if(isRightDirection())
      return (x < width && x > o.x);
    return (x > 0 && x < o.x);
  }
  void cast(Wall wall) {
    if (!areParallel(wall)) {
      //solving system of equations
      float x = (wall.q - q)/(m - wall.m);
      float y = m*x + q;
      //getting vector pointing from o to d and centered into the origin
      float v1_x = o.x - endpoint.x;
      float v1_y = o.y - endpoint.y;
      if (wall.inRange(x,y) && isOnDirection(x,y)){
        //getting vector pointing to the new position and centered into the origin
        float v2_x = o.x - x;
        float v2_y = o.y - y;
        //if is closer to the origin position, the values are updated
        if(magnitude(v2_x, v2_y) < magnitude(v1_x, v1_y)) 
          endpoint.set(x, y);
      }
    }
  }
}
/*
 *
 *
 *
 *
**/
Ray rays[];
Wall walls[];
int numRays = 240;
int numWalls = 10;
float delta;
PVector endpoint, tmp;

void setup() {
  size(1000, 1000);
  rays = new Ray[numRays];
  walls = new Wall[numWalls];
  delta = 360.0/(float)numRays;
  for (int i = 0; i < rays.length; i++)
    rays[i] = new Ray(new PVector(0, 0), i*delta+.1);
  for(int i = 0; i < walls.length; i++)
    walls[i] = new Wall(new PVector(random(20,width-20), random(20,height-20)), new PVector(random(20,width-20), random(20,height-20)));
}

void draw() {
  background(0);
  stroke(255);
  for(Wall wall: walls)
    wall.show();
  for (Ray ray: rays) {
    ray.updatePosition(mouseX, mouseY);
    for(Wall wall: walls)
      ray.cast(wall);
    ray.show();
  }
}

void mousePressed(){
  for(Wall wall: walls)
    wall.updatePosition(random(20,width-20), random(20,height-20),random(20,width-20), random(20,height-20));
}
