# Cubacadabra First Game

This repository is the portable source package for the first example game.
It contains the manifest, world content, and Luau rules. The shared tools
repository builds it into the package consumed by the web, iOS, Android, and
Rust clients.

The repositories are expected to be sibling directories:

~~~text
backend/       multiplayer Worker and world sessions
first-game/    this package
rust/          platform-neutral simulation and renderer
web/           browser shell and package host
ios_app/       Swift platform adapter
android_app/  Kotlin platform adapter
~~~

## Developer Preview 0.3: Spellbound Schoolyard

Players arrive in a sunny schoolyard and discover three beginner charms:
Spark, Splash, and Sprout. Walking into a glowing interaction zone teaches the
charm. Once all three are learned, players gather in the Wand Circle and tap
each charm to make a rainbow burst.

A solo player can complete the loop. Two or three players can split up to find
charms and then celebrate together in the circle. The round resets after a
short celebration, making the game easy to replay. There are no NPCs or dark
themes in this preview.

Future versions can add more kid-friendly charms, spell combinations, wand
trails, badges, time trials, and friendly teachers or creatures.

## Generic game contract

The manifest deliberately uses generic interactions. Rust does not know what
a spell, schoolyard, or Wand Circle is:

~~~json
"interactions": [{
  "id": "spark",
  "kind": "zone",
  "label": "SPARK",
  "position": [-15, 0, -8],
  "radius": 2.7,
  "color": "spark",
  "visual": "charm-pad"
}]
~~~

Rust provides proximity tracking, local enter/exit events, bounded effect
primitives, and the number of players in each zone. The manifest composes the
`charm-pad`, `wand-circle`, and `rainbow-burst` visuals; Luau owns their states
and triggers:

~~~luau
function Game.on_interaction(api, event)
    -- event.id, event.phase ("enter"/"exit"), event.players
end

local state = api.interactions:get_state()
local zone = state.zones["spark"]
-- zone.inside, zone.nearby, zone.players, zone.kind, zone.label

api.effects:set_state("spark", "collected")
api.effects:play("rainbow-burst", { position = { 0, 0, 0 } })
~~~

This same API can power doors, checkpoints, treasures, race gates, or any
other game without adding game-specific Rust types. Backend messaging should
remain a separate generic contract, so a future game can publish its own
events and state without teaching the platform about its theme.

Spellbound Schoolyard uses the compare-and-set retained channel
`schoolyard-round`. Its Luau state contains the round, phase, learned charms,
shared casts, burst count, and last action. Concurrent players merge and retry
against the Durable Object's sequence, so one player learning or casting cannot
erase another player's progress. The runtime and backend only carry opaque JSON
and sequences; another game can use the same primitive with completely
different state and rules.

## Source and build

- manifest.json — package metadata and declarative world content
- effects.json — game-owned effect recipes inlined into the built manifest
- src/main.luau — portable lifecycle entry point
- src/round.luau — Spellbound's reducer and accepted-state feedback
- src/ui/ — game-owned UI document, styles, and actions

Build the package from this directory with the shared tools:

~~~sh
PYTHONPATH=../tools/src python3 -m cubacadabra build-game . \
  --output build/package --zip build/first-game-v0.3.0.zip
~~~

The generated package contains manifest.json, game.luau, package.json, and
optional assets. It is the runtime distribution used by all clients.

The entry point explicitly includes
`@cubacadabra/shared-state-v1.luau` and
`@cubacadabra/disclosure-v1.luau`. The SDK helpers own compare-and-set intent
queuing and the compact objective's open state, while
`round.luau` owns only Spellbound's state schema, reducer, and presentation.

Spellbound teaches its objective with a game-owned schoolyard billboard. Its
persistent HUD is only a compact charm-progress control; tapping it reveals
the current round detail. The bottom-center progress control is replaced by
the three casting actions when the player enters the Wand Circle.

The package owns its short one-shot sounds under `assets/audio/` and declares
them by id in `manifest.json`. Game rules trigger them with
`api.audio:play("sound-id")`; the shared runtime and each host remain responsible
for playback. New games can ship their own WAV files without adding themed
assets or sound ids to Rust.

Lobbies are optional. Set "lobby": false to route players directly to the
manifest's start world or its launch destination. The current game uses direct
start so players can begin playing immediately.

Read ../web/README.md for package syncing and ../rust/README.md for the runtime
and host API.
