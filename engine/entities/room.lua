-- Definition of the Room class.
-- Aurelien Coet, 2017.

-- A room is an area of the game in which the player can move. It has a
-- background, and it contains items that can be observed, and sometimes even
-- picked up. Other actors can also be in the room, and they can be interacted
-- with.

local Object = require "lib/classic"
local Vector2D = require "lib/vector2d"
local WalkArea = require "engine/pathfinding/walkarea"
local Door = require "engine/entities/door"
local Item = require "engine/entities/item"

local gamera = require "lib/gamera"

-- Include the Shädows library for lighting.
local Shadows = require("shadows")
local LightWorld = require("shadows.LightWorld")
local Light = require("shadows.Light")

-- The definition table for the rooms is retrieved.
local rooms = require "data/rooms"
-- The definition table for the items is retrieved.
local items = require "data/items"

local Room = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new Room object.
-- @param roomName The name of the room that must be instantiated (name of the
--                 room in the rooms definition table in 'data/').
--------------------------------------------------------------------------------
function Room:new(roomName, entry)
  local currentRoom = rooms[roomName]

  self.background = love.graphics.newImage(currentRoom.background)
  self.scalingImg = love.image.newImageData(currentRoom.scalingImg)
  self.size = currentRoom.size

  -- A camera is created for the room.
  self.camera = gamera.new(0, 0, currentRoom.size[1], currentRoom.size[2])

  -- The player is placed in the room. ('player' is a global variable.)
  player:setPositionInRoom(currentRoom.entrances[entry][1],
                           currentRoom.entrances[entry][2],
                           self.scalingImg)

  self.camera:setPosition(player.position.x, player.position.y)

  -- The walkable area of the room is defined.
  self.walkableArea = WalkArea()
  for i, polygon in ipairs(currentRoom.polygons) do
    self.walkableArea:addPolygon()
    for _, vertex in ipairs(polygon) do
      self.walkableArea.polygons[i]:addVertex(vertex[1], vertex[2])
    end
  end

  self.walkableArea:createGraph()

  -- Attributes for pathfinding.
  self.walkindices = {}
  self.walkpath = {}

  -- The doors in the room are instantiated.
  self.doors = {}
  for i, door in ipairs(currentRoom.doors) do
    table.insert(self.doors, Door(door.x, door.y, door.width, door.height,
                                  doorsLocked[roomName][i], door.lockedMsg,
                                  door.nextRoom, door.roomEntry))
  end
  -- Boolean indicating whether the player has clicked on a door to leave the
  -- room.
  self.playerLeavingRoom = false

  -- Creation of the items inside the room.
  self.items = {}
  for i, itemName in ipairs(currentRoom.items) do
    if itemStates[itemName] == "inRoom" then
      self.items[itemName] = Item(itemName)
    end
  end

  -- The lights in the room are created.
  if currentRoom.lights ~= nil then
    self.lightWorld = LightWorld:new()

    self.lights = {}
    for i, light in ipairs(currentRoom.lights) do
      table.insert(self.lights, Light:new(self.lightWorld, light[3]))
      self.lights[i]:SetPosition(light[1], light[2])
    end
  else
    self.lightWorld = nil
  end
end

--------------------------------------------------------------------------------
-- Update the state of the room.
--------------------------------------------------------------------------------
function Room:update(dt)
  player:update(dt, self.scalingImg)

  -- The camera always follows the player.
  self.camera:setPosition(player.position.x, player.position.y)

  for i, door in ipairs(self.doors) do
    door:update(dt, player, self)
  end

  for i, item in pairs(self.items) do
    item:update(dt, player, self)
  end

  if self.lightWorld ~= nil then
    self.lightWorld:Update()
  end
end

--------------------------------------------------------------------------------
-- Draw the elements of the room.
--------------------------------------------------------------------------------
function Room:draw()

  -- Draw the content of the room which is seen with the camera.
  self.camera:draw(function(l,t,w,h)

    love.graphics.draw(self.background)

    -- The polygons defining the walkable area are drawn with white lines and
    -- circles.
    love.graphics.setColor(255, 255, 255)
    for _, polygon in ipairs(self.walkableArea.polygons) do
      for i, vertex in ipairs(polygon.vertices) do
        love.graphics.circle("fill", vertex.x, vertex.y, 4)
        next_vertex = polygon.vertices[i % #polygon.vertices + 1]
        love.graphics.line(vertex.x, vertex.y, next_vertex.x, next_vertex.y)
      end
    end

    -- All the elements in the room (including the player) are added to a queue
    -- in order to be drawn.
    local drawables = {}
    table.insert(drawables, player)

    for i, item in pairs(self.items) do
      table.insert(drawables, item)
    end

    -- The queue of elements to be drawn is sorted in ascending order of the
    -- elements' y positions in the room.
    table.sort(drawables, function(a, b)
                 return a.position.y+a.height/2 < b.position.y+b.height/2 end)

    for y, drawable in ipairs(drawables) do
      drawable:draw()
    end

  end)

  -- The lights are drawn last and outside of the camera:draw() function
  -- so that they have an effect on every other entity in the room.
  if self.lightWorld ~= nil then
    self.lightWorld:Draw()
  end
end

--------------------------------------------------------------------------------
-- Remove an item from the room.
-- @param itemName Name of the item to be removed.
--------------------------------------------------------------------------------
function Room:removeItem(itemName)
  self.items[itemName] = nil
end

return Room
