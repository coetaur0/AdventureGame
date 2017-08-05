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
  self.leftEdge = self.position.x - self.width/2
  self.rightEdge = self.position.x + self.width/2
  self.topEdge = self.position.y - self.height/2
  self.bottomEdge = self.position.y + self.height/2
  self.locked = locked
  self.nextRoom = nextRoom
  self.roomEntry = roomEntry
end

--------------------------------------------------------------------------------
-- Update the state of the door: if the player's position is inside it and he
-- clicked on it, it is being used.
--------------------------------------------------------------------------------
function Door:update(dt)
  if player.position.x > self.leftEdge and
     player.position.x < self.rightEdge and
     player.position.y > self.topEdge and
     player.position.y < self.bottomEdge then

       if room.playerLeavingRoom then
         if not self.locked then
           game:changeRoom(self.nextRoom, self.roomEntry)
         else
           -- If the door's locked, a message is displayed on screen to
           -- inform the player.
           game:addMessage("That door is locked...",
                           player.position.x + player.width/2,
                           player.position.y - player.height/2,
                           100
                          )
           room.playerLeavingRoom = false
         end
       end
  end
end

return Door
