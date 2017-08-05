-- Definition of the Actor class.
-- Aurelien Coet, 2017.

-- An actor is a character in the game. Actors (including the player) are always
-- located in one of the game's room, at a given position, and they can move
-- inside it or even leave it. They are represented on screen with animations.

local Vector2D = require "lib/vector2d"
local Object = require "lib/classic"

local Actor = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new Actor object.
-- @param x Position of the actor on the x-axis of the screen.
-- @param y Position of the actor on the y-axis of the screen.
-- @param speed Speed at which the actor moves in-game.
-- @param width Width of the animations for the actor.
-- @param height Height of the animations for the actor.
-- @param animations Set of animations for the different states of the actor.
--------------------------------------------------------------------------------
function Actor:new(name, x, y, speed, width, height, animations)
  self.name = name
  self.position = Vector2D(x, y)
  self.destination = Vector2D(x, y)
  self.path = {}
  self.speed = speed
  self.width = width
  self.height = height
  self.animations = animations
end

--------------------------------------------------------------------------------
-- Update the animation of the character according to its movement.
-- @param direction A vector with the direction in which the actor is moving.
--------------------------------------------------------------------------------
function Actor:updateAnimation(direction)
  if math.abs(direction.x) > math.abs(direction.y) then
    if direction.x > 0 then
      self.animations:switch("walking_right")
    else
      self.animations:switch("walking_left")
    end
  else
    if direction.y > 0 then
      self.animations:switch("walking_down")
    else
      self.animations:switch("walking_up")
    end
  end
end

--------------------------------------------------------------------------------
-- Move an actor to a new destination following a given path.
-- @param path An array of vectors indicating the path for the actor to follow.
--------------------------------------------------------------------------------
function Actor:move(path)
  self.path = path

  if #self.path > 0 then
    self.destination = self.path[1]
    table.remove(self.path, 1)

    local direction = self.destination:sub(self.position)
    self:updateAnimation(direction)
  end
end

--------------------------------------------------------------------------------
-- Update the state of the actor in the game loop.
-- @param dt Timestep.
--------------------------------------------------------------------------------
function Actor:update(dt)
  local direction = self.destination:sub(self.position)

  -- If the actor reached its current destination in the path that was
  -- attributed to it, we update its destination according to the path.
  if direction:norm() == 0 then
    if #self.path == 0 then
      self.animations:switch("idle")
    else
      -- If the actor hasn't finished completing its path, we update its
      -- destination and its animation according to the new direction taken
      -- to reach the next destination.
      self.destination = self.path[1]
      table.remove(self.path, 1)

      local direction = self.destination:sub(self.position)
      self:updateAnimation(direction)
    end

  -- If the actor hasn't reached its current destination yet, it moves further
  -- towards it.
  else
    -- If the direction is longer than 'speed * dt', we normalize it and
    -- multiply it by 'speed * dt' to make the actor move by such a distance.
    if direction:norm() > self.speed * dt then
      direction:normalize()
      direction.x = direction.x * self.speed * dt
      direction.y = direction.y * self.speed * dt
    end

    -- Update of the position of the actor.
    self.position = self.position:add(direction)

    -- Update of the position of the animation of the actor.
    self.animations.x = self.position.x
    self.animations.y = self.position.y

    self.animations:update(dt)
  end
end

--------------------------------------------------------------------------------
-- Draw the actor on the screen.
--------------------------------------------------------------------------------
function Actor:draw()
  self.animations:draw()
end

return Actor
