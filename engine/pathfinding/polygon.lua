-- Definition of the Polygon class.

local Object = require "lib/classic"
local Vector2D = require "lib/vector2d"

local Polygon = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new Polygon.
--------------------------------------------------------------------------------
function Polygon:new()
  self.vertices = {}
end

--------------------------------------------------------------------------------
-- Add a vertex to the polygon.
-- @param x Coordinate of the new vertex on the x-axis.
-- @param y Coordinate of the new vertex on the y-axis.
--------------------------------------------------------------------------------
function Polygon:addVertex(x, y)
  table.insert(self.vertices, Vector2D(x, y))
end

--------------------------------------------------------------------------------
-- Check if a point is inside the polygon or not.
-- @param point The point which is either inside or outside the polygon.
-- @param tolerance A boolean value indicating if a tolerance must be applied
--                  on points near the edges of the polygon.
-- @returns A boolean value indicating whether the point is inside the polygon.
--------------------------------------------------------------------------------
function Polygon:isPointInside(point, tolerance)
  if tolerance == nil then
    tolerance = true
  end

  local epsilon = 0.5
  local inside = false

  -- If a polygon has less than 3 vertices, a point is always outside of it
  -- (it is just a line).
  if #self.vertices < 3 then
    return false
  end

  local oldPoint = self.vertices[#self.vertices]
  local oldSquareDist = point:squareDistance(oldPoint)

  for i, v in ipairs(self.vertices) do
    local newPoint = v
    local newSquareDist = point:squareDistance(newPoint)

    if oldSquareDist + newSquareDist + 2*math.sqrt(oldSquareDist*newSquareDist)
     - newPoint:squareDistance(oldPoint) < epsilon then
      return tolerance
    end

    local left
    local right
    if newPoint.x > oldPoint.x then
      left = oldPoint
      right = newPoint
    else
      left = newPoint
      right = oldPoint
    end

    if left.x < point.x and point.x <= right.x and
     (point.y-left.y)*(right.x-left.x) < (right.y-left.y)*(point.x-left.x) then
      inside = not inside
    end

    oldPoint = newPoint
    oldSquareDist = newSquareDist
  end

  return inside
end

--------------------------------------------------------------------------------
-- Compute the distance between a point and a segment between two vertices.
-- @param point A point represented by a 2D vector.
-- @param vertex1 The vertex representing the start of the segment.
-- @param vertex2 The vertex representing the end of the segment.
-- @returns The distance between the point and the segment.
--------------------------------------------------------------------------------
function Polygon:distanceToSegment(point, vertex1, vertex2)
  local segmentLen = vertex1:squareDistance(vertex2)
  if segmentLen == 0 then
    return math.sqrt(point:squareDistance(vertex1))
  end

  local t = ((point.x-vertex1.x)*(vertex2.x-vertex1.x) +
            (point.y-vertex1.y)*(vertex2.y-vertex1.y)) / segmentLen

  if t < 0 then
    return math.sqrt(point:squareDistance(vertex1))
  end
  if t > 1 then
    return math.sqrt(point:squareDistance(vertex2))
  end

  local temp = Vector2D(vertex1.x+t*(vertex2.x-vertex1.x), vertex1.y+t*(vertex2.y-vertex1.y))
  return math.sqrt(point:squareDistance(temp))
end

--------------------------------------------------------------------------------
-- Get the closest point to a position on an edge of the polygon.
-- @param position The position for which the closest point must be found.
-- @returns A vector with the coordinates of the closest point.
--------------------------------------------------------------------------------
function Polygon:closestPointOnEdge(point)
  local v1 = -1
  local v2 = -1
  local minDist = 100000

  for i, v in ipairs(self.vertices) do
    local dist = self:distanceToSegment(point, v, self.vertices[i % #self.vertices + 1])
    if dist < minDist then
      minDist = dist
      v1 = v
      v2 = self.vertices[i % #self.vertices + 1]
    end
  end

  local u = ((point.x-v1.x)*(v2.x-v1.x) + (point.y-v1.y)*(v2.y-v1.y)) / v2:squareDistance(v1)

  local xu = v1.x + u * (v2.x - v1.x)
  local yu = v1.y + u * (v2.y - v1.y)

  local lineVect
  if u < 0 then
    lineVect = Vector2D(v1.x, v1.y)
  elseif u > 1 then
    lineVect = Vector2D(v2.x, v2.y)
  else
    lineVect = Vector2D(xu, yu)
  end

  return lineVect
end

--------------------------------------------------------------------------------
-- Check whether a vertex is concave.
-- @param vertex The index of the vertex which is either concave or not.
--------------------------------------------------------------------------------
function Polygon:isVertexConcave(vertex)
  local current = self.vertices[vertex]
  local next = self.vertices[vertex % #self.vertices + 1]
  local previous = self.vertices[#self.vertices]
  if vertex ~= 1 then
    previous = self.vertices[vertex-1]
  end

  local left = Vector2D(current.x-previous.x, current.y-previous.y)
  local right = Vector2D(next.x-current.x, next.y-current.y)

  local cross = (left.x*right.y) - (left.y*right.x)

  return cross < 0
end

return Polygon
