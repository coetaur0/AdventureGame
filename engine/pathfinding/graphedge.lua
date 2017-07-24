-- Definition of the GraphEdge class.

local Object = require "lib/classic"

local GraphEdge = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new GraphEdge object.
-- @param from Index of the node from which the edge starts.
-- @param to Index of the edge to which the edge goes.
-- @param cost Cost associated to the edge.
--------------------------------------------------------------------------------
function GraphEdge:new(from, to, cost)
  self.from = from
  self.to = to
  self.cost = cost or 1.0
end

--------------------------------------------------------------------------------
-- Create a copy of the GraphEdge.
-- @returns The copy.
--------------------------------------------------------------------------------
function GraphEdge:clone()
  return GraphEdge(self.from, self.to, self.cost)
end

return GraphEdge
