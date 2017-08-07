-- Definition of the Item class.
-- Aurelien Coet, 2017.

-- An item is an object that can be interacted with in the game (it can always
-- be 'observed' or 'looked at' when the player left clicks on it, and sometimes
-- picked up if the player right clicks on it).

local Object = require "lib/classic"
local Vector2D = require "lib/vector2d"

-- Include the Sodapop library for sprites.
local sodapop = require "lib/sodapop"

-- The definition table for the items in the game is retrieved.
local items = require "data/items"

local Item = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new Item object.
-- @param itemName Name of the item in the definition table for all items in the
--                 game.
--------------------------------------------------------------------------------
function Item:new(itemName)
  local itemDef = items[itemName]

  self.position = Vector2D(itemDef.x, itemDef.y)

  -- Sprite of the item when inside a room.
  local image = love.graphics.newImage(itemDef.image)
  self.sprite = sodapop.newSprite(image, self.position.x, self.position.y)
  self.width = itemDef.width
  self.height = itemDef.height

  self.leftEdge = self.position.x - self.width/2
  self.rightEdge = self.position.x + self.width/2
  self.topEdge = self.position.y - self.height/2
  self.bottomEdge = self.position.y + self.height/2

  -- Representation of the item when it is inside the player's inventory.
  self.icon = love.graphics.newImage(itemDef.icon)

  -- Message to display when the player left clicks on the item.
  self.onClickMessage = itemDef.onClickMessage

  -- Action to perform or message to display when the player right clicks on the
  -- item.
  self.onClickAction = itemDef.onClickAction

  -- Variables indicating whether the player clicked on the item the last time
  -- he clicked somewhere.
  self.clickedLeft = false
  self.clickedRight = false
  self.state = itemStates[itemName]
end

--------------------------------------------------------------------------------
-- Show the message associated to the item when the player left clicks on it
-- (when the item is inside a room).
--------------------------------------------------------------------------------
function Item:onLeftClick()
  local x = 0
  local y = player.position.y - player.height/2
  if player.position.x < room.size[1]/2 then
    x = player.position.x + player.width/2
  else
    x = player.position.x - player.width - love.graphics.getFont():getWidth(self.onClickMessage)
  end
  game:addMessage(self.onClickMessage, x, y, 3)
  self.clickedLeft = false
end

--------------------------------------------------------------------------------
-- Execute the action associated to the item when the player right clicks on it
-- (when the item is inside a room).
--------------------------------------------------------------------------------
function Item:onRightClick()
  if self.onClickAction == "pick up" then
    -- TODO
  elseif self.onClickAction == "use" then
    -- TODO

  -- Any other action than those above consists in a message that is displayed
  -- to tell the player there is nothing particular to do with the item.
  else
    local x = 0
    local y = player.position.y - player.height/2
    if player.position.x < room.size[1]/2 then
      x = player.position.x + player.width/2
    else
      x = player.position.x - player.width - love.graphics.getFont():getWidth(self.onClickAction)
    end
    game:addMessage(self.onClickAction, x, y, 3)
  end

  self.clickedRight = false
end

--------------------------------------------------------------------------------
-- Update the item's state.
--------------------------------------------------------------------------------
function Item:update(dt)
  self.sprite:update(dt)
  if self.clickedLeft and player.destination:sub(player.position):norm() == 0 then
    self:onLeftClick()
  elseif self.clickedRight and player.destination:sub(player.position):norm() == 0 then
    self:onRightClick()
  end
end

--------------------------------------------------------------------------------
-- Draw the item on screen.
--------------------------------------------------------------------------------
function Item:draw()
  self.sprite:draw()
end

return Item
