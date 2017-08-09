-- Table of tables containing the variables defining the items in the game.
-- Aurelien Coet, 2017.

local items = {
  book = {
    x = 950,
    y = 530,
    image = "assets/book.png",
    width = 128,
    height = 94,

    icon = "assets/book.png",
    onClickMessageRoom = "That's a book about cooking insects.",
    onClickActionRoom = "pick up",
    onClickActionMsgRoom = "That'll come in handy.",

    onClickMessageInventory = "Just a book about cooking bugs",
    onClickActionInventory = "useWith",
    useWith = "",
    onClickActionMsgInvetory = "Cool",
  }
}

return items
