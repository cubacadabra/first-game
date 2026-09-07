local SpellboundRound = {}
SpellboundRound.__index = SpellboundRound

local STATE_CHANNEL = "schoolyard-round"
local CELEBRATION_SECONDS = 4.5
local BURST_POSITION = { 0, 0, 0 }

local function copy_flags(source, ids, allowed)
    local result = {}
    if type(source) ~= "table" then
        return result
    end
    for _, id in ipairs(ids) do
        if source[id] == true and (allowed == nil or allowed[id]) then
            result[id] = true
        end
    end
    return result
end

local function all_flags(values, ids)
    for _, id in ipairs(ids) do
        if not values[id] then
            return false
        end
    end
    return true
end

local function initial_state(round, bursts)
    return {
        version = 1,
        round = round or 1,
        phase = "collecting",
        learned = {},
        cast = {},
        bursts = bursts or 0,
        lastAction = { type = "round_reset", round = round or 1 },
    }
end

local function validator_for(charm_order)
    return function(payload)
        if type(payload) ~= "table"
            or payload.version ~= 1
            or type(payload.round) ~= "number"
            or payload.round < 1
            or (payload.phase ~= "collecting"
                and payload.phase ~= "casting"
                and payload.phase ~= "celebrating")
        then
            return nil
        end

        local learned = copy_flags(payload.learned, charm_order)
        local cast = copy_flags(payload.cast, charm_order, learned)
        if payload.phase ~= "collecting" and not all_flags(learned, charm_order) then
            return nil
        end
        if payload.phase == "celebrating" and not all_flags(cast, charm_order) then
            return nil
        end
        return {
            version = 1,
            round = payload.round,
            phase = payload.phase,
            learned = learned,
            cast = cast,
            bursts = type(payload.bursts) == "number" and math.max(0, payload.bursts) or 0,
            lastAction = type(payload.lastAction) == "table" and payload.lastAction or {},
        }
    end
end

local function reducer_for(charm_order)
    return function(state, intent)
        if intent.type == "learn"
            and state.phase == "collecting"
            and not state.learned[intent.charm]
        then
            local learned = copy_flags(state.learned, charm_order)
            learned[intent.charm] = true
            return {
                version = 1,
                round = state.round,
                phase = all_flags(learned, charm_order) and "casting" or "collecting",
                learned = learned,
                cast = copy_flags(state.cast, charm_order, learned),
                bursts = state.bursts,
                lastAction = { type = "learn", charm = intent.charm },
            }
        end

        if intent.type == "cast"
            and state.phase == "casting"
            and state.learned[intent.charm]
            and not state.cast[intent.charm]
        then
            local cast = copy_flags(state.cast, charm_order, state.learned)
            cast[intent.charm] = true
            local celebrating = all_flags(cast, charm_order)
            return {
                version = 1,
                round = state.round,
                phase = celebrating and "celebrating" or "casting",
                learned = copy_flags(state.learned, charm_order),
                cast = cast,
                bursts = state.bursts + (celebrating and 1 or 0),
                lastAction = { type = "cast", charm = intent.charm },
            }
        end

        if intent.type == "reset"
            and state.phase == "celebrating"
            and intent.round == state.round
        then
            return initial_state(state.round + 1, state.bursts)
        end
        return nil
    end
end

function SpellboundRound.create(charm_order)
    local round = setmetatable({
        charmOrder = charm_order,
        round = 1,
        phase = "collecting",
        learned = {},
        cast = {},
        bursts = 0,
        celebrationSeconds = 0,
        circleReadyAnnounced = false,
        message = "Find the three beginner charms.",
        resetQueued = false,
    }, SpellboundRound)

    round.shared = CubaSharedState.create({
        channel = STATE_CHANNEL,
        initial = function()
            return initial_state()
        end,
        validate = validator_for(charm_order),
        reduce = reducer_for(charm_order),
        onChange = function(api, state, previous, event)
            round:on_change(api, state, previous, event)
        end,
    })
    return round
end

function SpellboundRound:count(values)
    local total = 0
    for _, id in ipairs(self.charmOrder) do
        if values[id] then
            total = total + 1
        end
    end
    return total
end

function SpellboundRound:all_learned()
    return all_flags(self.learned, self.charmOrder)
end

function SpellboundRound:all_cast()
    return all_flags(self.cast, self.charmOrder)
end

function SpellboundRound:sync_state(state)
    self.round = state.round
    self.phase = state.phase
    self.learned = state.learned
    self.cast = state.cast
    self.bursts = state.bursts
end

function SpellboundRound:on_change(api, state, previous, _event)
    if previous ~= nil then
        for _, id in ipairs(self.charmOrder) do
            if state.learned[id] and not previous.learned[id] then
                api.audio:play("charm-learned")
            end
            if state.cast[id] and not previous.cast[id] then
                api.audio:play("spell-cast")
            end
        end
        if state.phase == "celebrating" and previous.phase ~= "celebrating" then
            api.audio:play("rainbow-burst")
            api.effects:play("rainbow-burst", { position = BURST_POSITION })
        end
    end

    self:sync_state(state)
    for _, id in ipairs(self.charmOrder) do
        api.effects:set_state(id, self.learned[id] and "collected" or "available")
    end
    api.effects:set_state("wand-circle", self.phase)

    if previous ~= nil and state.round ~= previous.round then
        self.resetQueued = false
        self.circleReadyAnnounced = false
        self.message = "A new round! Find the three beginner charms."
    elseif self.phase == "celebrating" then
        self.message = "You made a rainbow burst with your friends!"
    elseif state.lastAction.type == "learn" then
        self.message = string.upper(state.lastAction.charm or "CHARM")
            .. " learned by your spell circle!"
    elseif state.lastAction.type == "cast" then
        self.message = string.upper(state.lastAction.charm or "CHARM")
            .. " joined the shared burst!"
    elseif self.phase == "casting" and (previous == nil or previous.phase ~= "casting") then
        self.message = "All charms learned! Meet in the Wand Circle."
    end
    self.celebrationSeconds = self.phase == "celebrating"
        and math.max(0, CELEBRATION_SECONDS - self.shared.ageSeconds)
        or 0
end

function SpellboundRound:initialize(api)
    self.shared:start(api)
end

function SpellboundRound:request_learn(api, charm)
    if self.phase ~= "collecting" or self.learned[charm] then
        return
    end
    self.message = "Learning " .. string.upper(charm) .. "..."
    self.shared:dispatch(api, { type = "learn", charm = charm })
end

function SpellboundRound:request_cast(api, charm)
    if self.phase ~= "casting" or not self.learned[charm] or self.cast[charm] then
        return
    end
    self.message = "Casting " .. string.upper(charm) .. "..."
    self.shared:dispatch(api, { type = "cast", charm = charm })
end

function SpellboundRound:apply_snapshot(api, event)
    self.shared:receive(api, event)
end

function SpellboundRound:tick(api, delta_seconds)
    self.shared:update(api, delta_seconds)
    self.celebrationSeconds = self.phase == "celebrating"
        and math.max(0, CELEBRATION_SECONDS - self.shared.ageSeconds)
        or 0
    if self.phase == "celebrating"
        and self.celebrationSeconds <= 0
        and not self.resetQueued
    then
        self.resetQueued = true
        self.shared:dispatch(api, { type = "reset", round = self.round })
    end
end
