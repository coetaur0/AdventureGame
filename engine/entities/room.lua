-- Definition of the Room class.
-- Aurelien Coet, 2017.

local Object = require "lib/classic"
local Vector2D = require "lib/vector2d"
local WalkArea = require "engine/pathfinding/walkarea"

local gamera = require "lib/gamera"

-- Include the Shädows library for lighting.
local Shadows = require("shadows")
local LightWorld = require("shadows.LightWorld")
local Light = require("shadows.Light")

-- The definition table for the rooms is retrieved.
local rooms = require "data/rooms"

local Room = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new Room object.
-- @param roomName The name of the room that must be instantiated (name of the
--                 room in the rooms definition table in 'data/').
--------------------------------------------------------------------------------
function Room:new(roomName, entry)
  local currentRoom = rooms[roomName]

  self.background = love.graphics.newImage(currentRoom.background)

  -- A camera is created for the room.
  self.camera = gamera.new(0, 0, currentRoom.size[1], currentRoom.size[2])

  -- The player is placed in the room. ('player' is a global variable.)
  player.position.x = currentRoom.entrances[entry][1]
  player.position.y = currentRoom.entrances[entry][2]
  player.destination.x = player.position.x
  player.destination.y = player.position.y
  player.animations.x = player.position.x
  player.animations.y = player.position.y

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
  local mouseX, mouseY = self.camera:toWorld(love.mouse.getX(),love.mouse.getY())

  -- The new shortest path between the position of the player and the position
  -- of the mouse is recomputed at every iteration of the game loop in the room.
  self.walkindices = self.walkableArea:getShortestPath(player.position, Vector2D(mouseX, mouseY))

  player:update(dt)

  self.camera:setPosition(player.position.x, player.position.y)

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

    -- The shortest path between the player and the position of the mouse is drawn
    -- with a red line.
    love.graphics.setColor(255, 0, 0)
    if #self.walkindices > 1 then
      for i = 1, #self.walkindices-1 do
        love.graphics.line(self.walkableArea.walkGraph.nodes[self.walkindices[i]].position.x,
                           self.walkableArea.walkGraph.nodes[self.walkindices[i]].position.y,
                           self.walkableArea.walkGraph.nodes[self.walkindices[i+1]].position.x,
                           self.walkableArea.walkGraph.nodes[self.walkindices[i+1]].position.y
                           )
      end
    end

    -- The player is drawn in the room.
    player:draw()

  end)

  -- The lights are drawn last and outside of the camera:draw() function
  -- so that they have an effect on every other entity in the room.
  if self.lightWorld ~= nil then
    self.lightWorld:Draw()
  end
end

return Room
