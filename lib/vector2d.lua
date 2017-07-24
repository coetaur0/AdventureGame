-- Definition of the Vector2D class.
-- Aurelien Coet, 2017.

local Object = require "lib/classic"

local Vector2D = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new Vector2D object.
-- @param x Coordinate of the vector along the x-axis.
-- @param y Coordinate of the vector along the y-axis.
--------------------------------------------------------------------------------
function Vector2D:new(x, y)
  self.x = x
  self.y = y
end

--------------------------------------------------------------------------------
-- Add two vectors.
-- @param vect A vector to add to the instance of Vector2D.
-- @returns A new vector containing the result of the operation.
--------------------------------------------------------------------------------
function Vector2D:add(vect)
  local new_vect = Vector2D(self.x, self.y)
  new_vect.x = new_vect.x + vect.x
  new_vect.y = new_vect.y + vect.y
  return new_vect
end

--------------------------------------------------------------------------------
-- Substract two vectors.
-- @param vect A vector to substract to the instance of Vector2D.
-- @returns A new vector containing the result of the operation.
--------------------------------------------------------------------------------
function Vector2D:sub(vect)
  local new_vect = Vector2D(self.x, self.y)
  new_vect.x = new_vect.x - vect.x
  new_vect.y = new_vect.y - vect.y
  return new_vect
end

--------------------------------------------------------------------------------
-- Dot product between two vectors.
-- @param vect Another vector.
-- @returns The result of the operation.
--------------------------------------------------------------------------------
function Vector2D:dot(vect)
  return self.x * vect.x + self.y * vect.y
end

--------------------------------------------------------------------------------
-- Pointwise multiplication between two vectors.
-- @param vect Another vector.
-- @returns A new vector containing the result of the operation.
--------------------------------------------------------------------------------
function Vector2D:mul(vect)
  local new_vect = Vector2D(self.x, self.y)
  new_vect.x = new_vect.x * vect.x
  new_vect.y = new_vect.y * vect.y
  return new_vect
end

--------------------------------------------------------------------------------
-- Pointwise division between two vectors.
-- @param vect Another vector.
-- @returns A new vector containing the result of the operation.
--------------------------------------------------------------------------------
function Vector2D:div(vect)
  local new_vect = Vector2D(self.x, self.y)
  new_vect.x = new_vect.x / vect.x
  new_vect.y = new_vect.y / vect.y
  return new_vect
end

--------------------------------------------------------------------------------
-- Compute the squared distance between two vectors.
-- @param vect Another vector.
-- @returns The squared distance.
--------------------------------------------------------------------------------
function Vector2D:squareDistance(vect)
  return (self.x-vect.x)*(self.x-vect.x) + (self.y-vect.y)*(self.y-vect.y)
end

--------------------------------------------------------------------------------
-- Compare two vectors.
-- @param vect Another vector.
-- @returns A boolean indicating whether the coordinates of the two vectors are
--          the same.
--------------------------------------------------------------------------------
function Vector2D:equals(vect)
  return self.x == vect.x and self.y == vect.y
end

--------------------------------------------------------------------------------
-- Compute the euclidean norm of the vector.
-- @returns The norm of the vector.
--------------------------------------------------------------------------------
function Vector2D:norm()
  return math.sqrt(self:dot(self))
end

--------------------------------------------------------------------------------
-- Normalize the vector.
--------------------------------------------------------------------------------
function Vector2D:normalize()
  local norm = self:norm()
  self.x = self.x / norm
  self.y = self.y / norm
end

return Vector2D
