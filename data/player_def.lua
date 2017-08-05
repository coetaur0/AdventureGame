-- Data for the definition of the player.
-- Aurelien Coet, 2017.

-- Include the Sodapop library for animations.
local sodapop = require "lib/sodapop"

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

-- Definition of the player, including its animations.
local playerDef = {
  name = "player",
  init_x = 28/2,
  init_y = 200,
  speed = 250,
  width = 168,
  height = 236,
  animations = playerAnims
}

return playerDef
