-- Definition of the IndexedPriorityQueue class.

local Object = require "lib/classic"

local IndexedPriorityQueue = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new IndexedPriorityQueue object.
--------------------------------------------------------------------------------
function IndexedPriorityQueue:new(keys)
  self.keys = keys
  self.data = {}
end

--------------------------------------------------------------------------------
-- Insert a new index in the queue and reorder it.
-- @param index The index to insert.
--------------------------------------------------------------------------------
function IndexedPriorityQueue:insert(index)
  table.insert(self.data, index)
  self:reorderUp()
end

--------------------------------------------------------------------------------
-- Pop the first value in the queue.
-- @returns The first value in the queue.
--------------------------------------------------------------------------------
function IndexedPriorityQueue:pop()
  local r = self.data[1]
  self.data[1]=self.data[#self.data]
	table.remove(self.data) -- Pop.
	self:reorderDown()
  return r
end

--------------------------------------------------------------------------------
-- Reorder the queue in ascending order.
--------------------------------------------------------------------------------
function IndexedPriorityQueue:reorderUp()
  for i = #self.data, 2, -1 do
    if self.keys[self.data[i]] < self.keys[self.data[i-1]] then
      local tmp = self.data[i]
      self.data[i] = self.data[i-1]
      self.data[i-1] = tmp
    else
      return
    end
  end
end

--------------------------------------------------------------------------------
-- Reorder the queue in descending order.
--------------------------------------------------------------------------------
function IndexedPriorityQueue:reorderDown()
  for i = 1, #self.data-1 do
    if self.keys[self.data[i]] > self.keys[self.data[i+1]] then
      local tmp = self.data[i]
      self.data[i] = self.data[i+1]
      self.data[i+1] = tmp
    else
      return
    end
  end
end

--------------------------------------------------------------------------------
-- Check whether the queue is empty.
-- @returns A boolean indicating whether the queue is empty.
--------------------------------------------------------------------------------
function IndexedPriorityQueue:isEmpty()
  return #self.data == 0
end

return IndexedPriorityQueue
