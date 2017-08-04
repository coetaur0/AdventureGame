-- Definition of the Door class.
-- Aurelien Coet, 2017.

local Object = require "lib/classic"
local Vector2D = require "lib/vector2d"

local Door = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new Door object.
-- @param x Position of the door on the x-axis.
-- @param y Position of the door on the y-axis.
-- @param width Width of the door.
-- @param height Height of the door.
-- @param locked Boolean indicating whether the door is locked or not.
-- @param nextRoom Name of the room to which the door leads.
-- @param roomEntry Name of the entrance to the room to which the door leads.
--------------------------------------------------------------------------------
function Door:new(x, y, width, height, locked, nextRoom, roomEntry)
  self.position = Vector2D(x, y)
  self.width = width
  self.height = height
  self.locked = locked
  self.nextRoom = nextRoom
  self.roomEntry = roomEntry
end

--------------------------------------------------------------------------------
-- Use a door to change the room in which the player is located.
--------------------------------------------------------------------------------
function Door:use()
  if not self.locked then
    room = Room(self.nextRoom, self.roomEntry)
  end
end

return Door
