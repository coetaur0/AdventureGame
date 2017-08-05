-- Definition of the Item class.
-- Aurelien Coet, 2017.

local Object = require "lib/classic"
local Vector2D = require "lib/vector2d"

-- Include the Sodapop library for sprites.
local sodapop = require "lib/sodapop"

-- The definition table for the items in the game is retrieved.
local items = require "data/items"

local Item = Object:extend()

--------------------------------------------------------------------------------
-- Instantiate a new Item object.
-- @param The name of the item in the definition table for all items in the
-- game.
--------------------------------------------------------------------------------
function Item:new(itemName)
  local itemDef = items[itemName]

  self.position = Vector2D(itemDef.x, itemDef.y)

  local image = love.graphics.newImage(itemDef.image)
  self.sprite = sodapop.newSprite(image, self.position.x, self.position.y)
  self.width = itemDef.width
  self.height = itemDef.height

  self.leftEdge = self.position.x - self.width/2
  self.rightEdge = self.position.x + self.width/2
  self.topEdge = self.position.y - self.height/2
  self.bottomEdge = self.position.y + self.height/2

  self.icon = love.graphics.newImage(itemDef.icon)

  self.onClickMessage = itemDef.onClickMessage
  self.onClickAction = itemDef.onClickAction

  -- Variable indicating whether the player clicked on the item.
  self.clickedLeft = false
  self.clickedRight = false
  self.state = itemStates[itemName]
end

--------------------------------------------------------------------------------
-- Show the message associated to the item when the player left clicks on it.
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
-- Update the item.
--------------------------------------------------------------------------------
function Item:update(dt)
  self.sprite:update(dt)
  if self.clickedLeft and player.destination:sub(player.position):norm() == 0 then
    self:onLeftClick()
  end
end

--------------------------------------------------------------------------------
-- Draw the item on screen.
--------------------------------------------------------------------------------
function Item:draw()
  self.sprite:draw()
end

return Item
