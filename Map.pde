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
  ArrayList<MazeCell> neighbors;
  //Hashmap with walls to neighbors (check the wall, check the neighbor for being visited, add)
  
  boolean visited;
  MazeCell parentCell;
  
  MazeCell(PVector center){
    location = center;
    walls = new ArrayList<Wall>();
    neighbors = new ArrayList<MazeCell>();
    addFakeWalls();
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

}

class Map
{
   ArrayList<Wall> walls;
   ArrayList<Wall> borders;
   ArrayList<MazeCell> nodes;
   MazeCell[][] nodearray;  //I think this one will be easier to set everything with its neighbors
   
   Map()
   {
      walls = new ArrayList<Wall>();
      borders = new ArrayList<Wall>();
      nodes = new ArrayList<MazeCell>();
      
   }
  
   
   
   void generate(int which)
   {
      walls.clear();
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
          }
          if(j < numberOfColumns - 1){
            nodearray[j][i].neighbors.add(nodearray[j+1][i]);
          }
          if(i > 0){
            nodearray[j][i].neighbors.add(nodearray[j][i-1]);
          }
          if(i < numberOfRows - 1){
            nodearray[j][i].neighbors.add(nodearray[j][i+1]);
          }
          
        }
      }
      
      //Picking a random node to start with
      //MazeCell startCell = nodes.get(int(random(0,nodes.size())));
      MazeCell startCell = nodearray[int(random(0,numberOfColumns))][int(random(0,numberOfRows))];
      startCell.visited = true;
      
      for (Wall w : startCell.walls)
      {
         walls.add(w);
      }
      
      //Main LOOP coming in
      while(!walls.isEmpty()){  //Continues while there are walls in the list
        int checkWallIndex = int(random(0,walls.size()));
        Wall checkWall = walls.get(checkWallIndex);
        //this is the tricky bit, find what nodes it connects and check if they have both been visited
          //if so add the walls of that node to the list  
        walls.remove(checkWallIndex);
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
      for (Wall w : walls)
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
              
              for (MazeCell n : nodearray[j][i].neighbors)
              {
                stroke(0, 0, 250);
                line(nodearray[j][i].location.x, nodearray[j][i].location.y, n.location.x, n.location.y);
              }
              
              stroke(250, 0, 0);
              fill(150,0,0);
              circle(nodearray[j][i].location.x, nodearray[j][i].location.y, 10);
              if (nodearray[j][i].visited == true) {
                
                circle(nodearray[j][i].location.x, nodearray[j][i].location.y, 20);
              }
            //}
        }
      }
      
   }
}
