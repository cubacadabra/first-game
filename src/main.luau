-- Portable entry point for the first-game package.
-- The build step expands these includes into one sandboxed Luau chunk.

-- @include "@cubacadabra/shared-state-v1.luau"
-- @include "round.luau"
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

local round = SpellboundRound.create(charm_order)

local function update_hud(api)
    local state = api.interactions:get_state()
    local charms_learned = round:count(round.learned)
    local circle = state.zones["wand-circle"]
    local players = circle and circle.players or 1

    local status
    local help
    if round.phase == "celebrating" then
        status = "RAINBOW BURST!"
        help = string.format("Amazing teamwork! Next round in %.1fs.", round.celebrationSeconds)
    elseif round.phase == "collecting" then
        status = string.format("%d/3 charms learned", charms_learned)
        help = round.message
    elseif not (circle and circle.inside) then
        status = "All charms learned!"
        help = "Run to the Wand Circle and get ready to cast."
    else
        status = string.format("Wand Circle • %d wizard%s", players, players == 1 and "" or "s")
        help = round.message
    end

    api.ui:set_text("school-status", status)
    api.ui:set_text("school-help-text", help)
    api.ui:set_text("school-kicker", string.format("SPELLBOUND SCHOOLYARD • %d BURSTS", round.bursts))
    api.ui:set_visible(
        "charm-dock",
        round.phase == "casting" and circle ~= nil and circle.inside
    )

    for _, id in ipairs(charm_order) do
        api.ui:set_visible("charm-" .. id, round.learned[id] == true and round.cast[id] ~= true)
        api.ui:set_checked("charm-" .. id, round.cast[id] == true)
    end
end

function FirstGame.on_start(api)
    api.lobby:set_status("Learn three charms and make a rainbow burst!")
    api.ui:set_document(GameUIDocument.create())
    round:initialize(api)
    update_hud(api)
end

function FirstGame.on_interaction(api, event)
    if event.phase ~= "enter" or charm_names[event.id] == nil then
        return
    end
    round:request_learn(api, event.id)
end

function FirstGame.on_network_message(api, event)
    if event.type ~= "game_state" or event.channel ~= "schoolyard-round" then
        return
    end
    round:apply_snapshot(api, event)
end

function FirstGame.on_ui_event(api, event)
    GameUIActions.handle(api, event, round)
end

function FirstGame.on_tick(api, delta_seconds)
    round:tick(api, delta_seconds)

    if round.phase == "casting" and not round.circleReadyAnnounced then
        local state = api.interactions:get_state()
        local circle = state.zones["wand-circle"]
        if circle and circle.inside then
            round.circleReadyAnnounced = true
            round.message = "Wands ready! Cast the remaining charms together."
            api.audio:play("circle-ready")
        end
    end

    update_hud(api)
end

return FirstGame
