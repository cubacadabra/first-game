# Cubacadabra First Game

The first sample game for Cubacadabra. This repository is the portable game
package: it contains content data and Luau rules, but no web, iOS, or Android
code.

The platform clients load `manifest.json` to build the world and load
`game.luau` into the Cubacadabra scripting runtime. A game author writes the
rules once in Luau; each client supplies the platform adapter for rendering,
input, audio, and native lifecycle concerns.

## Package layout

- `manifest.json` — declarative world content and presentation-independent
  settings
- `game.luau` — game-specific rules and lifecycle callbacks
- `assets/` — optional shared assets, when the game needs them

The first game currently demonstrates the shared lobby pattern: players join a
launch pad, the platform runtime owns the countdown and occupancy, and the
game script receives the launch event to begin `real-game`. That session keeps
only the players assembled on the winning pad and loads a small clearing with
no launch pads.

The native Rust host executes the Luau callbacks today. The browser package
loader and Rust ABI are already shaped for the same flow, but the browser
build still needs a dedicated Luau-WASM runtime before arbitrary game scripts
should be enabled there.
