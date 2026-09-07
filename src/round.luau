local SpellboundRound = {}
SpellboundRound.__index = SpellboundRound

local STATE_CHANNEL = "schoolyard-round"
local CELEBRATION_SECONDS = 4.5
local BURST_POSITION = { 0, 0, 0 }

local function copy_flags(source, ids)
    local result = {}
    if type(source) ~= "table" then
        return result
    end
    for _, id in ipairs(ids) do
        if source[id] == true or type(source[id]) == "string" then
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

local function empty_payload(round, bursts)
    return {
        version = 1,
        round = round,
        phase = "collecting",
        learned = {},
        cast = {},
        bursts = bursts,
        lastAction = { type = "round_reset", round = round },
    }
end

function SpellboundRound.create(charm_order)
    return setmetatable({
        charmOrder = charm_order,
        round = 1,
        phase = "collecting",
        learned = {},
        cast = {},
        bursts = 0,
        sequence = 0,
        celebrationSeconds = 0,
        circleReadyAnnounced = false,
        message = "Find the three beginner charms.",
        hasSnapshot = false,
        pendingLearn = {},
        pendingCast = {},
        resetPending = false,
        resetRetrySeconds = 0,
    }, SpellboundRound)
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

function SpellboundRound:has_pending_actions()
    for _, id in ipairs(self.charmOrder) do
        if self.pendingLearn[id] or self.pendingCast[id] then
            return true
        end
    end
    return false
end

function SpellboundRound:submit(api)
    if self.resetPending then
        api.network:compare_set_state(
            STATE_CHANNEL,
            self.sequence,
            empty_payload(self.round + 1, self.bursts)
        )
        self.resetRetrySeconds = 0.75
        return
    end

    local next_learned = copy_flags(self.learned, self.charmOrder)
    local next_cast = copy_flags(self.cast, self.charmOrder)
    local next_phase = self.phase
    local next_bursts = self.bursts
    local last_action = nil
    local changed = false

    if next_phase == "collecting" then
        for _, id in ipairs(self.charmOrder) do
            if self.pendingLearn[id] and not next_learned[id] then
                next_learned[id] = true
                last_action = { type = "learn", charm = id }
                changed = true
            end
        end
        if all_flags(next_learned, self.charmOrder) then
            next_phase = "casting"
        end
    end

    if next_phase == "casting" then
        for _, id in ipairs(self.charmOrder) do
            if self.pendingCast[id] and next_learned[id] and not next_cast[id] then
                next_cast[id] = true
                last_action = { type = "cast", charm = id }
                changed = true
            end
        end
        if all_flags(next_cast, self.charmOrder) then
            next_phase = "celebrating"
            next_bursts = next_bursts + 1
        end
    end

    if not changed then
        return
    end

    api.network:compare_set_state(STATE_CHANNEL, self.sequence, {
        version = 1,
        round = self.round,
        phase = next_phase,
        learned = next_learned,
        cast = next_cast,
        bursts = next_bursts,
        lastAction = last_action,
    })
end

function SpellboundRound:initialize(api)
    api.network:compare_set_state(STATE_CHANNEL, 0, empty_payload(1, 0))
end

function SpellboundRound:request_learn(api, charm)
    if self.phase ~= "collecting" or self.learned[charm] or self.pendingLearn[charm] then
        return
    end
    self.pendingLearn[charm] = true
    self.message = "Learning " .. string.upper(charm) .. "..."
    self:submit(api)
end

function SpellboundRound:request_cast(api, charm)
    if self.phase ~= "casting" or not self.learned[charm] or self.cast[charm] then
        return
    end
    self.pendingCast[charm] = true
    self.message = "Casting " .. string.upper(charm) .. "..."
    self:submit(api)
end

