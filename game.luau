-- The portable rules for Cubacadabra's first game.
--
-- Build controls use two compact surfaces: the header button opens a transient
-- block picker, while the bottom-center strip keeps only the three actions that
-- are useful during placement. This keeps the world visible and leaves both
-- hands free for movement and camera input on a phone or tablet.

local FirstGame = {}

local function control_style(background, accent)
    return {
        background = background,
        borderColor = "#D6E8E455",
        borderWidth = 1,
        cornerRadius = 16,
        foreground = "#EDF0E5FF",
        accent = accent or "#36A9FFFF",
    }
end

function FirstGame.on_start(api)
    api.lobby:set_status("Step onto BUILD TOGETHER to start a shared build")
    api.ui.selected_shape = "CUBE"
    api.ui.selected_color = "CORAL"
    api.ui.menu_open = false
    api.ui:set_document({
        nodes = {
            -- A game-owned icon is appended after the four shared header icons.
            {
                id = "build-menu-button",
                kind = "button",
                icon = "build",
                action = "build.menu",
                layout = {
                    region = "header",
                    width = 56,
                    height = 56,
                },
                style = control_style("#0A86E6EE"),
            },

            -- The scrim and menu are hidden until the header action is tapped.
            -- The scrim consumes the rest of the screen so a menu tap never
            -- becomes an accidental world movement or camera gesture.
            {
                id = "build-scrim",
                kind = "modal",
                action = "build.close",
                blocksInput = true,
                visible = false,
                layout = {
                    width = "fill",
                    height = "fill",
                    ignoreSafeArea = true,
                },
                style = { background = "#071216A8" },
            },
            {
                id = "build-menu",
                kind = "menu",
                blocksInput = true,
                visible = false,
                layout = {
                    anchor = "topLeft",
                    width = 252,
                    height = 276,
                    offset = { 24, 88 },
                    padding = 12,
                    direction = "column",
                    align = "stretch",
                    gap = 6,
                },
                style = {
                    background = "#102A34FA",
                    borderColor = "#C9E0DE66",
                    borderWidth = 1,
                    cornerRadius = 18,
                },
                children = {
                    {
                        id = "build-menu-title",
                        kind = "text",
                        text = "BUILD TOGETHER",
                        layout = { width = "fill", height = 24 },
                        style = { fontSize = 13, foreground = "#EDF0E5FF" },
                    },
                    {
                        id = "build-selection",
                        kind = "text",
                        text = "CUBE  /  CORAL",
                        layout = { width = "fill", height = 18 },
                        style = { fontSize = 10, foreground = "#9EB9B5FF" },
                    },
                    {
                        id = "build-shapes",
                        kind = "stack",
                        layout = {
                            width = "fill",
                            height = 56,
                            direction = "row",
                            align = "center",
                            gap = 6,
                        },
                        children = {
                            {
                                id = "build-shape-cube",
                                kind = "button",
                                icon = "cube",
                                text = "CUBE",
                                action = "build.shape.cube",
                                layout = { width = 68, height = 56 },
                                style = control_style("#FFFFFF18"),
                            },
                            {
                                id = "build-shape-beam",
                                kind = "button",
                                icon = "beam",
                                text = "BEAM",
                                action = "build.shape.beam",
                                layout = { width = 68, height = 56 },
                                style = control_style("#FFFFFF18"),
                            },
                            {
                                id = "build-shape-slab",
                                kind = "button",
                                icon = "slab",
                                text = "SLAB",
                                action = "build.shape.slab",
                                layout = { width = 68, height = 56 },
                                style = control_style("#FFFFFF18"),
                            },
                        },
                    },
                    {
                        id = "build-color-label",
                        kind = "text",
                        text = "COLOR",
                        layout = { width = "fill", height = 18 },
                        style = { fontSize = 10, foreground = "#9EB9B5FF" },
                    },
                    {
                        id = "build-colors",
                        kind = "stack",
                        layout = {
                            width = "fill",
                            height = 44,
                            direction = "row",
                            align = "center",
                            gap = 4,
                        },
                        children = {
                            {
                                id = "build-color-coral",
                                kind = "button",
                                text = "C",
                                action = "build.color.coral",
                                layout = { width = 40, height = 44 },
                                style = { background = "#F47765FF", foreground = "#102A34FF", cornerRadius = 14, fontSize = 14, textAlign = "center" },
                            },
                            {
                                id = "build-color-butter",
                                kind = "button",
                                text = "B",
                                action = "build.color.butter",
                                layout = { width = 40, height = 44 },
                                style = { background = "#F6D67AFF", foreground = "#102A34FF", cornerRadius = 14, fontSize = 14, textAlign = "center" },
                            },
                            {
                                id = "build-color-periwinkle",
                                kind = "button",
                                text = "P",
                                action = "build.color.periwinkle",
                                layout = { width = 40, height = 44 },
                                style = { background = "#A7B8F2FF", foreground = "#102A34FF", cornerRadius = 14, fontSize = 14, textAlign = "center" },
                            },
                            {
                                id = "build-color-ink",
                                kind = "button",
                                text = "I",
                                action = "build.color.ink",
                                layout = { width = 40, height = 44 },
                                style = { background = "#20333CFF", foreground = "#EDF0E5FF", cornerRadius = 14, fontSize = 14, textAlign = "center" },
                            },
                            {
                                id = "build-color-paper",
                                kind = "button",
                                text = "W",
                                action = "build.color.paper",
                                layout = { width = 40, height = 44 },
                                style = { background = "#EDF0E5FF", foreground = "#102A34FF", cornerRadius = 14, fontSize = 14, textAlign = "center" },
                            },
                        },
                    },
                    {
                        id = "build-menu-footer",
                        kind = "stack",
                        layout = {
                            width = "fill",
                            height = 50,
                            direction = "row",
                            align = "center",
                            gap = 6,
                        },
                        children = {
                            {
                                id = "build-save",
                                kind = "button",
                                icon = "save",
                                text = "SAVE",
                                action = "build.save",
                                layout = { width = "fill", height = 50 },
                                style = control_style("#FFFFFF18"),
                            },
                            {
                                id = "build-return",
                                kind = "button",
                                icon = "close",
                                text = "EXIT",
                                action = "build.return",
                                layout = { width = "fill", height = 50 },
                                style = control_style("#FFFFFF18"),
                            },
                        },
                    },
                },
            },

            -- The only persistent bottom-center controls: place, rotate, remove.
            {
                id = "build-context",
                kind = "panel",
                layout = {
                    region = "bottomCenter",
                    width = "auto",
                    height = 56,
                    padding = 4,
                    direction = "row",
                    align = "center",
                    gap = 6,
                },
                style = {
                    background = "#102A34D9",
                    borderColor = "#C9E0DE55",
                    borderWidth = 1,
                    cornerRadius = 28,
                },
                children = {
                    {
                        id = "build-place",
                        kind = "button",
                        icon = "plus",
                        action = "build.place",
                        layout = { width = 48, height = 48 },
                        style = control_style("#0A86E6FF"),
                    },
                    {
                        id = "build-rotate",
                        kind = "button",
                        icon = "rotate",
                        action = "build.rotate",
                        layout = { width = 48, height = 48 },
                        style = control_style("#FFFFFF18"),
                    },
                    {
                        id = "build-remove",
                        kind = "button",
                        icon = "trash",
                        action = "build.remove",
                        layout = { width = 48, height = 48 },
                        style = control_style("#FFFFFF18", "#F47765FF"),
                    },
                },
            },
            {
                id = "player-joystick",
                kind = "joystick",
                action = "player.move",
                layout = {
                    anchor = "bottomLeft",
                    width = 120,
                    height = 120,
                    offset = { 20, -24 },
                },
                style = {
                    background = "#102A34C9",
                    borderColor = "#D6E8E455",
                    borderWidth = 1,
                    cornerRadius = 60,
                    accent = "#EDF0E5FF",
                },
            },
            {
                id = "player-jump",
                kind = "button",
                text = "JUMP",
                action = "player.jump",
                layout = {
                    anchor = "bottomRight",
                    width = 86,
                    height = 44,
                    offset = { -22, -84 },
                },
                style = {
                    background = "#102A34A8",
                    borderColor = "#D6E8E455",
                    borderWidth = 1,
                    cornerRadius = 14,
                    textAlign = "center",
                    fontSize = 11,
                },
            },
            {
                id = "player-run",
                kind = "button",
                text = "RUN",
                action = "player.run",
                layout = {
                    anchor = "bottomRight",
                    width = 86,
                    height = 44,
                    offset = { -22, -30 },
                },
                style = {
                    background = "#102A34A8",
                    borderColor = "#D6E8E455",
                    borderWidth = 1,
                    cornerRadius = 14,
                    textAlign = "center",
                    fontSize = 11,
                },
            },
        },
    })
