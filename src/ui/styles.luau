local GameUIStyles = {}

GameUIStyles.colors = {
    ink = "#091A22F5",
    inkRaised = "#102D3AF7",
    keyline = "#EAF7F2A8",
    paper = "#F7F8EEFF",
    blue = "#078CF0FF",
    coral = "#EF6657FF",
}

function GameUIStyles.control_style(background, accent, foreground, radius)
    return {
        background = background,
        borderColor = "#031017B8",
        borderWidth = 3,
        cornerRadius = radius or 17,
        foreground = foreground or GameUIStyles.colors.paper,
        accent = accent or GameUIStyles.colors.blue,
        textAlign = "center",
        fontSize = 14,
    }
end

function GameUIStyles.popover_style()
    return {
        background = GameUIStyles.colors.inkRaised,
        borderColor = GameUIStyles.colors.keyline,
        borderWidth = 2,
        cornerRadius = 20,
        foreground = GameUIStyles.colors.paper,
    }
end
