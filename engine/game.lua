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
  -- Creation of the player. 'player' is a global variable.
  player = Actor(playerDef.name, playerDef.x, playerDef.y, playerDef.speed,
                 playerDef.width, playerDef.height, playerDef.animations)

  -- 'itemStates' is a list of strings indicating the state of each item in the
  -- game: in a room (at its initial location), in the inventory of the player,
  -- or destroyed (it has already been used by the player).
  itemStates = {}
  local items = require "data/items"
  for i, item in pairs(items) do
    itemStates[i] = "inRoom"
  end

  -- Creation of the initial room. 'room' is a global variable.
  room = Room("main", "left")
  -- 'nextRoom' will be used to transit to another room when the player clicks
  -- on an unlocked door and actually reaches it.
  nextRoom = nil

  -- List of messages that need to be printed on screen in the game.
  self.messages = {}
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

  -- Update of the room's state.
  room:update(dt)

  -- Update of the list of messages in the game. Messages are erased (not
  -- displayed anymore) after a given time.
  for i, message in ipairs(self.messages) do
    message.timelen = message.timelen - 1
    if message.timelen <= 0 then
      table.remove(self.messages, i)
    end
  end
end

--------------------------------------------------------------------------------
-- Draw all the elements of the game.
--------------------------------------------------------------------------------
function Game:draw()
  -- Draw the room and its elements.
  room:draw()

  -- Draw the messages to be displayed.
  for i, message in ipairs(self.messages) do
    love.graphics.print(message.text, message.x, message.y, 0, 1.5)
  end
end

--------------------------------------------------------------------------------
-- Change the current room in the game.
-- @param roomName Name of the new room to load.
-- @param roomEntry Entrance the player will appear on in the room.
--------------------------------------------------------------------------------
function Game:changeRoom(roomName, roomEntry)
  nextRoom = Room(roomName, roomEntry)
end

--------------------------------------------------------------------------------
-- Add a message to the list of messages that must be printed in the game's
-- window.
-- @param content Content of the message.
-- @param x_pos Position of the message on the x-axis.
-- @param y_pos Position of the message on the y-axis.
-- @param timesteps Number of timesteps before the message must stop being
--                  displayed.
--------------------------------------------------------------------------------
function Game:addMessage(content, x_pos, y_pos, timesteps)
  table.insert(self.messages, {text = content, x = x_pos, y = y_pos, timelen = timesteps})
end

return Game