function SpellboundRound:apply_snapshot(api, event)
    local payload = event.payload
    local sequence = event.sequence
    if type(payload) ~= "table" or payload.version ~= 1 or type(sequence) ~= "number" then
        return
    end
    if self.hasSnapshot and sequence < self.sequence then
        return
    end
    if self.hasSnapshot and sequence == self.sequence then
        if self.resetPending or self:has_pending_actions() then
            self:submit(api)
        end
        return
    end
    if type(payload.round) ~= "number" or payload.round < 1 then
        return
    end

    local next_phase = payload.phase
    if next_phase ~= "collecting" and next_phase ~= "casting" and next_phase ~= "celebrating" then
        return
    end

    local previous_round = self.round
    local previous_phase = self.phase
    local previous_learned = self.learned
    local previous_cast = self.cast
    local next_learned = copy_flags(payload.learned, self.charmOrder)
    local next_cast = copy_flags(payload.cast, self.charmOrder)
    local next_bursts = type(payload.bursts) == "number" and math.max(0, payload.bursts) or 0

    for _, id in ipairs(self.charmOrder) do
        local animate_learn = self.hasSnapshot or self.pendingLearn[id]
        local animate_cast = self.hasSnapshot or self.pendingCast[id]
        if animate_learn and next_learned[id] and not previous_learned[id] then
            api.audio:play("charm-learned")
        end
        if animate_cast and next_cast[id] and not previous_cast[id] then
            api.audio:play("spell-cast")
        end
    end
    if self.hasSnapshot then
        if next_phase == "celebrating" and previous_phase ~= "celebrating" then
            api.audio:play("rainbow-burst")
            api.effects:play("rainbow-burst", { position = BURST_POSITION })
        end
    end

    self.round = payload.round
    self.phase = next_phase
    self.learned = next_learned
    self.cast = next_cast
    self.bursts = next_bursts
    self.sequence = sequence
    self.hasSnapshot = true

    for _, id in ipairs(self.charmOrder) do
        api.effects:set_state(id, self.learned[id] and "collected" or "available")
    end
    api.effects:set_state("wand-circle", self.phase)

    for _, id in ipairs(self.charmOrder) do
        if self.learned[id] or self.phase ~= "collecting" then
            self.pendingLearn[id] = nil
        end
        if self.cast[id] or self.phase ~= "casting" then
            self.pendingCast[id] = nil
        end
    end

    if self.round ~= previous_round then
        self.resetPending = false
        self.circleReadyAnnounced = false
        self.message = "A new round! Find the three beginner charms."
    elseif self.phase == "celebrating" then
        self.message = "You made a rainbow burst with your friends!"
    elseif type(payload.lastAction) == "table" and payload.lastAction.type == "learn" then
        self.message = string.upper(payload.lastAction.charm or "CHARM") .. " learned by your spell circle!"
    elseif type(payload.lastAction) == "table" and payload.lastAction.type == "cast" then
        self.message = string.upper(payload.lastAction.charm or "CHARM") .. " joined the shared burst!"
    elseif self.phase == "casting" and previous_phase ~= "casting" then
        self.message = "All charms learned! Meet in the Wand Circle."
    end

    if self.phase == "celebrating" then
        local age_seconds = type(event.ageMs) == "number" and math.max(0, event.ageMs / 1000) or 0
        self.celebrationSeconds = math.max(0, CELEBRATION_SECONDS - age_seconds)
    else
        self.celebrationSeconds = 0
    end

    if self:has_pending_actions() then
        self:submit(api)
    end
end

function SpellboundRound:tick(api, delta_seconds)
    if self.phase ~= "celebrating" then
        return
    end
    self.celebrationSeconds = math.max(0, self.celebrationSeconds - delta_seconds)
    if self.celebrationSeconds > 0 then
        return
    end

    if not self.resetPending then
        self.resetPending = true
        self:submit(api)
        return
    end

    self.resetRetrySeconds = self.resetRetrySeconds - delta_seconds
    if self.resetRetrySeconds <= 0 then
        self:submit(api)
    end
end
