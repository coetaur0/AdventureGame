-- Definition of the GraphNode class.

local Object = require "lib/classic"
local Vector2D = require "lib/vector2d"

local GraphNode = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new GraphNode object.
-- @param position A vector containing the position of the node.
--------------------------------------------------------------------------------
function GraphNode:new(position)
  self.position = position
end

--------------------------------------------------------------------------------
-- Create a copy of the GraphNode.
-- @returns The copy.
--------------------------------------------------------------------------------
function GraphNode:clone()
  return GraphNode(Vector2D(self.position.x, self.position.y))
end

return GraphNode
