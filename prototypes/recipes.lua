local max_players = settings.startup["player-recycling-max-players"].value

-- Unhide player recycling
local fake_recycling = table.deepcopy(data.raw["recipe"]["character-recycling"])
local fake_recycling_quality = table.deepcopy(data.raw["recipe"]["character-recycling"])
data.raw["recipe"]["character-recycling"] = nil
fake_recycling_quality.name = "character-recycling-quality"
fake_recycling.hidden = false
fake_recycling_quality.hidden = true
fake_recycling.hidden_in_factoriopedia = false
fake_recycling_quality.hidden_in_factoriopedia = true
fake_recycling.show_amount_in_title = false
fake_recycling_quality.show_amount_in_title = false
fake_recycling.hide_from_signal_gui = true
fake_recycling_quality.hide_from_signal_gui = true
fake_recycling.hide_from_player_crafting = true
fake_recycling_quality.hide_from_player_crafting = true
fake_recycling.hide_from_stats = true
fake_recycling_quality.hide_from_stats = true
data:extend({fake_recycling, fake_recycling_quality})

-- Super dirty hackjob to copy paste recipes...
for i = 1,max_players,1 do
    local character_recycling = table.deepcopy(data.raw["recipe"]["player-recycling-character-"..tostring(i).."-recycling"])
    data.raw["recipe"]["player-recycling-character-"..tostring(i).."-recycling"] = nil
    character_recycling.energy_required = 2
    character_recycling.crafting_machine_tint = {
        primary = {
        0.8,
        0.2,
        0.2,
        0.75
        },
        secondary = {
        0.8,
        0.2,
        0.2,
        0.75
        },
        tertiary = {
        0.8,
        0.2,
        0.2,
        0.75
        },
        quaternary = {
        0.8,
        0.2,
        0.2,
        0.75
        },
    }

    character_recycling.results = {
        { type = "item", name = "player-recycling-spoil-trigger-item-"..tostring(i), amount = 1, probability = 1 }
    }
    character_recycling.preserve_products_in_machine_output = true

    data:extend({ character_recycling })
end
