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
  self.pathIndices = {}
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
-- Compute the new walkpath of an actor in order to make it move towards a new
-- destination.
-- @param x_dest Final destination of the actor on the x-axis.
-- @param y_dest Final destination of the actor on the y-axis.
--------------------------------------------------------------------------------
function Actor:newWalkPath(x_dest, y_dest)
  -- Reset the walk path of the actor.
  self.path = {}

  -- The shortest path between the position of the actor and its new destination
  -- is computed.
  self.pathIndices = room.walkableArea:getShortestPath(self.position, Vector2D(x_dest, y_dest))

  local new_path = {}
  for i, v in ipairs(self.pathIndices) do
    table.insert(new_path, Vector2D(room.walkableArea.walkGraph.nodes[v].position.x,
                                    room.walkableArea.walkGraph.nodes[v].position.y))
  end

  -- The first element in the shortest path computed with A-star is the
  -- position of the actor: we remove it from the path it must take.
  table.remove(new_path, 1)

  self:move(new_path)
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
      self:move(self.path)
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
