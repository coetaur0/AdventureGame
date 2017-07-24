-- Definition of the WalkArea class.

local Object = require "lib/classic"
local Vector2D = require "lib/vector2d"
local AStar = require "engine/pathfinding/astar"
local Polygon = require "engine/pathfinding/polygon"
local Graph = require "engine/pathfinding/graph"
local GraphNode = require "engine/pathfinding/graphnode"
local GraphEdge = require "engine/pathfinding/graphedge"

local WalkArea = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new WalkArea object.
--------------------------------------------------------------------------------
function WalkArea:new()
  self.vertices_concave = {}
  self.polygons = {}
  self.walkGraph = Graph()
  self.mainWalkGraph = Graph()
  self.targetX = 0
  self.targetY = 0
  self.startNodeIndex = 1
  self.endNodeIndex = 1
  self.shortestPath = {}
end

--------------------------------------------------------------------------------
-- Add a polygon (obstacle) to the walkable area.
--------------------------------------------------------------------------------
function WalkArea:addPolygon()
  table.insert(self.polygons, Polygon())
end

--------------------------------------------------------------------------------
-- Determine whether two line segments cross each other.
-- @param v1 The starting point of the first segment.
-- @param v2 The ending point of the first segment.
-- @param v3 The starting point of the second segment.
-- @param v4 The ending point of the second segment.
-- @returns A boolean indicating whether the two segments cross each other.
--------------------------------------------------------------------------------
function WalkArea:lineSegmentsCross(v1, v2, v3, v4)
  local denominator = (v2.x-v1.x)*(v4.y-v3.y) - (v2.y-v1.y)*(v4.x-v3.x)

  if denominator == 0 then
    return false
  end

  local numerator1 = (v1.y-v3.y)*(v4.x-v3.x) - (v1.x-v3.x)*(v4.y-v3.y)
  local numerator2 = (v1.y-v3.y)*(v2.x-v1.x) - (v1.x-v3.x)*(v2.y-v1.y)

  if numerator1 == 0 or numerator2 == 0 then
    return false
  end

  local r = numerator1 / denominator
  local s = numerator2 / denominator

  return (r > 0 and r < 1) and (s > 0 and s < 1)
end

