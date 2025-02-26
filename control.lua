---@diagnostic disable: missing-fields

-- Mod control constants
local max_players = settings.startup["player-recycling-max-players"].value
local qualities = { "normal", "uncommon", "rare", "epic", "legendary" }
local quality_index = { normal=1, uncommon=2, rare=3, epic=4, legendary=5 }

local craft_speeds = { normal=1, uncommon=1.25, rare=1.5, epic=1.8, legendary=2.5 }

-- Holds onto player character while the recycler is running
local player_statis = {}
local player_drop_point = {}
local culprit_recycler = {}
local player_result_quality = {}

-- Interaction with the UI
script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "kill_switch" then --If they interacted with our button
        local player = game.players[event.player_index]
        local recycler = player.opened
        if recycler == nil then return end
        local character = player.character
        if character == nil then return end

        -- Check is not ghost
        if recycler.name == "entity-ghost" then return end
        -- Check recycler is not crafting
        if recycler.is_crafting() then
            player.create_local_flying_text({
                text={"item-limitation.player-recycling-recycler-busy"},
                create_at_cursor = true
            })
            return
        end
        -- Check recycler is empty
        if recycler.get_output_inventory().is_empty() == false then
            player.create_local_flying_text({
                text={"item-limitation.player-recycling-recycler-full"},
                create_at_cursor = true
            })
            return
        end
        -- Check recycler output is clear
        local scan_area = {
            {recycler.drop_position.x - 0.5, recycler.drop_position.y - 0.5},
            {recycler.drop_position.x + 0.5, recycler.drop_position.y + 0.5}
        }
        if recycler.surface.count_entities_filtered{area = scan_area, name = "item-on-ground"} > 0 then
            player.create_local_flying_text({
                text={"item-limitation.player-recycling-recycler-blocked"},
                create_at_cursor = true
            })
            return
        end
        -- Check distance from recycler
        local x = (character.position.x - recycler.position.x)
        local y = (character.position.y - recycler.position.y)
        if x*x + y*y > 8*8 then
            player.create_local_flying_text({
                text={"item-limitation.player-recycling-too-far"},
                create_at_cursor = true
            })
            return
        end
        -- Check player not crafting
        if player.crafting_queue_size > 0 then
            player.create_local_flying_text({
                text={"item-limitation.player-recycling-player-crafting"},
                create_at_cursor = true
            })        
            return
        end

        -- Calculate output quality
        local current_quality = character.quality.name
        local highest_quality = "normal"
        for i = 2,5,1 do
            if player.force.is_quality_unlocked(qualities[i]) then
                highest_quality = qualities[i]
            else
                break
            end
        end
        local quality_factor = player.force.recipes["character-recycling-quality"].productivity_bonus
        if recycler.effects.quality ~= nil then
            quality_factor = quality_factor + recycler.effects.quality * 0.1
        end
        if quality_factor > 1.0 then
            quality_factor = 1.0
        end

        -- Count down from the highest quality to see if we were successful
        local quality = current_quality
        local cumulative_chance = 1.0 -- Janky way to properly replicate in-game quality
        for i = quality_index[highest_quality] , quality_index[current_quality] + 1 , -1 do
            local threshold = quality_factor^(i - quality_index[current_quality])
            local quality_number = math.random() * cumulative_chance
            if quality_number < threshold then
                quality = qualities[i]
                break
            end
            cumulative_chance = cumulative_chance * (1 - threshold)
        end

        -- Add a player item with the right ID into the machine if possible.
        local character_item = { name="player-recycling-character-"..tostring(event.player_index), count=1, quality=current_quality }
        if recycler.can_insert(character_item) then -- One last check we can insert to not crash the game
            recycler.insert(character_item)

            player.opened = nil

            -- Create a car to hide the player in
            local car = player.character.surface.create_entity({
                name = "player-recycling-invisible-vehicle",
                position = recycler.position,
                force = "player"
            })
            if car == nil then return end
            car.set_driver(player.character)
            
            -- Hide old player body during cutscene
            player.character.destructible = false
            
            -- decouple player from their character
            -- uses string key to not have issues with indexing
            player_statis[tostring(event.player_index)] = player.character
            player_drop_point[tostring(event.player_index)] = recycler.drop_position
            culprit_recycler[tostring(event.player_index)] = recycler
            player_result_quality[tostring(event.player_index)] = quality
            player.character = nil
            player.set_controller({
                type = defines.controllers.cutscene,
                start_position = recycler.position,
                start_zoom = 2,
                waypoints = {{  position = recycler.position, transition_time = 1000000, time_to_wait = 1000000 }}
            })
        end
    end
