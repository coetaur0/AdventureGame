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

-- Callback function to handle mouse buttons being pressed.
function love.mousepressed(x, y, button, istouch)
  if button == 1 then
    room.walkpath = {}
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
end
