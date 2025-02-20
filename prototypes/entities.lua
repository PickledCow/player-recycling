
-- Invisible "car" that the player is put into 

data:extend({{
    name = "player-recycling-invisible-vehicle",
    type = "car",
    hidden = true,
    hidden_in_factoriopedia = true,
    -- Massive values to prevent moving
    braking_power = "1TW",
    energy_per_hit_point = 0,
    friction = math.huge,
    weight = math.huge,

    allow_remote_driving = false,
    consumption = "0W",
    effectivity = 0,
    energy_source = {type="void"},
    inventory_size = 0,
    rotation_speed = 0,

    collision_mask = {
        layers = {} -- Collide with nothing
    }
}})

local character_uncommon = table.deepcopy(data.raw["character"]["character"])
local character_rare = table.deepcopy(data.raw["character"]["character"])
local character_epic = table.deepcopy(data.raw["character"]["character"])
local character_legendary = table.deepcopy(data.raw["character"]["character"])

-- Most values follow roughly 1, 1.25, 1.5, 1.8, 2.5

-- Copy paste ease
-- character_uncommon
-- character_rare
-- character_epic
-- character_legendary

-- name
character_uncommon.name = "player-recycling-character-uncommon"
character_rare.name = "player-recycling-character-rare"
character_epic.name = "player-recycling-character-epic"
character_legendary.name = "player-recycling-character-legendary"

-- hide
character_uncommon.hidden = true
character_uncommon.hidden_in_factoriopedia = true
character_rare.hidden = true
character_rare.hidden_in_factoriopedia = true
character_epic.hidden = true
character_epic.hidden_in_factoriopedia = true
character_legendary.hidden = true
character_legendary.hidden_in_factoriopedia = true

-- build and reach distance (10)
character_uncommon.build_distance = 12
character_uncommon.reach_distance = 12
character_rare.build_distance = 15
character_rare.reach_distance = 15
character_epic.build_distance = 18
character_epic.reach_distance = 18
character_legendary.build_distance = 25
character_legendary.reach_distance = 25

-- healing (0.15), boosted even higher to make the bar go up faster considering boosted hp
-- 1, 1.3, 1.7, 2.2, 3
character_uncommon.healing_per_tick = 0.15 * 1.3
character_rare.healing_per_tick = 0.15 * 1.7
character_epic.healing_per_tick = 0.15 * 2.2
character_legendary.healing_per_tick = 0.15 * 3

-- inventory (80)
character_uncommon.inventory_size = 100
character_rare.inventory_size = 120
character_epic.inventory_size = 150
character_legendary.inventory_size = 200

-- loot pickup distance (2)
character_uncommon.loot_pickup_distance = 2.5
character_rare.loot_pickup_distance = 3 
character_epic.loot_pickup_distance = 3.6
character_legendary.loot_pickup_distance = 5

-- mining distance (2.7)
character_uncommon.reach_resource_distance = 3.375
character_rare.reach_resource_distance = 4
character_epic.reach_resource_distance = 5
character_legendary.reach_resource_distance = 6.5

local mining_speed_factors = { 1, 2, 3, 5, 8 }

-- mining speed (0.5), boosted for comedy since it doesn't actually matter
character_uncommon.mining_speed = 0.5 * mining_speed_factors[2]
character_rare.mining_speed = 0.5 * mining_speed_factors[3]
character_epic.mining_speed = 0.5 * mining_speed_factors[4]
character_legendary.mining_speed = 0.5 * mining_speed_factors[5]

-- mining animations (0.9 for first 3, 0.45 for 4th)
for i = 1,3,1 do
    for j = 1,3,1 do
        character_uncommon.animations[i].mining_with_tool.layers[j].animation_speed = 0.9 * mining_speed_factors[2]
        character_rare.animations[i].mining_with_tool.layers[j].animation_speed = 0.9 * mining_speed_factors[3]
        character_epic.animations[i].mining_with_tool.layers[j].animation_speed = 0.9 * mining_speed_factors[4]
        character_legendary.animations[i].mining_with_tool.layers[j].animation_speed = 0.9 * mining_speed_factors[5]
    end
end
for j = 1,3,1 do
    character_uncommon.animations[4].mining_with_tool.layers[j].animation_speed = 0.45 * mining_speed_factors[2]
    character_rare.animations[4].mining_with_tool.layers[j].animation_speed = 0.45 * mining_speed_factors[3]
    character_epic.animations[4].mining_with_tool.layers[j].animation_speed = 0.45 * mining_speed_factors[4]
    character_legendary.animations[4].mining_with_tool.layers[j].animation_speed = 0.45 * mining_speed_factors[5]
end

-- run speed (0.15), nerfed because it's actually just uncontrollable
-- 1, 1.1, 1.225, 1.375, 1.575
character_uncommon.running_speed = 0.15 * 1.1
character_rare.running_speed = 0.15 * 1.225
character_epic.running_speed = 0.15 * 1.375
character_legendary.running_speed = 0.15 * 1.575

-- flashlight size (25, 2)
character_uncommon.light[1].size = 31.25
character_uncommon.light[2].size = 2.5
character_uncommon.light[2].shift[2] = -16.25
character_rare.light[1].size = 37.5
character_rare.light[2].size = 3
character_rare.light[2].shift[2] = -19.5
character_epic.light[1].size = 45
character_epic.light[2].size = 3.6
character_epic.light[2].shift[2] = -23.4
character_legendary.light[1].size = 62.5
character_legendary.light[2].size = 5
character_legendary.light[2].shift[2] = -32.5

data:extend({character_uncommon, character_rare, character_epic, character_legendary})