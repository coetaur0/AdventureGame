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
  -- 'nextRoom' will be used to transit to another room when the player clicks
  -- on an unlocked door and actually reaches it.
  nextRoom = nil
end

--------------------------------------------------------------------------------
-- Update the state of the game.
--------------------------------------------------------------------------------
function Game:update(dt)
  -- Before updating the current room in the game, we check if it has changed
  -- (i.e. the player used a door).
  if nextRoom then
    room = nextRoom
    nextRoom = nil
  end

  -- Update of the room.
  room:update(dt)
end

--------------------------------------------------------------------------------
-- Draw all the elements of the game.
--------------------------------------------------------------------------------
function Game:draw()
  room:draw()
end

--------------------------------------------------------------------------------
-- Change the current room in the game.
-- @param roomName Name of the new room to load.
-- @param roomEntry Entrance the player will appear on in the room.
--------------------------------------------------------------------------------
function Game:changeRoom(roomName, roomEntry)
  nextRoom = Room(roomName, roomEntry)
end

return Game
