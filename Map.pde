import java.util.*;
//Map doesnt need anything from lab 1

/// You do not have to change this file, but you can, if you want to add a more sophisticated generator.
class Wall
{
   PVector start;
   PVector end;
   PVector normal;
   PVector direction;
   float len;
   int ID;  //ID will be used to distinguish split walls from the rest of the walls
   
   Wall(PVector start, PVector end)
   {
      this.start = start;
      this.end = end;
      direction = PVector.sub(this.end, this.start);
      len = direction.mag();
      direction.normalize();
      normal = new PVector(-direction.y, direction.x);
      this.ID = 0;
   }
   
   void setID(int ID){
     this.ID = ID;
   }
   
   int getID(){
     return ID;
   }
   
   boolean crosses(PVector from, PVector to)
   {
      // Vector pointing from `this.start` to `from`
      PVector d1 = PVector.sub(from, this.start);
      // Vector pointing from `this.start` to `to`
      PVector d2 = PVector.sub(to, this.start);
      // If both vectors are on the same side of the wall
      // their dot products with the normal will have the same sign
      // If they are both positive, or both negative, their product will
      // be positive.
      float dist1 = normal.dot(d1);
      float dist2 = normal.dot(d2);
      if (dist1 * dist2 > 0) return false;
      
      // if the start and end are on different sides, we need to determine 
      // how far the intersection point is along the wall
      // first we determine how far the projections of from and to are 
      // along the wall
      float ldist1 = direction.dot(d1);
      float ldist2 = direction.dot(d2);
      
      // the distance of the intersection point from the start
      // is proportional to the normal distance of `from` in 
      // along the total movement
      float t = dist1/(dist1 - dist2);

      // calculate the intersection as this proportion
      float intersection = ldist1 + t*(ldist2 - ldist1);
      if (intersection < 0 || intersection > len) return false;
      return true;      
   }
   
   // Return the mid-point of this wall
   PVector center()
   {
      return PVector.mult(PVector.add(start, end), 0.5);
   }
   
   void draw()
   {
       strokeWeight(3);
       line(start.x, start.y, end.x, end.y);
       if (SHOW_WALL_DIRECTION)
       {
          PVector marker = PVector.add(PVector.mult(start, 0.2), PVector.mult(end, 0.8));
          circle(marker.x, marker.y, 5);
       }
   }
}

void AddPolygon(ArrayList<Wall> walls, PVector[] nodes)
{
    for (int i = 0; i < nodes.length; ++ i)
    {
       int next = (i+1)%nodes.length;
       walls.add(new Wall(nodes[i], nodes[next]));
    }
}

void AddPolygonScaled(ArrayList<Wall> walls, PVector[] nodes)
{
    for (int i = 0; i < nodes.length; ++ i)
    {
       int next = (i+1)%nodes.length;
       walls.add(new Wall(new PVector(nodes[i].x*width, nodes[i].y*height), new PVector(nodes[next].x*width, nodes[next].y*height)));
    }
}


// Given a (closed!) polygon surrounded by walls, tests if the
// given point is inside that polygon.
// Note that this only works for polygons that are inside the
// visible screen (or not too far outside)
boolean isPointInPolygon(PVector point, ArrayList<Wall> walls)
{
   // we create a test point "far away" horizontally
   PVector testpoint = PVector.add(point, new PVector(width*2, 0));
   
   // Then we count how often the line from the given point
   // to our test point intersects the polygon outline
   int count = 0;
   for (Wall w: walls)
   {
      if (w.crosses(point, testpoint))
         count += 1;
   }
   
   // If we cross an odd number of times, we started inside
   // otherwise we started outside the polygon
   // Intersections alternate between enter and exit,
   // so if we "know" that the testpoint is outside
   // and odd number means we exited one more time 
   // than we entered.
   return (count%2) == 1;
}
//The different nodes that will be used
class MazeCell{

  PVector location;  //center of the grid
  ArrayList<Wall> walls; 
  ArrayList<MazeCell> neighbors;
  ArrayList<MazeCell> connectedCells;
  
  boolean visited;
  boolean started;
  MazeCell parentCell;
  
  MazeCell(PVector center){
    location = center;
    walls = new ArrayList<Wall>();
    neighbors = new ArrayList<MazeCell>();
    connectedCells = new ArrayList<MazeCell>();
    
    visited = false;
    started = false;
    //addFakeWalls();
  }
  
