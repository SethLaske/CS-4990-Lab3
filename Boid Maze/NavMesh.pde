

// Useful to sort lists by a custom key
import java.util.Comparator;
import java.util.HashMap;
import java.util.Random;
import java.util.*;
/// In this file you will implement your navmesh and pathfinding.

/*
/// This node representation is just a suggestion
class Node
{
  //int id;    //each polygon is given a unique ID    This is not required for this implementation but helped with troubleshooting
  ArrayList<Wall> polygon;    //each polygon will have convex walls
  PVector center;    //each polygon will have a centerpoint
  ArrayList<Node> connectedCells;    //a list of all adjacent nodes
  HashMap<Node, Wall> neighborToWall;    //the map to quickly find a wall based on which neighbor is being analyzed
  ArrayList<Wall> connections;    //a seperate list of walls to make the design easier

  Node(MazeCell cell) {
    //this.id = id;
    polygon = cell.borders;
    center = cell.location;
    connectedCells = new ArrayList<Node>();
    neighborToWall = new HashMap<Node, Wall>();
    connections = new ArrayList<Wall>();
  }

  //finds the center given the walls, simply an average of all the coordinates
  PVector findCenter (ArrayList<Wall> polygon) {
    float xCoord = 0;
    float yCoord = 0;

    for (int i = 0; i < polygon.size(); i++) {
      xCoord += polygon.get(i).start.x;
      yCoord += polygon.get(i).start.y;
    }
    xCoord /= polygon.size();
    yCoord /= polygon.size();

    return new PVector(xCoord, yCoord);
  }

  void addNeighbor(Node newNeighbor)
  {
    connectedCells.add(newNeighbor);
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
*/


class NavMesh
{
  public ArrayList<MazeCell> mazeCells;  //Pass them all in
  
  
  
  
  
  
  
  //possible improvement, get rid of the hashmap by using a dynamic data structure that has 2 rows
  void bake(Map map)
  {
    mazeCells = new ArrayList<MazeCell>();
    
    for (int i = 0; i < map.nodearray.length; i++) { 
        for (int j = 0; j < map.nodearray[0].length; j++) {
          mazeCells.add(map.nodearray[i][j]);    //Should preserve all connectedCells, just converting it to an array list
        }
    }
    
  }

