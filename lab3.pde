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

Boid billy;

void setup() {
  size(800, 600);
  randomSeed(0);
  map.generate(-2);
  billy = new Boid(BILLY_START, BILLY_START_HEADING, BILLY_MAX_SPEED, BILLY_MAX_ROTATIONAL_SPEED, BILLY_MAX_ACCELERATION, BILLY_MAX_ROTATIONAL_ACCELERATION);
  
}


void keyPressed()
{
    if (key == 'g')
    {
       map.generate(-2);
    }
}


void draw() {
  background(0);

  float dt = (millis() - lastt)/1000.0;
  lastt = millis();
  
  map.update(dt);  
}
