-- Portable entry point for the first-game package.
-- The build step expands these includes into one sandboxed Luau chunk.

-- @include "ui/styles.luau"
-- @include "ui/document.luau"
-- @include "ui/actions.luau"

local FirstGame = {}

local charm_order = { "spark", "splash", "sprout" }
local charm_names = {
    spark = "Spark",
    splash = "Splash",
    sprout = "Sprout",
}
local charm_hints = {
    spark = "A tiny sunburst for bright ideas.",
    splash = "A giggle-powered wave spell.",
    sprout = "A friendly charm for growing courage.",
}

local learned = {}
local cast = {}
local completed = 0
local celebration_seconds = 0
local circle_ready_announced = false
local message = "Find the three beginner charms."
local progress_channel = "schoolyard-progress"

local function count(values)
    local total = 0
    for _, value in pairs(values) do
        if value then
            total = total + 1
        end
    end
    return total
end

local function all_learned()
    return count(learned) == #charm_order
end

local function all_cast()
    return all_learned() and count(cast) == #charm_order
end

local function progress_payload()
    local progress = {}
    for _, id in ipairs(charm_order) do
        if learned[id] then
            progress[id] = true
        end
    end
    return { learned = progress }
end

local function publish_progress(api)
    api.network:set_state(progress_channel, progress_payload())
end

local function update_hud(api)
    local state = api.interactions:get_state()
    local charms_learned = count(learned)
    local circle = state.zones["wand-circle"]
    local players = circle and circle.players or 1

    local status
    local help
    if celebration_seconds > 0 then
        status = "RAINBOW BURST!"
        help = string.format("Amazing teamwork! Next round in %.1fs.", celebration_seconds)
    elseif not all_learned() then
        status = string.format("%d/3 charms learned", charms_learned)
        help = message
    elseif not (circle and circle.inside) then
        status = "All charms learned!"
        help = "Run to the Wand Circle and get ready to cast."
    else
        status = string.format("Wand Circle • %d wizard%s", players, players == 1 and "" or "s")
        help = message
    end

    api.ui:set_text("school-status", status)
    api.ui:set_text("school-help-text", help)
    api.ui:set_text("school-kicker", string.format("SPELLBOUND SCHOOLYARD • %d BURSTS", completed))
    api.ui:set_visible("charm-dock", celebration_seconds <= 0 and circle ~= nil and circle.inside and all_learned())

    for _, id in ipairs(charm_order) do
        api.ui:set_visible("charm-" .. id, learned[id] == true and cast[id] ~= true)
        api.ui:set_checked("charm-" .. id, cast[id] == true)
    end
end

function FirstGame.on_start(api)
    api.lobby:set_status("Learn three charms and make a rainbow burst!")
    api.ui:set_document(GameUIDocument.create())
    update_hud(api)
end

function FirstGame.on_interaction(_api, event)
    if event.phase ~= "enter" or learned[event.id] or charm_names[event.id] == nil then
        return
    end
    learned[event.id] = true
    message = charm_names[event.id] .. " learned! " .. charm_hints[event.id]
    _api.audio:play("charm-learned")
    publish_progress(_api)
end

function FirstGame.on_network_message(_api, event)
    if event.type ~= "game_state" or event.channel ~= progress_channel then
        return
    end
    local payload = event.payload
    if type(payload) ~= "table" or type(payload.learned) ~= "table" then
        return
    end
    local changed = false
    for _, id in ipairs(charm_order) do
        if payload.learned[id] and not learned[id] then
            learned[id] = true
            changed = true
        end
    end
    if changed then
        message = "Your spell circle learned a new charm!"
    end
end

function FirstGame.on_ui_event(_api, event)
    GameUIActions.handle(_api, event, learned, cast, function(text)
        message = text
    end)
end

function FirstGame.on_tick(api, delta_seconds)
    if celebration_seconds > 0 then
        celebration_seconds = celebration_seconds - delta_seconds
        if celebration_seconds <= 0 then
            learned = {}
            cast = {}
            circle_ready_announced = false
            message = "A new round! Find the three beginner charms."
        end
    elseif all_cast() then
        completed = completed + 1
        celebration_seconds = 4.5
        message = "You made a rainbow burst with your friends!"
        api.audio:play("rainbow-burst")
    elseif all_learned() and not circle_ready_announced then
        local state = api.interactions:get_state()
        local circle = state.zones["wand-circle"]
        if circle and circle.inside then
            circle_ready_announced = true
            message = "Wands ready! Cast all three charms."
            api.audio:play("circle-ready")
        end
    end
    update_hud(api)
end

return FirstGame
