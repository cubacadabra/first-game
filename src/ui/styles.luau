local GameUIStyles = {}

GameUIStyles.colors = {
    ink = "#101329F2",
    inkRaised = "#1A1D3BF5",
    paper = "#FFF8EFFF",
    quiet = "#C5C9E8FF",
    rainbow = "#FF8BB7FF",
    spark = "#FFB84DFF",
    splash = "#50C9E8FF",
    sprout = "#75D68AFF",
    keyline = "#F6E8C66B",
}

function GameUIStyles.panel_style(background, radius)
    return {
        background = background or GameUIStyles.colors.ink,
        borderColor = GameUIStyles.colors.keyline,
        borderWidth = 2,
        cornerRadius = radius or 18,
        foreground = GameUIStyles.colors.paper,
    }
end
function GameUIStyles.charm_style(color)
    return {
        background = GameUIStyles.colors.inkRaised,
        borderColor = color,
        borderWidth = 3,
        cornerRadius = 18,
        foreground = GameUIStyles.colors.paper,
        accent = color,
        textAlign = "center",
        fontSize = 13,
    }
end

function GameUIStyles.control_style(background, accent, foreground, radius)
    return {
        background = background or GameUIStyles.colors.inkRaised,
        borderColor = accent or GameUIStyles.colors.rainbow,
        borderWidth = 2,
        cornerRadius = radius or 17,
        foreground = foreground or GameUIStyles.colors.paper,
        accent = accent or GameUIStyles.colors.rainbow,
        textAlign = "center",
        fontSize = 14,
    }
end
