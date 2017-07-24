-- Definition of the Game class.
-- Aurelien Coet, 2017.

local Object = require "lib/classic"
local Actor = require "engine/entities/actor"
local Room = require "engine/entities/room"

-- Include the Sodapop library for animations.
local sodapop = require "lib/sodapop"

local Game = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new game.
--------------------------------------------------------------------------------
function Game:new()
  -- Creation of the animations for the main character (the player).
  local animImg = love.graphics.newImage("assets/player.png")

  local playerAnims = sodapop.newAnimatedSprite(0, 0)
  playerAnims:addAnimation("idle", {
    image       = animImg,
    frameWidth  = 168,
    frameHeight = 236,
    frames      = {
      {2, 2, 2, 2, .5}
    }
  })
  playerAnims:addAnimation("walking_right", {
    image       = animImg,
    frameWidth  = 168,
    frameHeight = 236,
    frames      = {
      {1, 3, 3, 3, .15}
    }
  })
  playerAnims:addAnimation("walking_left", {
    image       = animImg,
    frameWidth  = 168,
    frameHeight = 236,
    frames      = {
      {1, 4, 3, 4, .15}
    }
  })
  playerAnims:addAnimation("walking_up", {
    image       = animImg,
    frameWidth  = 168,
    frameHeight = 236,
    frames      = {
      {1, 1, 3, 1, .15}
    }
  })
  playerAnims:addAnimation("walking_down", {
    image       = animImg,
    frameWidth  = 168,
    frameHeight = 236,
    frames      = {
      {1, 2, 3, 2, .15}
    }
  })

  -- Creation of the player.
  player = Actor("player", 28/2, 200, 250, 28, 40, playerAnims)

  -- Creation of the room.
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
