local GameUIActions = {}

function GameUIActions.handle(api, event, round)
    if event.phase ~= "activate" then
        return
    end
    local prefix = "charm.cast."
    if string.sub(event.action, 1, #prefix) ~= prefix then
        return
    end

    local id = string.sub(event.action, #prefix + 1)
    if round.learned[id] and not round.cast[id] then
        round:request_cast(api, id)
        api.ui:set_checked("charm-" .. id, false)
    else
        api.ui:set_checked("charm-" .. id, round.cast[id] == true)
    end
end
