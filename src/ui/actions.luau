local GameUIActions = {}

function GameUIActions.handle(api, event, learned, cast, set_message)
    if event.phase ~= "activate" then
        return
    end
    local prefix = "charm.cast."
    if string.sub(event.action, 1, #prefix) ~= prefix then
        return
    end

    local id = string.sub(event.action, #prefix + 1)
    if learned[id] and not cast[id] then
        cast[id] = true
        api.audio:play("spell-cast")
        set_message("You cast " .. string.upper(id) .. "! Add another charm to the burst.")
    else
        api.ui:set_checked("charm-" .. id, cast[id] == true)
    end
end