--------------------------------------------------------------------------------
-- Determine whether a vector is in the line of sight of another one in the
-- WalkArea.
-- @param start_p The vector from which the line of sight must be determined.
-- @param end_p The vector which is either in the line of sight or not.
-- @returns A boolean indicating whether end is in the line of sight of start.
--------------------------------------------------------------------------------
function WalkArea:inLineOfSight(start_p, end_p)
  local epsilon = 0.5

  -- Check whether the starting and ending points are inside the main polygon.
  if not self.polygons[1]:isPointInside(start_p, true) or not self.polygons[1]:isPointInside(end_p, true) then
    return false
  end

  -- If the starting and ending points are the same -> true.
  if start_p:sub(end_p):norm() < epsilon then
    return true
  end

  -- Check if the line between start_p and end_p cross any of the edges of
  -- the polygons in the WalkArea.
  for _, polygon in ipairs(self.polygons) do
    for i = 1, #polygon.vertices do

      local v1 = polygon.vertices[i]
      local v2 = polygon.vertices[i % #polygon.vertices + 1]
      if (self:lineSegmentsCross(start_p, end_p, v1, v2)) then

        -- A 0.5 margin is used to tackle rounding errors which might cause a
        -- point to be a little over the line.
        if polygon:distanceToSegment(start_p, v1, v2) > 0.5 and
        polygon:distanceToSegment(end_p, v1, v2) > 0.5 then
          return false
        end

      end
    end
  end

  local v = start_p:add(end_p)
  local v2 = Vector2D(v.x/2, v.y/2)
  local inside = self.polygons[1]:isPointInside(v2, true)

  -- Check that the line between start_p and end_p doesn't cross an inner
  -- polygon (obstacle).
  for i = 2, #self.polygons, 1 do
    if self.polygons[i]:isPointInside(v2, false) then
      inside = false
    end
  end

  return inside
end

--------------------------------------------------------------------------------
-- Create the graph with the concave vertices of the main polygon and the
-- convex ones from the inner polygons (obstacles).
--------------------------------------------------------------------------------
function WalkArea:createGraph()
  local first = true

  for _, polygon in ipairs(self.polygons) do
    if polygon ~= nil and polygon.vertices ~= nil and #polygon.vertices > 2 then
      for i = 1, #polygon.vertices do
        -- For the first polygon, we retrieve the concave vertices. For the others,
        -- which are inside the main one and therefore are obstacle, we retrieve
        -- the non-concave vertices.
        if polygon:isVertexConcave(i) == first then
          table.insert(self.vertices_concave, polygon.vertices[i])
          self.mainWalkGraph:addNode(GraphNode(Vector2D(polygon.vertices[i].x, polygon.vertices[i].y)))
        end
      end
    end
    first = false
  end

  for i, c1 in ipairs(self.vertices_concave) do
    for j, c2 in ipairs(self.vertices_concave) do
      if self:inLineOfSight(c1, c2) then
        self.mainWalkGraph:addEdge(GraphEdge(i, j, math.sqrt(c1:squareDistance(c2))))
      end
    end
  end
end

--------------------------------------------------------------------------------
-- Compute the shortest path from a position to another one in the walkable
-- area.
-- @param from A vector containing the position from which the path must start.
-- @param to A vector containing the position to which the path must go.
-- @returns The shortest path between from and to.
--------------------------------------------------------------------------------
function WalkArea:getShortestPath(from, to)
  self.walkGraph = self.mainWalkGraph:clone()

  local minDistFrom = 100000
  local minDistTo = 100000

  -- Creation of a new node on the start position.
  self.startNodeIndex = #self.walkGraph.nodes + 1

  -- If the start and end positions are outside the main polygon, compute the
  -- closest position inside.
  if not self.polygons[1]:isPointInside(from, true) then
    from = self.polygons[1]:closestPointOnEdge(from)
  end
  if not self.polygons[1]:isPointInside(to, true) then
    to = self.polygons[1]:closestPointOnEdge(to)
  end

  -- If there are inner polygons, check whether the end point is inside
  -- one of them. If this is the case, find the closest point on one
  -- of its edges.
  for i = 2, #self.polygons do
    if self.polygons[i]:isPointInside(to, true) then
      to = self.polygons[i]:closestPointOnEdge(to)
      break
    end
  end

  self.targetX = to.x
  self.targetY = to.y

  -- Create a new node on the start position.
  local startPosition = Vector2D(from.x, from.y)
  local startNode = GraphNode(startPosition)
  self.walkGraph:addNode(startNode)

  -- Compute the edges between the start node and all the other nodes in its
  -- line of sight.
  for cIndex = 1, #self.vertices_concave do
    local c = self.vertices_concave[cIndex]
    if self:inLineOfSight(startPosition, c) then
      self.walkGraph:addEdge(GraphEdge(self.startNodeIndex, cIndex, math.sqrt(startPosition:squareDistance(c))))
    end
  end

  -- Create a new node on the end position.
  self.endNodeIndex = #self.walkGraph.nodes + 1
  local endPosition = Vector2D(to.x, to.y)
  local endNode = GraphNode(endPosition)
  self.walkGraph:addNode(endNode)

  -- Compute the edges between the end node and all the other nodes in its line
  -- of sight.
  for cIndex = 1, #self.vertices_concave do
    local c = self.vertices_concave[cIndex]
    if self:inLineOfSight(endPosition, c) then
      self.walkGraph:addEdge(GraphEdge(self.endNodeIndex, cIndex, math.sqrt(endPosition:squareDistance(c))))
    end
  end

  if self:inLineOfSight(startPosition, endPosition) then
    self.walkGraph:addEdge(GraphEdge(self.startNodeIndex, self.endNodeIndex, math.sqrt(startPosition:squareDistance(endPosition))))
  end

  -- Compute the shortest path with the A-star algorithm.
  local astar = AStar(self.walkGraph, self.startNodeIndex, self.endNodeIndex)
  self.shortestPath = astar:getPath()

  return self.shortestPath
end

return WalkArea
