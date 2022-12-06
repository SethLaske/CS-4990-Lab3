import java.util.*;
//Shouldn't need old map code from lab 1
//What we do need is the node and navmesh code from lab 1
class Node
{
   int id;    //each polygon is given a unique ID    This is not required for this implementation but helped with troubleshooting
   ArrayList<Wall> polygon;    //each polygon will have convex walls
   PVector center;    //each polygon will have a centerpoint
   ArrayList<Node> neighbors;    //a list of all adjacent nodes
   HashMap<Node, Wall> neighborToWall;    //the map to quickly find a wall based on which neighbor is being analyzed
   ArrayList<Wall> connections;    //a seperate list of walls to make the design easier
   
   Node(int id, ArrayList<Wall> walls){
    this.id = id;  
    polygon = walls;
    center = findCenter(walls);
    neighbors = new ArrayList<Node>();
    neighborToWall = new HashMap<Node, Wall>();
    connections = new ArrayList<Wall>();   
  }
  
  //finds the center given the walls, simply an average of all the coordinates. Not likely to be used for lab 3
  PVector findCenter (ArrayList<Wall> polygon)
  {
    float xCoord = 0;
    float yCoord = 0;
    
    for(int i = 0; i < polygon.size(); i++){
      xCoord += polygon.get(i).start.x;
      yCoord += polygon.get(i).start.y;
    }
    xCoord /= polygon.size();
    yCoord /= polygon.size();
    
    return new PVector(xCoord, yCoord);
  }
  
  //add functions for the node. Will likely be used in tandem with lab 3's wall creation.
  void addNeighbor(Node newNeighbor)
  {
    neighbors.add(newNeighbor);
  }
  
  void addNeighborWall(Node newNeighbor, Wall wall)
  {
    neighborToWall.put(newNeighbor, wall);
  }
  
