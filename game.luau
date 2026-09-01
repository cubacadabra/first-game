-- The portable rules for Cubacadabra's first game.
--
-- The platform host provides this small API on web, iOS, and Android. The
-- renderer never calls these rules directly; it only presents the state the
-- host produces.

local FirstGame = {}

function FirstGame.on_start(api)
    api.lobby:set_status("Players are finding their launch pads")
end

function FirstGame.on_tick(api, _delta_seconds)
    -- Game-specific rules belong here as the first game grows.
    -- Movement, collision, launch-pad timing, and manifest world routes remain
    -- platform services.
end

return FirstGame
