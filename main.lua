-- Definition of the game's main 'loop'.
-- Aurelien Coet, 2017.

local Game = require "engine/game"
local Vector2D = require "lib/vector2d"

function love.load()
  game = Game()
end

function love.update(dt)
  game:update(dt)
end

function love.draw()
  game:draw()

  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

--------------------------------------------------------------------------------
-- Callback function to handle mouse buttons being pressed.
--------------------------------------------------------------------------------
function love.mousepressed(x, y, button, istouch)
  if game.state == "running" then

    -- If a message was being displayed in-game, it is erased when the
    -- player moves.
    game.message = nil

    -- A new path between the player's position and the position where the
    -- mouse was clicked is applied to the player.
    local mouseX, mouseY = room.camera:toWorld(x, y)
    player:newWalkPath(mouseX, mouseY, room)

    -- Check if the player clicked on a door to go to another room.
    for i, door in ipairs(room.doors) do
      if x > door.leftEdge and
         x < door.rightEdge and
         y > door.topEdge and
         y < door.bottomEdge then
           room.playerLeavingRoom = true
           break
      end
      room.playerLeavingRoom = false
    end

    -- Check if the player clicked on an item in the room to observe it
    -- (left click) or use it/pick it up (right click).
    for i, item in pairs(room.items) do
      if x > item.leftEdge and
         x < item.rightEdge and
         y > item.topEdge and
         y < item.bottomEdge then

           if button == 1 then
             item.clickedLeft = true
           elseif button == 2 then
             item.clickedRight = true
           end
      else
        item.clickedLeft = false
        item.clickedRight = false
      end
    end
  end
end
