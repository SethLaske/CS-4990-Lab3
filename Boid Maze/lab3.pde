/// You do not need to change anything in this file, but you can
/// For example, if you want to add additional options controllable by keys
/// keyPressed would be the place for that.

ArrayList<PVector> waypoints = new ArrayList<PVector>();
int lastt;

boolean entering_path = false;
boolean show_waypoints = true;

Boid billy;

Map map = new Map();
NavMesh nm = new NavMesh();

void setup() {
  size(800, 600);
  randomSeed(0);
  map.generate(-2);
  nm.bake(map);
  billy = new Boid(BILLY_START, BILLY_START_HEADING, BILLY_MAX_SPEED, BILLY_MAX_ROTATIONAL_SPEED, BILLY_MAX_ACCELERATION, BILLY_MAX_ROTATIONAL_ACCELERATION);
}


void keyPressed()
{
    if (key == 'g')
    {
       map.generate(-2);
       nm.bake(map);
    }else if (key == 'w')
  {
    show_waypoints = !show_waypoints;
  } 
}

void mousePressed() {
  
  PVector target = new PVector(mouseX, mouseY);
  if (!map.isReachable(target)) return;
  if (mouseButton == LEFT)
  {

    if (waypoints.size() == 0)
    {
      billy.seek(target);
    } else
    {
      ArrayList<PVector> pathfinding = nm.findPath(waypoints.get(waypoints.size()-1), target);
      for (int i = 0; i < pathfinding.size(); i++) {
        waypoints.add(pathfinding.get(i));
      }
      waypoints.add(target);
      entering_path = false;
      billy.follow(waypoints);
    }
  } else if (mouseButton == RIGHT)
  {
    
    
    if (!entering_path) {
      waypoints = new ArrayList<PVector>();
      ArrayList<PVector> pathfinding = nm.findPath(billy.kinematic.position, target);
      waypoints = pathfinding;
    } else {
      print("Adding additional path");
      ArrayList<PVector> pathfinding = nm.findPath(waypoints.get(waypoints.size()-1), target);
      for (int i = 0; i < pathfinding.size(); i++) {
        waypoints.add(pathfinding.get(i));
      }
    }
    waypoints.add(target);
    entering_path = true;
    
    
  }
}

void draw() {
  background(0);

  float dt = (millis() - lastt)/1000.0;
  lastt = millis();
  
  map.update(dt);  
  
  if (entering_path || show_waypoints)
  {
    if (waypoints!=null) {
      for (PVector point : waypoints) {
        stroke(255);
        circle(point.x, point.y, 5);
      }
    }
    stroke(255, 0, 0);
    strokeWeight(1);
    PVector current = billy.kinematic.position;
    if (show_waypoints && billy.target != null)
    {
      line(current.x, current.y, billy.target.x, billy.target.y);

      //troubleshooting by creating compass around points
      //draw compass
      //stroke(0,0,255);
      //line(current.x, current.y, current.x + 50, current.y);
      //line(current.x, current.y, current.x - 50, current.y);
      //line(current.x, current.y, current.x, current.y + 50);
      //line(current.x, current.y, current.x, current.y - 50);
      stroke(255, 0, 0);

      current = billy.target;
    }
    for (PVector wp : waypoints)
    {
      line(current.x, current.y, wp.x, wp.y);
      current = wp;
      //draw compass
      //line(wp.x, wp.y, wp.x + 50, wp.y);
      //line(wp.x, wp.y, wp.x - 50, wp.y);
      //line(wp.x, wp.y, wp.x, wp.y + 50);
      //line(wp.x, wp.y, wp.x, wp.y - 50);
    }
    if (entering_path)
      line(current.x, current.y, mouseX, mouseY);
  }


  
  billy.update(dt);
  
  
}