  //Check to make sure our "walls" that create the convex polygons are placeable (eg. won't collide with anything)
  Boolean IsPlaceable (ArrayList<Wall> PolygonWalls, Wall TestWall)
  {
    //Vector from where the wall is starting
    PVector From = PVector.add(TestWall.start, PVector.mult(TestWall.direction, 0.01));
    //Vector to where the wall will be placed
    PVector To = PVector.add(TestWall.end, PVector.mult(TestWall.direction, -0.01));
    for (int n = 0; n<PolygonWalls.size(); n++)
    {      //checks all walls to see if there is any crossing
      if (PolygonWalls.get(n).crosses(From, To))
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
    MazeCell currentNode;
    frontierNode parentNode;

    frontierNode(MazeCell currentNode, frontierNode parentNode, float pathLength, PVector target)
    {
      this.currentNode = currentNode;
      this.parentNode = parentNode;
      this.pathLength = pathLength;
      this.heuristic = getPVectorDistance(currentNode.location, target);
      this.aValue = pathLength + heuristic;
    }
  }

  //Function to find the most optimal path using a*
  ArrayList<PVector> findPath(PVector boidPosition, PVector destinationPosition)
  {
    print("\n Looking for path");
    
    ArrayList<PVector> path = new ArrayList<PVector>();

    //find which nodes boid and destination are in
    MazeCell startNode = null;
    MazeCell endNode = null;

    for (MazeCell testNode : mazeCells)
    {
      if (pointContained(boidPosition, testNode.borders))
      {
        startNode = testNode;
        print("\n Found start node");
        break;
      }
      print("\n searching for start node");
    }

    for (MazeCell testNode : mazeCells)
    {
      if (pointContained(destinationPosition, testNode.borders))
      {
        endNode = testNode;
        print("\n Found end node");
        break;
      }
    }

    //call find node path
    if (startNode != endNode)
    {
      ArrayList<MazeCell> nodePath = new ArrayList<MazeCell>();
      print("\nFinding path between nodes");
      nodePath = findNodePath(startNode, endNode);

      print("\n Number of nodes " + nodePath.size());

      for (int i = 0; i < nodePath.size() - 1; i++)
      {
        
        //path.add(nodePath.get(i).neighborToWall.get(nodePath.get(i + 1)).center());
        path.add(new PVector( (nodePath.get(i).location.x + nodePath.get(i+1).location.x)/2 , (nodePath.get(i).location.y + nodePath.get(i+1).location.y)/2));
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
    for (Wall wall : polygon)
    {
      if (wall.crosses(point, new PVector(point.x + 2*width, point.y)))
      {
        crosses ++;
      }
    }
    if ((crosses % 2) == 0)
    {
      return false;
    }
    return true;
  }

  //Function to find the proper node path
  ArrayList<MazeCell> findNodePath(MazeCell start, MazeCell destination)
  {
    print("\n Looking for node path");
    ArrayList<frontierNode> frontierList = new ArrayList<frontierNode>();
    ArrayList<MazeCell> previouslyExpandedList = new ArrayList<MazeCell>();

    //Will add a new frontier every time it reaches a frontier.
    frontierList.add(new frontierNode(start, null, 0, destination.location));

    //While there are still frontiers, and we're not in the destination, it will keep looking and expanding horizons. It will also remove any older frontiers we've already been to
    while (frontierList.get(0).currentNode != destination)
    {
      print("\n The current lowest node is at: " + frontierList.get(0).currentNode.location);
      for (int i = 0; i < frontierList.get(0).currentNode.connectedCells.size(); i++) {
        print("\n Adding connectedCells");
        float newPath = frontierList.get(0).pathLength + getPVectorDistance(frontierList.get(0).currentNode.location, frontierList.get(0).currentNode.connectedCells.get(i).location);
        frontierList.add(new frontierNode(frontierList.get(0).currentNode.connectedCells.get(i), frontierList.get(0), newPath, destination.location));
      }
      previouslyExpandedList.add(frontierList.get(0).currentNode);
      frontierList.remove(0);
      frontierList.sort(new FrontierCompare());
      while (previouslyExpandedList.contains(frontierList.get(0).currentNode)) {
        frontierList.remove(0);
      }
      print("\n Done Sorting");
    }

    //Array list for the result. It will return a the optimal list. Thanks a*, and thank you Seth.
    ArrayList<MazeCell> result = new ArrayList<MazeCell>();
    result.add(frontierList.get(0).currentNode);

    frontierNode parentNode = frontierList.get(0).parentNode;

    while (result.get(0) != start)
    {
      result.add(0, parentNode.currentNode);
      parentNode = parentNode.parentNode;
    }
    return result;
  }

  //Function that compares frontiers. Whichever choice is the most optimal will have the higher value.
  class FrontierCompare implements Comparator<frontierNode>
  {
    int compare(frontierNode a, frontierNode b) {
      print("\n Doing comparing things");
      if (a.aValue > b.aValue)
      {
        return 1;
      } else if (a.aValue < b.aValue)
      {
        return -1;
      } else
        return 0;
    }
  }


  //Tree implementation of the expanded frontier map.
  TreeMap<Float, MazeCell> expandFrontier(TreeMap<Float, MazeCell>frontier, MazeCell target)
  {
    float shortestPath = frontier.firstKey();
    for (int i = 0; i<frontier.get(shortestPath).connectedCells.size(); i++)
    {
      float heuristic = shortestPath + getPVectorDistance(target.location, frontier.get(shortestPath).connectedCells.get(i).location);
      frontier.put(heuristic, frontier.get(shortestPath).connectedCells.get(i));
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
    
    

    //Has sections to draw different portions of the completed navMesh
   
  }
}
