-- Table of tables containing the scripts of the cutscenes for each room in the game.
-- Aurelien Coet, 2017.

cutscenes = {
  main = {
    onEntry = {
      always = false,
      script = {
        {"movePlayer", 300, 450},
        {"addMessage", "Well, here I am.", 340, 490, 3}
      }
    }
  },

  secondary = {
    onEntry = {
      always = true,
      script = {
        {"movePlayer", 760, 650}
      }
    }
  }
}

return cutscenes
