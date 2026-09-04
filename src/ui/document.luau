local GameUIDocument = {}

local function shape_trigger(id, icon, visible)
    return {
        id = id,
        kind = "button",
        icon = icon,
        action = "build.shape.toggle",
        visible = visible,
        visibleIn = { "real-game" },
        layout = { region = "header", width = 56, height = 56 },
        style = GameUIStyles.control_style("#102D3AF7", "#078CF0FF"),
    }
end

local function color_trigger(id, label, background, foreground, visible)
    return {
        id = id,
        kind = "button",
        icon = "colorswap",
        action = "build.color.toggle",
        visible = visible,
        visibleIn = { "real-game" },
        layout = { region = "header", width = 56, height = 56 },
        style = GameUIStyles.control_style(background, "#078CF0FF", foreground),
    }
end

local function shape_choice(id, icon, label, checked)
    return {
        id = "build-shape-" .. id,
        kind = "button",
        icon = icon,
        text = label,
        action = "build.shape." .. id,
        checked = checked,
        layout = { width = 96, height = 88 },
        style = GameUIStyles.control_style("#183A48FF", "#078CF0FF", "#F7F8EEFF", 16),
    }
end

local function color_choice(id, background, foreground, checked)
    return {
        id = "build-color-" .. id,
        kind = "button",
        action = "build.color." .. id,
        checked = checked,
        layout = { width = 56, height = 56 },
        style = GameUIStyles.control_style(background, "#078CF0FF", foreground, 18),
    }
end

function GameUIDocument.create()
    return {
        nodes = {
            shape_trigger("build-shape-trigger-cube", "cube", true),
            shape_trigger("build-shape-trigger-beam", "beam", false),
            shape_trigger("build-shape-trigger-slab", "slab", false),

            color_trigger("build-color-trigger-coral", "coral", "#EF725FFF", "#F7F8EEFF", true),
            color_trigger("build-color-trigger-butter", "butter", "#F3CD6DFF", "#10212AFF", false),
            color_trigger("build-color-trigger-periwinkle", "periwinkle", "#91A8EEFF", "#10212AFF", false),
            color_trigger("build-color-trigger-ink", "ink", "#203B46FF", "#F7F8EEFF", false),
            color_trigger("build-color-trigger-paper", "warm white", "#F7F3E8FF", "#10212AFF", false),

            -- This transparent outside-tap target closes either selector
            -- without visually obscuring the world.
            {
                id = "build-popover-catcher",
                kind = "modal",
                action = "build.popover.close",
                blocksInput = true,
                visible = false,
                visibleIn = { "real-game" },
                layout = { width = "fill", height = "fill", ignoreSafeArea = true },
            },
            {
                id = "build-shape-popover",
                kind = "menu",
                blocksInput = true,
                visible = false,
                visibleIn = { "real-game" },
                layout = {
                    anchor = "topLeft",
                    width = 336,
                    height = 136,
                    offset = { 316, 88 },
                    padding = 12,
                    direction = "column",
                    align = "stretch",
                    gap = 8,
                },
                style = GameUIStyles.popover_style(),
                children = {
                    {
                        id = "build-shape-title",
                        kind = "text",
                        text = "CHOOSE A SHAPE",
                        layout = { width = "fill", height = 20 },
                        style = { fontSize = 15, foreground = "#F7F8EEFF" },
                    },
                    {
                        id = "build-shape-options",
                        kind = "stack",
                        layout = { width = "fill", height = 88, direction = "row", align = "center", gap = 10 },
                        children = {
                            shape_choice("cube", "cube", "CUBE", true),
                            shape_choice("beam", "beam", "BEAM", false),
                            shape_choice("slab", "slab", "SLAB", false),
                        },
                    },
                },
            },
            {
                id = "build-color-popover",
                kind = "menu",
                blocksInput = true,
                visible = false,
                visibleIn = { "real-game" },
                layout = {
                    anchor = "topLeft",
                    width = 336,
                    height = 108,
                    offset = { 380, 88 },
                    padding = 12,
                    direction = "column",
                    align = "stretch",
                    gap = 8,
                },
                style = GameUIStyles.popover_style(),
                children = {
                    {
                        id = "build-color-title",
                        kind = "text",
                        text = "CHOOSE A COLOR",
                        layout = { width = "fill", height = 20 },
                        style = { fontSize = 15, foreground = "#F7F8EEFF" },
                    },
                    {
                        id = "build-color-options",
                        kind = "stack",
                        layout = { width = "fill", height = 56, direction = "row", align = "center", gap = 7 },
                        children = {
                            color_choice("coral", "#EF725FFF", "#F7F8EEFF", true),
                            color_choice("butter", "#F3CD6DFF", "#10212AFF", false),
                            color_choice("periwinkle", "#91A8EEFF", "#10212AFF", false),
                            color_choice("ink", "#203B46FF", "#F7F8EEFF", false),
                            color_choice("paper", "#F7F3E8FF", "#10212AFF", false),
                        },
                    },
                },
            },

            {
                id = "build-context",
                kind = "panel",
                visibleIn = { "real-game" },
                layout = {
                    region = "bottomCenter",
                    width = "auto",
                    height = 68,
                    padding = 5,
                    direction = "row",
                    align = "center",
                    gap = 8,
                },
                style = {
                    background = "#091A22E8",
                    borderColor = "#EAF7F266",
                    borderWidth = 2,
                    cornerRadius = 24,
                },
                children = {
                    {
                        id = "build-place",
                        kind = "button",
                        icon = "place",
                        action = "build.place",
                        layout = { width = 58, height = 58 },
                        style = GameUIStyles.control_style("#078CF0FF", "#078CF0FF", "#FFFFFFFF", 18),
                    },
                    {
                        id = "build-rotate",
                        kind = "button",
                        icon = "rotate",
                        action = "build.rotate",
                        layout = { width = 58, height = 58 },
                        style = GameUIStyles.control_style("#274552FF", "#078CF0FF", "#F7F8EEFF", 18),
                    },
                    {
                        id = "build-remove",
                        kind = "button",
                        icon = "trash",
                        action = "build.remove",
                        layout = { width = 58, height = 58 },
                        style = GameUIStyles.control_style("#D9564CFF", "#EF6657FF", "#FFFFFFFF", 18),
                    },
                },
            },
            {
                id = "player-joystick",
                kind = "joystick",
                action = "player.move",
                layout = { anchor = "bottomLeft", width = 120, height = 120, offset = { 20, -24 } },
                style = {
                    background = "#091A22C9",
                    borderColor = "#D6E8E455",
                    borderWidth = 2,
                    cornerRadius = 60,
                    accent = "#EDF0E5FF",
                },
            },
            {
                id = "player-jump",
                kind = "button",
                text = "JUMP",
                action = "player.jump",
                layout = { anchor = "bottomRight", width = 86, height = 44, offset = { -22, -84 } },
                style = GameUIStyles.control_style("#102D3AE8", "#078CF0FF", "#F7F8EEFF", 14),
            },
            {
                id = "player-run",
                kind = "button",
                text = "RUN",
                action = "player.run",
                layout = { anchor = "bottomRight", width = 86, height = 44, offset = { -22, -30 } },
                style = GameUIStyles.control_style("#102D3AE8", "#078CF0FF", "#F7F8EEFF", 14),
            },
        },
    }
end
