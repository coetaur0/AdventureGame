-- Definition of the AStar class.

local Object = require "lib/classic"
local Graph = require "engine/pathfinding/graph"
local GraphEdge = require "engine/pathfinding/graphedge"
local IndexedPriorityQueue = require "engine/pathfinding/indexedpriorityqueue"

local AStar = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new AStar object.
-- @param graph The graph on which the A-star algorithm must be applied.
-- @param source The index of the starting node for the path.
-- @param target The index of the end node in the path.
--------------------------------------------------------------------------------
function AStar:new(graph, source, target)
  self.graph = graph
  self.source = source
  self.target = target

  self.spt = {} -- Shortest path tree.
  self.fCost = {}
  self.gCost = {}
  self.sf = {} -- Search frontier.

  for _, node in ipairs(self.graph.nodes) do
    table.insert(self.fCost, 0)
    table.insert(self.gCost, 0)
  end

  self:search()
end

--------------------------------------------------------------------------------
-- Search the shortest path in the graph between the start and end nodes.
--------------------------------------------------------------------------------
function AStar:search()
  -- Priority queue to sort the nodes in the graph.
  local prioQueue = IndexedPriorityQueue(self.fCost)
  -- Insertion of the source as the first node.
  prioQueue:insert(self.source)

  -- While the priority queue is not empty, the search continues.
  while not prioQueue:isEmpty() do
    -- The next closest node is analysed. Its best edge is added to the
    -- shortest path tree.
    local nextClosestNode = prioQueue:pop()
    self.spt[nextClosestNode] = self.sf[nextClosestNode]

    -- If the target node was reached, the search is over.
    if nextClosestNode == target then
      return
    end

    -- Retrieve all the edges associated to the next closest node, and analyse
    -- each of them to find the best.
    local edges = self.graph.edges[nextClosestNode]
    for _, edge in ipairs(edges) do
      local hCost = self.graph.nodes[edge.to].position:sub(self.graph.nodes[self.target].position):norm()
      local newGCost = self.gCost[nextClosestNode] + edge.cost
      local to = edge.to

      if self.sf[edge.to] == nil then
        self.fCost[edge.to] = newGCost + hCost
        self.gCost[edge.to] = newGCost
        prioQueue:insert(edge.to)
        self.sf[edge.to] = edge
      elseif newGCost < self.gCost[edge.to] and self.spt[edge.to] == nil then
        self.fCost[edge.to] = newGCost + hCost
        self.gCost[edge.to] = newGCost
        prioQueue:reorderUp()
        self.sf[edge.to] = edge
      end
    end
  end
end

--------------------------------------------------------------------------------
-- Retrieve the path found with the A-star algorithm.
-- @returns The path.
--------------------------------------------------------------------------------
function AStar:getPath()
  local path = {}
  if self.target < 1 then
    return path
  end

  -- Start with the target node, and add each node that leads to it one by one.
  local node = self.target
  table.insert(path, node)
  while node ~= self.source and self.spt[node] ~= nil do
    node = self.spt[node].from
    table.insert(path, node)
  end

  -- Reverse the path so it starts from the source.
  local reversedPath = {}
  for i = #path, 1, -1 do
    table.insert(reversedPath, path[i])
  end

  return reversedPath
end

return AStar
