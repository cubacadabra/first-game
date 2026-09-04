local GameUIStyles = {}

function GameUIStyles.control_style(background, accent)
    return {
        background = background,
        borderColor = "#D6E8E455",
        borderWidth = 1,
        cornerRadius = 16,
        foreground = "#EDF0E5FF",
        accent = accent or "#36A9FFFF",
    }
end