  void addConnection(Wall newWall)
  {
    connections.add(newWall);
  }
}
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
   //Bellow are functions form Map from lab 1
   void AddPolygon(ArrayList<Wall> walls, PVector[] nodes)
   {
      for (int i = 0; i < nodes.length; ++ i)
      {
         int next = (i+1)%nodes.length;
         walls.add(new Wall(nodes[i], nodes[next]));
      }
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
   ArrayList<Wall> walls;
   ArrayList<Wall> primWalls;
   ArrayList<MazeCell> primNodes;
   //HashMap <Wall, MazeCell> primMap;
   ArrayList<Wall> borders;
   ArrayList<MazeCell> nodes;
   MazeCell[][] nodearray;  //I think this one will be easier to set everything with its neighbors
   
   Map()
   {
      mazeWalls = new ArrayList<Wall>();
      primWalls = new ArrayList<Wall>();
      primNodes = new ArrayList<MazeCell>();
      //primMap = new HashMap <Wall, MazeCell>();
      borders = new ArrayList<Wall>();
      nodes = new ArrayList<MazeCell>();
      
   }
   //This function from lab 1 checks for collision
      boolean collides(PVector from, PVector to)
   {
      for (Wall w : walls)
      {
         if (w.crosses(from, to)) return true;
      }
      return false;
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

//This section is for our NavMesh from lab1
class NavMesh
{   
   public ArrayList<PVector> ReflexPoints;  //Reflex points that need to be adjusted
   public ArrayList<Wall> NewWalls;      //Walls that have been added to split polygon to be convex useful as a counter, and as a stepping stone, but could be edited out
   public ArrayList<Node> convexPolygons;    //The list of all convex polygons
   HashMap<Integer, Node> NewWallsMap = new HashMap<Integer, Node>();   //Useful for providing neighbors into each node using the index number

       //Adding the new wall to a list or later use/recursion

       //Add proper connections/neighbors

   
   //Check to make sure our "walls" that create the convex polygons are placeable (eg. won't collide with anything)
   Boolean IsPlaceable (ArrayList<Wall> PolygonWalls, Wall TestWall)
   {
        //Vector from where the wall is starting
        PVector From = PVector.add(TestWall.start, PVector.mult(TestWall.direction, 0.01));
        //Vector to where the wall will be placed
        PVector To = PVector.add(TestWall.end, PVector.mult(TestWall.direction, -0.01));
        for(int n = 0; n<PolygonWalls.size(); n++)
        {      //checks all walls to see if there is any crossing
            if(PolygonWalls.get(n).crosses(From, To))
            {
            return false;
            }
        }
        //If there are no issues, we can return true. Thus the wall can be placed.
        return true;
   }
   
   //Class definition of the frontier node.
   //Contains a heuristic for the navigation algorithm, length of path, value for a*, and the current node.
   class frontierNode
   {
     float heuristic;
     float pathLength;
     float aValue;
     Node currentNode;
     frontierNode parentNode;
     
     frontierNode(Node currentNode, frontierNode parentNode, float pathLength, PVector target)
     {
       this.currentNode = currentNode;
       this.parentNode = parentNode;
       this.pathLength = pathLength;
       this.heuristic = getPVectorDistance(currentNode.center, target);
       this.aValue = pathLength + heuristic;
     }
   }
   
   //Function to find the most optimal path using a*
   ArrayList<PVector> findPath(PVector boidPosition, PVector destinationPosition)
   {
     ArrayList<PVector> path = new ArrayList<PVector>();
    
     //find which nodes boid and destination are in
     Node startNode = null;
     Node endNode = null;

     for(Node testNode: convexPolygons)
     {     
       if(pointContained(boidPosition, testNode.polygon))
       {
         startNode = testNode;
         break;
       }
     }
     
     for(Node testNode: convexPolygons)
     {
       if(pointContained(destinationPosition, testNode.polygon))
       {
         endNode = testNode;
         break;
       }
     }
     
     //call find node path
     if (startNode != endNode)
     {
       ArrayList<Node> nodePath = new ArrayList<Node>();
       print("\nFinding path between nodes");
       nodePath = findNodePath(startNode, endNode);
       
       print("\n Number of nodes " + nodePath.size());
       
       for(int i = 0; i < nodePath.size() - 1; i++)
       {
         path.add(nodePath.get(i).neighborToWall.get(nodePath.get(i + 1)).center());
       }
     }
     
     path.add(destinationPosition);
     //might combine them all into one, tbd
     print("\n Number of points to travel through: " + path.size());
     
     return path;  
   }
   
   //Function to check the point we need to access
   boolean pointContained (PVector point, ArrayList<Wall> polygon)
   {
    int crosses = 0;
    for(Wall wall: polygon)
    {
            if (wall.crosses(point, new PVector(point.x + 2*width, point.y)))
            {
              crosses ++;
            }
    }
    if((crosses % 2) == 0)
    {
       return false;
    }
    return true;
   }
   
   //Function to find the proper node path
   ArrayList<Node> findNodePath(Node start, Node destination)
   {
     print("\n Looking for path");
     ArrayList<frontierNode> frontierList = new ArrayList<frontierNode>();
     ArrayList<Node> previouslyExpandedList = new ArrayList<Node>();
     
     //Will add a new frontier every time it reaches a frontier.
     frontierList.add(new frontierNode(start, null, 0, destination.center));

     //While there are still frontiers, and we're not in the destination, it will keep looking and expanding horizons. It will also remove any older frontiers we've already been to
     while(frontierList.get(0).currentNode != destination)
     {
        print("\n The current lowest node is at: " + frontierList.get(0).currentNode.center);
        for(int i = 0; i < frontierList.get(0).currentNode.neighbors.size(); i++){
          print("\n Adding Neighbors");
          float newPath = frontierList.get(0).pathLength + getPVectorDistance(frontierList.get(0).currentNode.center, frontierList.get(0).currentNode.neighbors.get(i).center);
          frontierList.add(new frontierNode(frontierList.get(0).currentNode.neighbors.get(i), frontierList.get(0), newPath, destination.center));
        }
        previouslyExpandedList.add(frontierList.get(0).currentNode);
        frontierList.remove(0);
        frontierList.sort(new FrontierCompare());
        while(previouslyExpandedList.contains(frontierList.get(0).currentNode)){
          frontierList.remove(0);
        }
        print("\n Done Sorting");
     }
     
      //Array list for the result. It will return a the optimal list. Thanks a*, and thank you Seth.
      ArrayList<Node> result = new ArrayList<Node>();
      result.add(frontierList.get(0).currentNode);
      
      frontierNode parentNode = frontierList.get(0).parentNode;
      
      while(result.get(0) != start)
      {
        result.add(0, parentNode.currentNode);
        parentNode = parentNode.parentNode;
      }
      return result;
   }
   
   //Function that compares frontiers. Whichever choice is the most optimal will have the higher value.
   class FrontierCompare implements Comparator<frontierNode>
   {
     int compare(frontierNode a, frontierNode b){
       print("\n Doing comparing things");
       if(a.aValue > b.aValue)
       {
         return 1;
       } 
       else if(a.aValue < b.aValue)
       {
         return -1;
       } 
       else
         return 0;
     }
   }
   
   
   //Tree implementation of the expanded frontier map. 
   TreeMap<Float, Node> expandFrontier(TreeMap<Float, Node>frontier, Node target)
   {
     float shortestPath = frontier.firstKey();
     for(int i = 0; i<frontier.get(shortestPath).neighbors.size(); i++)
     {
       float heuristic = shortestPath + getPVectorDistance(target.center, frontier.get(shortestPath).neighbors.get(i).center);
       frontier.put(heuristic, frontier.get(shortestPath).neighbors.get(i));
     }
     return frontier;
   }
   
   void update(float dt)
   {
      draw();     
   }
   
   void draw()
   {
      /// use this to draw the nav mesh graph
      for(int i = 0; i < ReflexPoints.size(); i++){
        stroke(0,255,0);
        circle(ReflexPoints.get(i).x, ReflexPoints.get(i).y, 20);
      }
      int blueColor = 255;
      int redColor = 0;

      if(NewWalls!=null)
      {
        for(int j = 0; j < NewWalls.size(); j++)
        {
            stroke(redColor,0,blueColor);
            blueColor -= 10;
            redColor += 10;
        }
      }
      
      if(convexPolygons != null)
      {
        for(int l = 0; l < convexPolygons.size(); l++)
        {
            stroke(150);
            circle(convexPolygons.get(l).center.x, convexPolygons.get(l).center.y, 20);
            for(int f = 0; f < convexPolygons.get(l).connections.size(); f++)
            {
                stroke(150);
                line(convexPolygons.get(l).connections.get(f).start.x, convexPolygons.get(l).connections.get(f).start.y, convexPolygons.get(l).connections.get(f).end.x, convexPolygons.get(l).connections.get(f).end.y);
            }
            for(int f = 0; f < convexPolygons.get(l).polygon.size(); f++)
            {
                stroke(020);
            }
            for(int f = 0; f < convexPolygons.get(l).neighbors.size(); f++)
            {
                stroke(150);
            }
        }
      } 
   }
}
