local max_players = settings.startup["player-recycling-max-players"].value

local qualities = { "normal", "uncommon", "rare", "epic", "legendary" }


-- Fake player for displaying recycling

data:extend({
    {
        name = "character",
        type = "item",
        icon = "__core__/graphics/icons/entity/character.png",
        stack_size = 1,
        subgroup = "creatures",
        flags = {
            "not-stackable"
        },
        place_result = "character"
    }
})

-- Super dirty hackjob to copy paste items...
for i = 1,max_players,1 do
    data:extend({
        -- Player Item
        {
            name = "player-recycling-character-"..tostring(i),
            type = "item",
            icon = "__core__/graphics/icons/entity/character.png",
            stack_size = 1,
            hidden = true,
            hidden_in_factoriopedia = true,
            hide_from_signal_gui = true,
            hide_from_player_crafting = true,
            hide_from_stats = true,
            subgroup = "creatures",
            flags = {
                "not-stackable"
            },
            -- Emergency spoilage to respawn the player
            spoil_ticks = 300,
        },
        -- Recycling instant spoil item to trigger player character recycling
        {
            name = "player-recycling-spoil-trigger-item-"..tostring(i),
            type = "item",
            icons = {
                {
                    icon = "__space-age__/graphics/icons/spoilage.png"
                },
                {
                    icon = "__core__/graphics/icons/entity/character.png",
                    scale = 0.6,
                    tint = {
                        0, 0, 0, 1
                    }
                },
                {
                    icon = "__core__/graphics/icons/entity/character.png",
                    scale = 0.5
                }
            },
            stack_size = 1,
            hidden = true,
            hidden_in_factoriopedia = true,
            hide_from_signal_gui = true,
            hide_from_player_crafting = true,
            hide_from_stats = true,
            spoil_ticks = 1,
            spoil_to_trigger_result = {
                items_per_trigger = 1,
                trigger = {
                    type = "direct",
                    action_delivery = {
                        type = "instant",
                        source_effects = {
                            type = "script",
                            effect_id = "player-recycling-event-"..tostring(i)
                        }
                    }
                }
            },
            flags = {
                "ignore-spoil-time-modifier",
                "not-stackable"
            }
        }
    })
end

