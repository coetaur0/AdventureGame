-- Table of tables containing the variables defining the rooms in the game.
-- Aurelien Coet, 2017.

-- This is a prototype. The final format should include the positions of NPCs
-- and links to their definition tables, as well as the positions of objects in
-- the room, etc.
local rooms = {
  -- Main room : just a simple test.
  main = {
    background = "assets/living_room.png",

    size = {1280, 720},

    -- Possible initial positions of the player in the room.
    entrances = {
      left = {100, 356}
    },

    -- List of doors in the room.
    doors = {
      {x = 100, y = 356, width = 95, height = 214, locked = false,
       nextRoom = "secondary", roomEntry = "right"}
    },

    -- List of vertices defining the polygons that make up the walkable area
    -- of the room. The first table in 'polygons' is the main walkable area, the
    -- other ones define obstacles.
    polygons = {
      -- Walkable area.
      {
        {84, 356},
        {232, 300},
        {260, 300},
        {297, 332},
        {427, 332},
        {475, 300},
        {513, 330},
        {750, 330},
        {795, 300},
        {1048, 300},
        {1196, 356},
        {1196, 605},
        {84, 605}
      }
      -- Obstacles.
      -- None
    },

    -- List of positions and radius for lights in the room.
    lights = nil
  },

  -- Secondary room.
  secondary = {
    background = "assets/bedroom.png",

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
        {633, 350},
        {633, 550},
        {1195, 550},
        {1195, 602},
        {84, 602}
      }
    }
  }
}

return rooms
