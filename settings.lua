data:extend({
    {
        type = "int-setting",
        default_value = 8,
        minimum_value = 1,
        name = "player-recycling-max-players",
        setting_type = "startup",
    },
    {
        type = "bool-setting",
        default_value = true,
        name = "player-recycling-show-quality-icon",
        setting_type = "runtime-per-user",
    }
})