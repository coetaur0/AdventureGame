-- Definition of the Game class.
-- Aurelien Coet, 2017.

local Object = require "lib/classic"
local Actor = require "engine/entities/actor"
local Room = require "engine/entities/room"

-- Import of the table containing the definition for the player.
local playerDef = require "data/player_def"

local Game = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new game.
--------------------------------------------------------------------------------
function Game:new()
  -- Creation of the player.
  player = Actor(playerDef.name, playerDef.x, playerDef.y, playerDef.speed,
                 playerDef.width, playerDef.height, playerDef.animations)

  -- Creation of the initial room.
  room = Room("main", "left")
end

--------------------------------------------------------------------------------
-- Update the state of the game.
--------------------------------------------------------------------------------
function Game:update(dt)
  -- Update of the room.
  room:update(dt)
end

--------------------------------------------------------------------------------
-- Draw all the elements of the game.
--------------------------------------------------------------------------------
function Game:draw()
  room:draw()
end

return Game