  void addFakeWalls(){
    PVector topLeft = new PVector (location.x - (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      PVector topRight = new PVector (location.x + (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      PVector bottomRight = new PVector (location.x + (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      PVector bottomLeft = new PVector (location.x - (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      
      walls.add(new Wall(topLeft, topRight));
      walls.add(new Wall(topRight, bottomRight));
      walls.add(new Wall(bottomRight, bottomLeft));
      walls.add(new Wall(bottomLeft, topLeft));
  }
  
  void addLeftWall(){
    PVector topLeft = new PVector (location.x - (GRID_SIZE/2), location.y - (GRID_SIZE/2));
    PVector bottomLeft = new PVector (location.x - (GRID_SIZE/2), location.y + (GRID_SIZE/2));
    
    walls.add(new Wall(bottomLeft, topLeft));
  }
  
  void addRightWall(){
    PVector topRight = new PVector (location.x + (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      PVector bottomRight = new PVector (location.x + (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      
      walls.add(new Wall(topRight, bottomRight));
  }
  
  void addTopWall(){
    PVector topLeft = new PVector (location.x - (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      PVector topRight = new PVector (location.x + (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      
      walls.add(new Wall(topLeft, topRight));
  }
  
  void addBottomWall(){
    PVector bottomRight = new PVector (location.x + (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      PVector bottomLeft = new PVector (location.x - (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      
      walls.add(new Wall(bottomRight, bottomLeft));
  }
  
  

}

class Map
{
   ArrayList<Wall> mazeWalls;
   ArrayList<Wall> primWalls;
   ArrayList<MazeCell> primNodes;
   //HashMap <Wall, MazeCell> primMap;
   ArrayList<Wall> borders;
   ArrayList<MazeCell> nodes;
   MazeCell[][] nodearray;  //I think this one will be easier to set everything with its neighbors
   boolean collides(PVector from, PVector to)
   {
      for (Wall w : walls)
      {
         if (w.crosses(from, to)) return true;
      }
      return false;
   }
   Map()
   {
      mazeWalls = new ArrayList<Wall>();
      primWalls = new ArrayList<Wall>();
      primNodes = new ArrayList<MazeCell>();
      //primMap = new HashMap <Wall, MazeCell>();
      borders = new ArrayList<Wall>();
      nodes = new ArrayList<MazeCell>();
      
   }
  
   
   
   void generate(int which)
   {
      mazeWalls.clear();
      primWalls.clear();
      borders.clear();
      nodes.clear();
      
      int numberOfRows = height/GRID_SIZE;
      int numberOfColumns = width/GRID_SIZE;
      
      nodearray = new MazeCell[numberOfColumns][numberOfRows];
      
      //This creates a border. very redundant, I just was testing
      PVector topLeft = new PVector (0,0);
      PVector topRight = new PVector (numberOfColumns * GRID_SIZE,0);
      PVector bottomRight = new PVector (numberOfColumns * GRID_SIZE,numberOfRows * GRID_SIZE);
      PVector bottomLeft = new PVector (0, numberOfRows * GRID_SIZE);
      
      borders.add(new Wall(topLeft, topRight));
      borders.add(new Wall(topRight, bottomRight));
      borders.add(new Wall(bottomRight, bottomLeft));
      borders.add(new Wall(bottomLeft, topLeft));
      
      //Creates all of the new maze cells. But not the neighbors yet
      for(int i = 0; i < numberOfRows; i++){
        for(int j = 0; j < numberOfColumns; j++){
          nodes.add(new MazeCell(new PVector(j*GRID_SIZE + GRID_SIZE/2, i*GRID_SIZE + GRID_SIZE/2)));
          nodearray[j][i] = new MazeCell(new PVector(j*GRID_SIZE + GRID_SIZE/2, i*GRID_SIZE + GRID_SIZE/2));
        }
      }
      
      //Loop through everything and add the neighbors
      for(int i = 0; i < numberOfRows; i++){
        for(int j = 0; j < numberOfColumns; j++){
          
          //nodearray[j][i];
          if(j > 0){
            nodearray[j][i].neighbors.add(nodearray[j-1][i]);
            //nodearray[j][i].addLeftNeighbor(nodearray[j-1][i]);
          }
          if(j < numberOfColumns - 1){
            nodearray[j][i].neighbors.add(nodearray[j+1][i]);
            //nodearray[j][i].addRightNeighbor(nodearray[j+1][i]);
          }
          if(i > 0){
            nodearray[j][i].neighbors.add(nodearray[j][i-1]);
            //nodearray[j][i].addTopNeighbor(nodearray[j][i-1]);
          }
          if(i < numberOfRows - 1){
            nodearray[j][i].neighbors.add(nodearray[j][i+1]);
            //nodearray[j][i].addBottomNeighbor(nodearray[j][i+1]);
          }
          
        }
      }
      
      //Picking a random node to start with
      //MazeCell startCell = nodes.get(int(random(0,nodes.size())));
      MazeCell startCell = nodearray[int(random(0,numberOfColumns))][int(random(0,numberOfRows))];
      startCell.visited = true;
      startCell.started = true;
      
      //Adding the first posibilities for Prims
      for (MazeCell n : startCell.neighbors)
      {
        n.parentCell = startCell;
        primNodes.add(n);
      }
      
      while(!primNodes.isEmpty()){  //Continues while there are walls in the list
        int checkNodeIndex = int(random(0,primNodes.size()));
        MazeCell checkNode = primNodes.get(checkNodeIndex);  //Might just be able to remove it here and not at the bottom
        
        if(checkNode.visited == true){
          //add wall to mazeWalls
        } else {
          //remove wall between this and parent node
          
          for (MazeCell n : checkNode.neighbors)
            {
              if(n.visited == false){
                n.parentCell = checkNode;
                primNodes.add(n);
              }
            }
          checkNode.visited = true;
          
          //Informs parent and child that they are connected
          checkNode.connectedCells.add(checkNode.parentCell);
          checkNode.parentCell.connectedCells.add(checkNode);
        }
            
        primNodes.remove(checkNodeIndex);
      }
      //All cells should have the cells theyve actually been connected to now
      //gonna do it slow for now
      for(int i = 0; i < numberOfRows; i++){
        for(int j = 0; j < numberOfColumns; j++){
          //nodearray[j][i];
          boolean left = true;
          boolean right = true;
          boolean up = true;
          boolean down = true;
          //print("\nMaze Cell has x connections " + nodearray[j][i].connectedCells.size());
          for(MazeCell MC : nodearray[j][i].connectedCells){
            if(nodearray[j][i].location.x < MC.location.x){
              right = false;
              //print("\n \t connection found to the right");
              //nodearray[j][i].addRightWall();
            } else if(nodearray[j][i].location.x > MC.location.x){
              left = false;
              //nodearray[j][i].addLeftWall();
            } else if(nodearray[j][i].location.y < MC.location.y){
              down = false;
              //nodearray[j][i].addBottomWall();
            } else if(nodearray[j][i].location.y > MC.location.y){
              up = false;
              //nodearray[j][i].addTopWall();
            }
          }
          if(left){
              nodearray[j][i].addLeftWall();
            }
            if(right){
              nodearray[j][i].addRightWall();
            }
            if(up){
              nodearray[j][i].addTopWall();
            }
            if(down){
              nodearray[j][i].addBottomWall();
            }
          
          
        }
      }
     
      //Prims
      //Place all walls
      //Start at random node, marking as visited
        //if one of the walls it touches hasnt been visited, remove the wall, and add the new nodes walls to the list
        //remove the wall from the list
   }
   
   void update(float dt)
   {
      draw();
   }
   
   void draw()
   {
      stroke(255);
      //strokeWeight(10);
      for (Wall w : mazeWalls)
      {
         w.draw();
      }
      
      for (Wall w : borders)
      {
         w.draw();
      }
      
      //Based of the array list, not sure this is the way to do it
      /*
      stroke(0, 150, 0);
      //strokeWeight(1);
      for (MazeCell m : nodes)
      {
         for (Wall w : m.walls)
          {
            stroke(0, 150, 0);
            //strokeWeight(1);
             w.draw();
          }
          stroke(150, 0, 0);
          fill(150,0,0);
          circle(m.location.x, m.location.y, 5);
          if (m.visited == true) {
            
            circle(m.location.x, m.location.y, 20);
          }
      }*/
      for(int i = 0; i < height/GRID_SIZE; i++){
        for(int j = 0; j < width/GRID_SIZE; j++){
          //reaches all nodes
            //if(i%2 == 0 && j%3 ==0){
              for (Wall w : nodearray[j][i].walls)
              {
                stroke(0, 250, 0);
                //strokeWeight(1);
                 w.draw();
              }
              
              //draws blue lines to all neighbors
              for (MazeCell n : nodearray[j][i].neighbors)
              {
                stroke(0, 0, 250);
                //line(nodearray[j][i].location.x, nodearray[j][i].location.y, n.location.x, n.location.y);
              }
              
              //draws a circle around each nodes midpoint. It is larger if visited
              stroke(250, 0, 0);
              fill(150,0,0);
              circle(nodearray[j][i].location.x, nodearray[j][i].location.y, 10);
              if (nodearray[j][i].started == true) {
                circle(nodearray[j][i].location.x, nodearray[j][i].location.y, 20);
              }
              
              stroke(0, 0, 250);
              if(nodearray[j][i].parentCell != null){
                line(nodearray[j][i].location.x, nodearray[j][i].location.y, nodearray[j][i].parentCell.location.x, nodearray[j][i].parentCell.location.y);
              }
            //}
        }
      }
      
      stroke(255);
      //strokeWeight(10);
      for (Wall w : mazeWalls)
      {
         w.draw();
      }
      
   }
}