end

function FirstGame.on_ui_event(api, event)
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

    if event.action == "build.menu" then
        api.ui.menu_open = not api.ui.menu_open
        api.ui:set_visible("build-scrim", api.ui.menu_open)
        api.ui:set_visible("build-menu", api.ui.menu_open)
        api.ui:set_visible("build-context", not api.ui.menu_open)
    elseif event.action == "build.close" then
        api.ui.menu_open = false
        api.ui:set_visible("build-scrim", false)
        api.ui:set_visible("build-menu", false)
        api.ui:set_visible("build-context", true)
    elseif shapes[event.action] then
        api.ui.menu_open = false
        api.ui.selected_shape = shapes[event.action]
        api.ui:set_text("build-selection", api.ui.selected_shape .. "  /  " .. api.ui.selected_color)
        api.ui:set_visible("build-scrim", false)
        api.ui:set_visible("build-menu", false)
        api.ui:set_visible("build-context", true)
    elseif colors[event.action] then
        api.ui.menu_open = false
        api.ui.selected_color = colors[event.action]
        api.ui:set_text("build-selection", api.ui.selected_shape .. "  /  " .. api.ui.selected_color)
        api.ui:set_visible("build-scrim", false)
        api.ui:set_visible("build-menu", false)
        api.ui:set_visible("build-context", true)
    elseif event.action == "build.save" or event.action == "build.return" then
        api.ui.menu_open = false
        api.ui:set_visible("build-scrim", false)
        api.ui:set_visible("build-menu", false)
        api.ui:set_visible("build-context", true)
    end
end

function FirstGame.on_tick(api, _delta_seconds)
    -- Game-specific rules belong here as the first game grows.
    -- Movement, collision, launch-pad timing, and multiplayer build state
    -- remain platform services.
end

return FirstGame