end)

-- Actual UI
function player_recycle_ui(player, entity, element)
	if player.gui.relative.player_recycling_ui_main_frame ~= nil then return end-- If the UI already exists then return cause we don't want multiple.
    -- Recyclers are furnaces technically
    local anchor = { gui=defines.relative_gui_type.furnace_gui, position=defines.relative_gui_position.right }
	local frame = player.gui.relative.add({ type="frame", name="player_recycling_ui_main_frame", direction="vertical", anchor=anchor}) --add a frame (.relative) because it's anchored to something else
    -- Add titlebar
    local titlebar_flow = frame.add({ type="flow", name="titlebar_flow", direction="horizontal", style="frame_header_flow" })
    titlebar_flow.add({ type="label", name="title", caption="Recycle player", style="frame_title"})
    -- Add box contents
    local inset = frame.add({ type="frame", name="inset", style="inside_shallow_frame_with_padding" })
    local table = inset.add({ type="table", column_count=1 })
    table.add({ type="label", name="kill_switch_heading", caption="Recycle player", style="caption_label"}) -- Button name="" corresponds to our method that detects if the button was pressed.
    table.add({ type="button", tooltip="Recycle player", name="kill_switch", style="button", caption = "[entity=character] Recycle player"}) -- Button name="" corresponds to our method that detects if the button was pressed.
    table.add({ type="line", style="line"})
    table.add({ type="label", name="stats", caption="Stats", style="caption_label"}) -- Button name="" corresponds to our method that detects if the button was pressed.

    local quality_factor = player.force.recipes["character-recycling-quality"].productivity_bonus
    if entity.effects.quality ~= nil then
        quality_factor = quality_factor + entity.effects.quality * 0.1
    end

    local prod_percent = math.min(300, player.force.recipes["character-recycling"].productivity_bonus * 100)
    local qual_percent = math.min(100, quality_factor * 100)
    --
    local prod_text = string.format("%.1f", prod_percent).."%"
    local qual_text = string.format("%.1f", qual_percent).."%"
    if prod_percent >= 300 then
        prod_text = prod_text.." (limit)"
    end
    if qual_percent >= 100 then
        qual_text = qual_text.." (limit)"
    end

    local prod_flow = table.add({ type="flow", direction="horizontal", name="prod_flow", style="player_input_horizontal_flow" })
    prod_flow.add({ type="label", name="prod", caption="Productivity:", style="label"}) -- Button name="" corresponds to our method that detects if the button was pressed.
    prod_flow.add({ type="label", name="prod_value", caption=prod_text, style="label"}) -- Button name="" corresponds to our method that detects if the button was pressed.
    local qual_flow = table.add({ type="flow", direction="horizontal", name="qual_flow", style="player_input_horizontal_flow" })
    qual_flow.add({ type="label", name="qual", caption="Quality:", style="label"}) -- Button name="" corresponds to our method that detects if the button was pressed.
    qual_flow.add({ type="label", name="qual_value", caption=qual_text, style="label"}) -- Button name="" corresponds to our method that detects if the button was pressed.

end

-- Destroying the UI
function player_recycle_ui_hide(player)
if player == nil then return end
    if not player.gui.relative.player_recycling_ui_main_frame then return end

    player.gui.relative.player_recycling_ui_main_frame.destroy() --Removes the UI
end

