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
-- Modify the walk path of the player to make him move to a new destination.
-- @param x_dest New destination of the player on the x-axis.
-- @param y_dest New destination of the player on the y-axis.
--------------------------------------------------------------------------------
function applyNewWalkPath(x_dest, y_dest)
  local mouseX, mouseY = room.camera:toWorld(x_dest, y_dest)

  -- Reset the walk path of the player.
  room.walkpath = {}

  -- The new shortest path between the position of the player and his new destination
  -- is computed.
  room.walkindices = room.walkableArea:getShortestPath(player.position, Vector2D(mouseX, mouseY))

  for i, v in ipairs(room.walkindices) do
    table.insert(room.walkpath, Vector2D(room.walkableArea.walkGraph.nodes[v].position.x,
                                         room.walkableArea.walkGraph.nodes[v].position.y
                                         )
                )
  end
  -- The first element in the shortest path computed with A-star is the
  -- position of the player: we remove it from the path he must take.
  table.remove(room.walkpath, 1)

  -- Add the new walkpath to the state of the player.
  player:move(room.walkpath)
end

--------------------------------------------------------------------------------
-- Callback function to handle mouse buttons being pressed.
--------------------------------------------------------------------------------
function love.mousepressed(x, y, button, istouch)
  if button == 1 then

    applyNewWalkPath(x, y)

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
    -- (left click).
    for i, item in ipairs(room.items) do
      if x > item.leftEdge and
         x < item.rightEdge and
         y > item.topEdge and
         y < item.bottomEdge then
           item.clickedLeft = true
      else
        item.clickedLeft = false
      end
    end
  end
end
