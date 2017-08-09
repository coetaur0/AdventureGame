-- Table of tables containing the variables defining the rooms in the game.
-- Aurelien Coet, 2017.

-- This is a prototype. The final format should include the positions of NPCs
-- and links to their definition tables, as well as the positions of objects in
-- the room, etc.
local rooms = {
  -- Main room : just a simple test.
  main = {
    background = "assets/living_room.png",
    scalingImg = "assets/bedroom_scaling.png",

    size = {1280, 720},

    -- Possible initial positions of the player in the room.
    entrances = {
      left = {100, 356}
    },

    -- List of doors in the room.
    doors = {
      {x = 100, y = 332, width = 95, height = 214, nextRoom = "secondary",
       roomEntry = "right", lockedMsg = "Oops, that door's locked..."}
    },

    -- List of vertices defining the polygons that make up the walkable area
    -- of the room. The first table in 'polygons' is the main walkable area, the
    -- other ones define obstacles.
    polygons = {
      -- Walkable area.
      {
        {84, 356},
        {232, 330},
        {260, 330},
        {297, 362},
        {427, 362},
        {475, 330},
        {513, 360},
        {750, 360},
        {795, 330},
        {1048, 330},
        {1196, 356},
        {1196, 605},
        {84, 605}
      }
      -- Obstacles.
      -- None
    },

    items = {
      "book"
    },

    -- List of positions and radius for lights in the room.
    lights = nil
  },

  -- Secondary room.
  secondary = {
    background = "assets/bedroom.png",
    scalingImg = "assets/bedroom_scaling.png",

    size = {1280, 720},

    entrances = {
      right = {1195, 602}
    },

    doors = {
      {x = 1195, y = 570, width = 95, height = 214, locked = false,
       nextRoom = "main", roomEntry = "left"}
    },

    polygons = {
      {
        {210, 350},
        {225, 350},
        {273, 365},
        {495, 365},
        {531, 350},
        {633, 350},
        {633, 550},
        {1195, 550},
        {1195, 602},
        {84, 602}
      }
    },

    items = {},

    lights = nil
  }
}

return rooms
