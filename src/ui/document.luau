local GameUIDocument = {}

local function charm_button(id, label, color)
    return {
        id = "charm-" .. id,
        kind = "button",
        text = label,
        action = "charm.cast." .. id,
        visible = false,
        visibleIn = { "schoolyard" },
        layout = { width = 112, height = 58 },
        style = GameUIStyles.charm_style(color),
    }
end

function GameUIDocument.create()
    return {
        nodes = {
            {
                id = "school-header",
                kind = "panel",
                visibleIn = { "schoolyard" },
                layout = {
                    anchor = "top",
                    width = "90%",
                    maxWidth = 390,
                    height = 96,
                    offset = { 0, 74 },
                    padding = 10,
                    direction = "column",
                    align = "stretch",
                    gap = 3,
                },
                style = GameUIStyles.panel_style(),
                children = {
                    {
                        id = "school-kicker",
                        kind = "text",
                        text = "SPELLBOUND SCHOOLYARD",
                        layout = { width = "fill", height = 18 },
                        style = { fontSize = 12, foreground = GameUIStyles.colors.rainbow },
                    },
                    {
                        id = "school-status",
                        kind = "text",
                        text = "Find the three beginner charms.",
                        layout = { width = "fill", height = 20 },
                        style = { fontSize = 14, foreground = GameUIStyles.colors.paper },
                    },
                    {
                        id = "school-help-text",
                        kind = "text",
                        text = "Walk into a glowing spot to learn its charm.",
                        layout = { width = "fill", height = 36 },
                        style = { fontSize = 12, foreground = GameUIStyles.colors.quiet },
                    },
                },
            },
            {
                id = "charm-dock",
                kind = "panel",
                visible = false,
                visibleIn = { "schoolyard" },
                layout = {
                    anchor = "top",
                    width = "90%",
                    maxWidth = 390,
                    height = 70,
                    offset = { 0, 180 },
                    padding = 6,
                    direction = "row",
                    align = "center",
                    justify = "center",
                    gap = 7,
                },
                style = GameUIStyles.panel_style("#17304AF2", 22),
                children = {
                    charm_button("spark", "SPARK", GameUIStyles.colors.spark),
                    charm_button("splash", "SPLASH", GameUIStyles.colors.splash),
                    charm_button("sprout", "SPROUT", GameUIStyles.colors.sprout),
                },
            },
            {
                id = "player-joystick",
                kind = "joystick",
                action = "player.move",
                layout = { anchor = "bottomLeft", width = 120, height = 120, offset = { 20, -24 } },
                style = {
                    background = "#17304AC9",
                    borderColor = "#FFFDF455",
                    borderWidth = 2,
                    cornerRadius = 60,
                    accent = GameUIStyles.colors.paper,
                },
            },
            {
                id = "player-jump",
                kind = "button",
                text = "JUMP",
                action = "player.jump",
                layout = { anchor = "bottomRight", width = 86, height = 44, offset = { -22, -84 } },
                style = GameUIStyles.control_style(GameUIStyles.colors.inkRaised, GameUIStyles.colors.rainbow),
            },
            {
                id = "player-run",
                kind = "button",
                text = "RUN",
                action = "player.run",
                layout = { anchor = "bottomRight", width = 86, height = 44, offset = { -22, -30 } },
                style = GameUIStyles.control_style(GameUIStyles.colors.inkRaised, GameUIStyles.colors.rainbow),
            },
        },
    }
end
