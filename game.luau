-- The portable rules for Cubacadabra's first game.
--
-- The platform host provides this small API on web, iOS, and Android. The
-- renderer never calls these rules directly; it only presents the state the
-- host produces.

local FirstGame = {}

function FirstGame.on_start(api)
    api.lobby:set_status("Step onto BUILD TOGETHER to start a shared build")
    api.ui:set_document({
        nodes = {
            {
                id = "hud-header",
                kind = "panel",
                layout = {
                    anchor = "top",
                    width = "90%",
                    maxWidth = 760,
                    height = 68,
                    padding = 10,
                    direction = "row",
                    align = "center",
                    gap = 8,
                },
                style = {
                    background = "#172F38E8",
                    borderColor = "#FFFFFF24",
                    borderWidth = 1,
                    cornerRadius = 22,
                },
                children = {
                    {
                        id = "hud-menu",
                        kind = "button",
                        text = "MENU",
                        action = "hud.menu",
                        layout = { width = 64, height = 44 },
                        style = {
                            background = "#FFFFFF1F",
                            cornerRadius = 22,
                            textAlign = "center",
                            fontSize = 10,
                        },
                    },
                    {
                        id = "hud-title",
                        kind = "text",
                        text = "THE CLEARING",
                        layout = { width = "fill", height = 44 },
                        style = { fontSize = 14, textAlign = "center" },
                    },
                    {
                        id = "hud-players",
                        kind = "text",
                        text = "1 PLAYER",
                        layout = { width = 88, height = 44 },
                        style = { fontSize = 10, textAlign = "center" },
                    },
                    {
                        id = "hud-safety",
                        kind = "button",
                        text = "PEOPLE",
                        action = "hud.safety",
                        layout = { width = 76, height = 44 },
                        style = {
                            background = "#FFFFFF1F",
                            cornerRadius = 22,
                            textAlign = "center",
                            fontSize = 9,
                        },
                    },
                },
            },
            {
                id = "build-dock",
                kind = "panel",
                layout = {
                    anchor = "bottom",
                    width = "92%",
                    maxWidth = 620,
                    height = 112,
                    offset = { 0, -16 },
                    padding = 8,
                    direction = "column",
                    align = "stretch",
                    gap = 4,
                },
                style = {
                    background = "#172F38E8",
                    borderColor = "#FFFFFF24",
                    borderWidth = 1,
                    cornerRadius = 24,
                },
                children = {
                    {
                        id = "build-tools",
                        kind = "stack",
                        layout = {
                            width = "fill",
                            height = 48,
                            direction = "row",
                            align = "center",
                            gap = 5,
                        },
                        children = {
                            {
                                id = "build-tool",
                                kind = "button",
                                text = "PLACE",
                                action = "build.tool",
                                layout = { width = 68, height = 44 },
                                style = {
                                    background = "#0094FFFF",
                                    cornerRadius = 22,
                                    textAlign = "center",
                                    fontSize = 10,
                                },
                            },
                            {
                                id = "build-shape",
                                kind = "button",
                                text = "CUBE",
                                action = "build.shape",
                                layout = { width = 72, height = 44 },
                                style = {
                                    background = "#FFFFFF1F",
                                    cornerRadius = 22,
                                    textAlign = "center",
                                    fontSize = 10,
                                },
                            },
                            {
                                id = "build-color",
                                kind = "button",
                                text = "CORAL",
                                action = "build.color",
                                layout = { width = 78, height = 44 },
                                style = {
                                    background = "#FFFFFF1F",
                                    cornerRadius = 22,
                                    textAlign = "center",
                                    fontSize = 10,
                                },
                            },
                            {
                                id = "build-use",
                                kind = "button",
                                text = "BUILD",
                                action = "build.use",
                                layout = { width = "fill", height = 44 },
                                style = {
                                    background = "#0094FFFF",
                                    cornerRadius = 22,
                                    textAlign = "center",
                                    fontSize = 10,
                                },
                            },
                        },
                    },
                    {
                        id = "build-footer",
                        kind = "stack",
                        layout = {
                            width = "fill",
                            height = 40,
                            direction = "row",
                            align = "center",
                            gap = 6,
                        },
                        children = {
                            {
                                id = "build-status",
                                kind = "text",
                                text = "BUILD TOGETHER",
                                layout = { width = "fill", height = 36 },
                                style = { fontSize = 9, textAlign = "start" },
                            },
                            {
                                id = "build-save",
                                kind = "button",
                                text = "SAVE",
                                action = "build.save",
                                layout = { width = 70, height = 36 },
                                style = {
                                    background = "#FFFFFF1F",
                                    cornerRadius = 18,
                                    textAlign = "center",
                                    fontSize = 9,
                                },
                            },
                            {
                                id = "build-return",
                                kind = "button",
                                text = "EXIT",
                                action = "build.return",
                                layout = { width = 62, height = 36 },
                                style = {
                                    background = "#FFFFFF1F",
                                    cornerRadius = 18,
                                    textAlign = "center",
                                    fontSize = 9,
                                },
                            },
                        },
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
                    background = "#172F38B8",
                    borderColor = "#FFFFFF3D",
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
                    background = "#FFFFFF33",
                    borderColor = "#FFFFFF2E",
                    borderWidth = 1,
                    cornerRadius = 22,
                    textAlign = "center",
                    fontSize = 10,
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
                    background = "#FFFFFF33",
                    borderColor = "#FFFFFF2E",
                    borderWidth = 1,
                    cornerRadius = 22,
                    textAlign = "center",
                    fontSize = 10,
                },
            },
        },
    })
end

function FirstGame.on_ui_event(api, event)
    local tools = { "PLACE", "ROTATE", "REMOVE", "RECOLOR" }
    local shapes = { "CUBE", "BEAM", "SLAB" }
    local colors = { "CORAL", "BUTTER", "PERIWINKLE", "INK", "PAPER" }

    if event.action == "build.tool" then
        local current = api.ui.tool_index or 1
        current = current % #tools + 1
        api.ui.tool_index = current
        api.ui:set_text("build-tool", tools[current])
    elseif event.action == "build.shape" then
        local current = api.ui.shape_index or 1
        current = current % #shapes + 1
        api.ui.shape_index = current
        api.ui:set_text("build-shape", shapes[current])
    elseif event.action == "build.color" then
        local current = api.ui.color_index or 1
        current = current % #colors + 1
        api.ui.color_index = current
        api.ui:set_text("build-color", colors[current])
    elseif event.action == "build.place" or event.action == "build.rotate"
        or event.action == "build.remove" or event.action == "build.recolor" then
        api.ui:set_text("build-tool", string.upper(string.sub(event.action, 7)))
    end
end

function FirstGame.on_tick(api, _delta_seconds)
    -- Game-specific rules belong here as the first game grows.
    -- Movement, collision, launch-pad timing, and manifest world routes remain
    -- platform services.
end

return FirstGame
