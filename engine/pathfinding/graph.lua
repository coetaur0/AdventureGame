-- Definition of the Graph class.

local Object = require "lib/classic"
local GraphNode = require "engine/pathfinding/graphnode"
local GraphEdge = require "engine/pathfinding/graphedge"

local Graph = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new Graph object.
--------------------------------------------------------------------------------
function Graph:new()
  self.nodes = {}
  self.edges = {}
end

--------------------------------------------------------------------------------
-- Create a copy the the Graph.
-- @returns The copy.
--------------------------------------------------------------------------------
function Graph:clone()
  local new_graph = Graph()

  for i, v in ipairs(self.nodes) do
    table.insert(new_graph.nodes, v:clone())
  end

  for i, v in ipairs(self.edges) do
    table.insert(new_graph.edges, {})
    for _, v2 in ipairs(v) do
      table.insert(new_graph.edges[i], v2:clone())
    end
  end

  return new_graph
end

--------------------------------------------------------------------------------
-- Retrieve the edge between two nodes.
-- @param from Index of the node from which the edge starts.
-- @param to Index of the node to which the edge goes.
-- @returns The edge if it exists, nil otherwise.
--------------------------------------------------------------------------------
function Graph:getEdge(from, to)
  local from_edges = self.edges[from]
  for _, edge in ipairs(from_edges) do
    if edge.to == to then
      return edge
    end
  end
  return nil
end

--------------------------------------------------------------------------------
-- Add a node to the graph.
-- @param node The node to add to the graph.
--------------------------------------------------------------------------------
function Graph:addNode(node)
  table.insert(self.nodes, node)
  table.insert(self.edges, {})
end

--------------------------------------------------------------------------------
-- Add an edge to the graph.
-- @param edge The edge to add to the graph.
--------------------------------------------------------------------------------
function Graph:addEdge(edge)
  if self:getEdge(edge.from, edge.to) == nil then
    table.insert(self.edges[edge.from], edge)
  end
  if self:getEdge(edge.to, edge.from) == nil then
    table.insert(self.edges[edge.to], GraphEdge(edge.to, edge.from, edge.cost))
  end
end

return Graph
