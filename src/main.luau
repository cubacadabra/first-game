-- Portable entry point for the first-game package.
--
-- The build step expands these includes into one sandboxed Luau chunk for the
-- shared Rust runtime. Keeping the includes explicit makes load order visible
-- without requiring a runtime filesystem or module loader.

-- @include "ui/styles.luau"
-- @include "ui/document.luau"
-- @include "ui/actions.luau"

local FirstGame = {}

function FirstGame.on_start(api)
    api.lobby:set_status("Step onto BUILD TOGETHER to start a shared build")
    api.ui.selected_shape = "CUBE"
    api.ui.selected_color = "CORAL"
    api.ui.menu_open = false
    api.ui:set_document(GameUIDocument.create())
end

function FirstGame.on_ui_event(api, event)
    GameUIActions.handle(api, event)
end

function FirstGame.on_tick(_api, _delta_seconds)
    -- Game-specific rules belong here as the first game grows.
    -- Movement, collision, launch-pad timing, and multiplayer build state
    -- remain platform services.
end

return FirstGame
