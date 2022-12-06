/// You do not need to change anything in this file, but you can
/// For example, if you want to add additional options controllable by keys
/// keyPressed would be the place for that.

ArrayList<PVector> waypoints = new ArrayList<PVector>();
int lastt;

int mapnr = 0;


boolean entering_path = false;

boolean show_nav_mesh = true;

boolean show_waypoints = true;

boolean show_help = false;

boolean flocking_enabled = false;

Map map = new Map();
NavMesh nm = new NavMesh();


Boid billy;

void setup() {
  size(800, 600);
  randomSeed(0);
  map.generate(-2);
  billy = new Boid(BILLY_START, BILLY_START_HEADING, BILLY_MAX_SPEED, BILLY_MAX_ROTATIONAL_SPEED, BILLY_MAX_ACCELERATION, BILLY_MAX_ROTATIONAL_ACCELERATION);
  
}

void mousePressed() 
{
  if (show_help) return;
  PVector target = new PVector(mouseX, mouseY);
  //if (!map.isReachable(target)) return;
  if (mouseButton == LEFT)
  {
     
     if (waypoints.size() == 0)
     {
        billy.seek(target);
     }
     else
     {
       //ArrayList<PVector> pathfinding = nm.findPath(waypoints.get(waypoints.size()-1), target);
       //for(int i = 0; i < pathfinding.size(); i++)
       //{
       //  waypoints.add(pathfinding.get(i));
       //}
        waypoints.add(target);
        entering_path = false;
        billy.follow(waypoints);
     }
  }
  else if (mouseButton == RIGHT)
  {
     if (!entering_path){
        waypoints = new ArrayList<PVector>();
        //ArrayList<PVector> pathfinding = nm.findPath(billy.kinematic.position, target);
        //waypoints = pathfinding;
      }
     else
     {
       print("Adding additional path");
       //ArrayList<PVector> pathfinding = nm.findPath(waypoints.get(waypoints.size()-1), target);
       //for(int i = 0; i < pathfinding.size(); i++)
       //{
       //  waypoints.add(pathfinding.get(i));
       //}
     }
     waypoints.add(target);
     entering_path = true; 
  }
}

void keyPressed()
{
    if (key == 'g')
    {
       map.generate(-2);
    }
    else if (key == 'w')
    {
       show_waypoints = !show_waypoints;
    }
}


void draw() {
  background(0);

  float dt = (millis() - lastt)/1000.0;
  billy.update(dt);
  lastt = millis();
  
  map.update(dt);  
  
  //Implementation to show waypoints
  if(waypoints!=null){
    for(PVector point: waypoints)
    {
      stroke(255);
      circle(point.x, point.y, 5);
    }
  }
}