function recycle_player(i, kill_player)

    local player = game.players[i]
    local character = player_statis[tostring(i)]
    local quality = player_result_quality[tostring(i)]

    assert(character ~= nil, "Character is nil.")

    -- Destroy the car the old character is riding
    if character.vehicle ~= nil then
        character.vehicle.destroy()
    end

    -- Create the new character entity
    local characte_name = "character"
    if quality ~= "normal" then
        characte_name = "player-recycling-character-"..quality
    end
    --- Change back the player's camera out of cutscene mode
    player.set_controller({
        type = defines.controllers.character,
        character = character
    })
    --- Remove and replace the old character
    player.character = nil
    player.create_character({name=characte_name, quality=quality})
    --- Move the player to the output slot of the recycler
    player.character.teleport(player_drop_point[tostring(i)])

    -- Draw quality sprite for the player if they haven't opt-ed out of it
    if quality ~= "normal" and settings.get_player_settings(i)["player-recycling-show-quality-icon"].value then
        rendering.draw_sprite({
            sprite = "quality/"..quality,
            target = { entity=player.character, offset = {-0.25, 0.0625} },
            surface = player.character.surface,
            players = {player},
            x_scale = 0.25,
            y_scale = 0.25,
            only_in_alt_mode = true,
        })
    end

    -- Copy inventory over from the old player
    player.character.get_inventory(defines.inventory.character_armor)[1].set_stack(character.get_inventory(defines.inventory.character_armor)[1])
    for _, inventory_index in ipairs({
        defines.inventory.character_guns,
        defines.inventory.character_ammo,
        defines.inventory.character_main,
        defines.inventory.character_trash
        }) do
        local old_inventory = character.get_inventory(inventory_index)
        local new_inventory = player.character.get_inventory(inventory_index)
        if old_inventory == nil then break end
        if new_inventory == nil then break end


        for slot = 1, #old_inventory do
            if old_inventory[slot].valid_for_read then
                assert(old_inventory[slot].swap_stack(new_inventory[slot]), _ .. "-" .. slot)
            end
        end
        old_inventory.clear()
        end

    if character.valid then 
        character.get_inventory(defines.inventory.character_armor)[1].clear()
    end
    --- This should never happen but just in case 
    if character.valid then 
        character.mine()
    end

    -- Apply bonuses that the prototype doesn't offer
    player.character_crafting_speed_modifier = craft_speeds[quality]

    -- Determine survival chance
    local rand1 = math.random()
    local survival = 0.25 * (1 + player.force.recipes["character-recycling"].productivity_bonus)
    --- Kill the player if they fail this
    if rand1 > survival or kill_player then
        if culprit_recycler[tostring(i)] == nil then
            player.character.die()
        else
            player.character.die(
                player.force,
                culprit_recycler[tostring(i)]
            )
        end
    else
        game.print(player.name.." has survived being recycled and is now "..(quality:gsub("^%l", string.upper)).."!")
    end

    -- Clear data storage
    player_statis[tostring(i)] = nil
    culprit_recycler[tostring(i)] = nil
    player_drop_point[tostring(i)] = nil
    player_result_quality[tostring(i)] = nil
end


-- Trigger for handling the recycling outcome of the player
function recycling_trigger(event)
    -- Go through each possible player
    for i = 1,max_players,1 do
        if event.effect_id == "player-recycling-event-"..tostring(i) then
            recycle_player(i, false)
            return
        end
    end
end

-------------------------------------------------------------------------------
-- Event triggers
-------------------------------------------------------------------------------

-- Instantly kills the player if the recycler the player is in is destroyed to
-- prevent the player being trapped in purgatory.
script.on_event(defines.events.on_entity_died,function(event)
    if event.entity == nil then return end
    if event.entity.prototype.name == "recycler" then
        for i=1,max_players,1 do
            if culprit_recycler[tostring(i)] == event.entity then
                recycle_player(i, true)
                return
            end
        end

    end
end)

script.on_event(defines.events.on_gui_closed,function(event)
    if event.entity == nil then return end
    if event.entity.prototype.name == "recycler" then
        local player = game.players[event.player_index]
        player_recycle_ui_hide(player)
    end
end)

script.on_event(defines.events.on_gui_opened,function(event)
    if event.entity == nil then return end
    if event.entity.prototype.name == "recycler" then
        local player = game.players[event.player_index]

        player_recycle_ui(player, event.entity, event.element)
    end

end)
script.on_event(defines.events.on_script_trigger_effect, recycling_trigger)
--