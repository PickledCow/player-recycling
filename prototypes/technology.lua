local player_recycling_productivity = {
    effects = {
      {
        change = 0.1,
        recipe = "character-recycling",
        type = "change-recipe-productivity"
      }
    },
    icon_size = 256,
    icons = {
      {
        icon = "__player-recycling__/graphics/technology.png",
        icon_size = 256
      },
      {
        icon = "__core__/graphics/icons/technology/constants/constant-recipe-productivity.png",
        icon_size = 128,
        scale = 0.5,
        shift = {
          50,
          50
        }
      }
    },
    max_level = "infinite",
    name = "character-recycling-productivity",
    prerequisites = {
        "scrap-recycling-productivity",
        "health"
    },
    type = "technology",
    unit = {
      count_formula = "1.5^L*500",
      ingredients = {
        {
          "automation-science-pack",
          1
        },
        {
          "logistic-science-pack",
          1
        },
        {
          "military-science-pack",
          1
        },
        {
          "chemical-science-pack",
          1
        },
        {
          "production-science-pack",
          1
        },
        {
          "utility-science-pack",
          1
        },
        {
          "agricultural-science-pack",
          1
        },
        {
          "electromagnetic-science-pack",
          1
        }
      },
      time = 60
    },
    upgrade = true
}

local player_recycling_quality = {
    effects = {
      {
        change = 0.01,
        recipe = "character-recycling-quality",
        type = "change-recipe-productivity",
        use_icon_overlay_constant = false,
        icons = {
            {
                icon = "__quality__/graphics/icons/recycling.png"
            },
            {
                icon = "__core__/graphics/icons/entity/character.png",
                scale = 0.4
            },
            {
                icon = "__quality__/graphics/icons/recycling-top.png"
            },
            {
                icon = "__core__/graphics/icons/any-quality.png",
                icon_size = 64,
                scale = 0.25,
                shift = {8,8}
            }
          }
      }
    },
    icon_size = 256,
    icons = {
      {
        icon = "__player-recycling__/graphics/technology.png",
        icon_size = 256
      },
      {
        icon = "__core__/graphics/icons/any-quality.png",
        icon_size = 64,
        scale = 0.33,
        shift = {
          50,
          50
        }
      }
    },
    max_level = "infinite",
    name = "character-recycling-quality",
    prerequisites = {
        "scrap-recycling-productivity",
        "health",
        "epic-quality"
    },
    type = "technology",
    unit = {
      count_formula = "1.5^L*500",
      ingredients = {
        {
          "automation-science-pack",
          1
        },
        {
          "logistic-science-pack",
          1
        },
        {
          "military-science-pack",
          1
        },
        {
          "chemical-science-pack",
          1
        },
        {
          "production-science-pack",
          1
        },
        {
          "utility-science-pack",
          1
        },
        {
          "agricultural-science-pack",
          1
        },
        {
          "electromagnetic-science-pack",
          1
        }
      },
      time = 60
    },
    upgrade = true
}

-- Add a first stage to the infinite research
local scrap_recycling_productivity_1 = table.deepcopy(data.raw["technology"]["scrap-recycling-productivity"])
local scrap_recycling_productivity_infinite = table.deepcopy(data.raw["technology"]["scrap-recycling-productivity"])
data.raw["technology"]["scrap-recycling-productivity"] = nil
scrap_recycling_productivity_1.max_level = 1
scrap_recycling_productivity_infinite.name = "scrap-recycling-productivity-2"
scrap_recycling_productivity_infinite.prerequisites = {"scrap-recycling-productivity"}

local health_1 = table.deepcopy(data.raw["technology"]["health"])
local health_infinite = table.deepcopy(data.raw["technology"]["health"])
data.raw["technology"]["health"] = nil
health_1.max_level = 1
health_infinite.name = "health-2"
health_infinite.prerequisites = {"health"}

data:extend({
    player_recycling_productivity,
    player_recycling_quality,
    scrap_recycling_productivity_1,
    scrap_recycling_productivity_infinite,
    health_1,
    health_infinite
})