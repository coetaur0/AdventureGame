-- Definition of the Game class.
-- Aurelien Coet, 2017.

-- This class represents the state of the program when the user is playing (as
-- opposed to when the user is in the game's menu).

local Object = require "lib/classic"
local Actor = require "engine/entities/actor"
local Room = require "engine/entities/room"

-- Import of the table containing the definition for the player.
local playerDef = require "data/actors/hero"
local rooms = require "data/rooms"
local cutscenes = require "data/cutscenes"

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

  -- 'doorStates' is a list of booleans indicating whether each door in the game
  -- is locked (true) or not (false).
  doorsLocked = {}
  for roomName, room in pairs(rooms) do
    doorsLocked[roomName] = {}
    for j, door in ipairs(room.doors) do
      table.insert(doorsLocked[roomName], false)
    end
  end

  -- Creation of the initial room. 'room' is a global variable.
  room = Room("main", "left")
  -- 'nextRoom' will be used to transit to another room when the player clicks
  -- on an unlocked door and actually reaches it.
  nextRoom = nil

  -- List of messages that need to be printed on screen in the game.
  self.messages = {}

  self.state = "running"
  self.script = nil
  self.nextScriptInstruct = nil

  if cutscenes["main"] then
    self.script = cutscenes["main"]
    self:executeScript()
  end
end

--------------------------------------------------------------------------------
-- Update the state of the game.
--------------------------------------------------------------------------------
function Game:update(dt)
  if self.state == "cutscene" then
    self:executeScript()
  end


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
    message.timelen = message.timelen - dt
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

--------------------------------------------------------------------------------
-- Execute the instructions in the 'script' queue of the Game object.
-- Instructions are executed one after the other, and while there are
-- instructions to be executed, the game is in the special state 'cutscene'.
-- When there aren't any instructions left to execute in the 'script' queue,
-- the game goes back to its normal state and the player retrieves the control
-- of it.
--------------------------------------------------------------------------------
function Game:executeScript()
  -- The state of the game is set to 'cutscene' to take control from the user
  -- and to keep executing the instructions of the script while there are some.
  self.state = "cutscene"

  -- If an instruction is currently eing executed and hasn't finished, we keep
  -- executing it.
  if self.nextScriptInstruct then

    -- When the execution of an instruction is over, it is removed from the
    -- 'nextScriptInstruct' variable of the Game object.
    if self.nextScriptInstruct[1] == "movePlayer" then
      if player.destination:sub(player.position):norm() == 0 then
        self.nextScriptInstruct = nil
      end
    elseif self.nextScriptInstruct[1] == "addMessage" then
      if #self.messages == 0 then
        self.nextScriptInstruct = nil
      end
    end

  -- If the last instruction finished executing, we go to the next one (if there
  -- is any).
  else
    -- If all instructions were executed, the game goes back to its normal
    -- 'running' state.
    if #self.script == 0 then
      self.state = "running"
      self.script = nil
    -- Selection of the next instruction.
    else
      self.nextScriptInstruct = self.script[1]
      if self.nextScriptInstruct[1] == "movePlayer" then
        applyNewWalkPath(self.nextScriptInstruct[2], self.nextScriptInstruct[3])
      elseif self.nextScriptInstruct[1] == "addMessage" then
        self:addMessage(self.nextScriptInstruct[2], self.nextScriptInstruct[3],
                        self.nextScriptInstruct[4], self.nextScriptInstruct[5])
      end
      table.remove(self.script, 1)
    end
  end

end

return Game
