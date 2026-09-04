local GameUIActions = {}

local shapes = {
    ["build.shape.cube"] = "CUBE",
    ["build.shape.beam"] = "BEAM",
    ["build.shape.slab"] = "SLAB",
}

local colors = {
    ["build.color.coral"] = "CORAL",
    ["build.color.butter"] = "BUTTER",
    ["build.color.periwinkle"] = "PERIWINKLE",
    ["build.color.ink"] = "INK",
    ["build.color.paper"] = "PAPER",
}

local function close_menu(api)
    api.ui.menu_open = false
    api.ui:set_visible("build-scrim", false)
    api.ui:set_visible("build-menu", false)
    api.ui:set_visible("build-context", true)
end

function GameUIActions.handle(api, event)
    if event.action == "build.menu" then
        api.ui.menu_open = not api.ui.menu_open
        api.ui:set_visible("build-scrim", api.ui.menu_open)
        api.ui:set_visible("build-menu", api.ui.menu_open)
        api.ui:set_visible("build-context", not api.ui.menu_open)
    elseif event.action == "build.close" then
        close_menu(api)
    elseif shapes[event.action] then
        api.ui.selected_shape = shapes[event.action]
        api.ui:set_text("build-selection", api.ui.selected_shape .. "  /  " .. api.ui.selected_color)
        close_menu(api)
    elseif colors[event.action] then
        api.ui.selected_color = colors[event.action]
        api.ui:set_text("build-selection", api.ui.selected_shape .. "  /  " .. api.ui.selected_color)
        close_menu(api)
    elseif event.action == "build.save" or event.action == "build.return" then
        close_menu(api)
    end
end
