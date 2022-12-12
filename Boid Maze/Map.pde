import java.util.*;

class Wall
{
   PVector start;
   PVector end;
   PVector normal;
   PVector direction;
   float len;
   
   Wall(PVector start, PVector end)
   {
      this.start = start;
      this.end = end;
      direction = PVector.sub(this.end, this.start);
      len = direction.mag();
      direction.normalize();
      normal = new PVector(-direction.y, direction.x);
   }
   
   // Return the mid-point of this wall
   PVector center()
   {
      return PVector.mult(PVector.add(start, end), 0.5);
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

//The different nodes that will be used
class MazeCell{

  PVector location;  //center of the grid
  ArrayList<Wall> walls; 
  ArrayList<Wall> borders; 
  ArrayList<MazeCell> neighbors;
  ArrayList<MazeCell> connectedCells;
  
  boolean visited;
  boolean started;
  MazeCell parentCell;
  
  MazeCell(PVector center){
    location = center;
    walls = new ArrayList<Wall>();
    borders = new ArrayList<Wall>();
    neighbors = new ArrayList<MazeCell>();
    connectedCells = new ArrayList<MazeCell>();
    
    visited = false;
    started = false;
    addSurroundingWalls();
  }
  
  void addSurroundingWalls(){
    PVector topLeft = new PVector (location.x - (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      PVector topRight = new PVector (location.x + (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      PVector bottomRight = new PVector (location.x + (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      PVector bottomLeft = new PVector (location.x - (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      
      borders.add(new Wall(topLeft, topRight));
      borders.add(new Wall(topRight, bottomRight));
      borders.add(new Wall(bottomRight, bottomLeft));
      borders.add(new Wall(bottomLeft, topLeft));
  }
  
  Wall addLeftWall(){
    PVector topLeft = new PVector (location.x - (GRID_SIZE/2), location.y - (GRID_SIZE/2));
    PVector bottomLeft = new PVector (location.x - (GRID_SIZE/2), location.y + (GRID_SIZE/2));
    
    walls.add(new Wall(bottomLeft, topLeft));
    return new Wall(bottomLeft, topLeft);
  }
  
  Wall addRightWall(){
    PVector topRight = new PVector (location.x + (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      PVector bottomRight = new PVector (location.x + (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      
      walls.add(new Wall(topRight, bottomRight));
      return new Wall(topRight, bottomRight);
  }
  
  Wall addTopWall(){
    PVector topLeft = new PVector (location.x - (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      PVector topRight = new PVector (location.x + (GRID_SIZE/2), location.y - (GRID_SIZE/2));
      
      walls.add(new Wall(topLeft, topRight));
      return new Wall(topLeft, topRight);
  }
  
  Wall addBottomWall(){
    PVector bottomRight = new PVector (location.x + (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      PVector bottomLeft = new PVector (location.x - (GRID_SIZE/2), location.y + (GRID_SIZE/2));
      
      walls.add(new Wall(bottomRight, bottomLeft));
      return new Wall(bottomRight, bottomLeft);
  }
  
  

}

class Map
{
   ArrayList<Wall> mazeWalls;
   ArrayList<Wall> primWalls;
   ArrayList<MazeCell> primNodes;
   //HashMap <Wall, MazeCell> primMap;
   ArrayList<Wall> borders;
   //ArrayList<MazeCell> nodes;
   MazeCell[][] nodearray;  //I think this one will be easier to set everything with its neighbors
   
   Map()
   {
      mazeWalls = new ArrayList<Wall>();
      primWalls = new ArrayList<Wall>();
      primNodes = new ArrayList<MazeCell>();
      //primMap = new HashMap <Wall, MazeCell>();
      borders = new ArrayList<Wall>();
      //nodes = new ArrayList<MazeCell>();
      
   }
  
   
   
   void generate(int which)
   {
      mazeWalls.clear();
      primWalls.clear();
      borders.clear();
      //nodes.clear();
      
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
          //nodes.add(new MazeCell(new PVector(j*GRID_SIZE + GRID_SIZE/2, i*GRID_SIZE + GRID_SIZE/2)));
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
              mazeWalls.add(nodearray[j][i].addLeftWall());
            }
            if(right){
              mazeWalls.add(nodearray[j][i].addRightWall());
            }
            if(up){
              mazeWalls.add(nodearray[j][i].addTopWall());
            }
            if(down){
              mazeWalls.add(nodearray[j][i].addBottomWall());
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

      for (Wall w : mazeWalls)
      {
         //w.draw();
      }
      
   }
   
   boolean collides(PVector from, PVector to)
  {
    for (Wall w : mazeWalls)
    {
      if (w.crosses(from, to)) return true;
    }
    return false;
  }
   
   boolean isReachable(PVector point)
  {
    if(point.x > width - width%GRID_SIZE){
      return false;
    }else if(point.y > height - height%GRID_SIZE){
      return false;
    } 
    return true;  
  }
}
