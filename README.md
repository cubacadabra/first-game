# Cubacadabra First Game

This repository is the portable game package. It contains content data and
Luau rules, but no web, iOS, or Android code. The package is consumed by the
clients at runtime:

- `web` copies it into `public/games/first-game/` before each dev or
  production build and loads it in the browser.
- `ios_app` fetches the same `manifest.json` and `game.luau` from the web
  host.
- `rust` parses the manifest and hosts the Luau lifecycle API used by native
  clients. The browser currently keeps the scripting seam while its dedicated
  Luau-WASM runtime is still pending.

The repositories are expected to be sibling directories. The backend supplies
multiplayer world sockets, while this package supplies the world description
and game-specific rules:

```text
backend/       multiplayer Worker and one Durable Object per world
first-game/    this package
rust/          platform-neutral simulation and renderer
web/           browser shell and package host
ios_app/       Swift platform adapter
```

When starting here, read [web/README.md](../web/README.md) next to see how the
package is loaded and run. Then read [rust/README.md](../rust/README.md) for
the runtime that interprets its data, or [ios_app/README.md](../ios_app/README.md)
for the native adapter.

## Package layout

- `manifest.json` — declarative world content and presentation-independent
  settings
- `game.luau` — game-specific rules and lifecycle callbacks
- `assets/` — optional shared assets, when the game needs them

The manifest starts players in the `lobby`. Its three launch pads share a
countdown and route the winning cohort to `real-game`. The platform runtime
owns movement, collision, occupancy, countdown, player selection, and world
routing; the Luau package is the place for game-specific effects and rules.

The important package URLs on a running web host are:

```text
http://<web-host>:5173/games/first-game/manifest.json
http://<web-host>:5173/games/first-game/game.luau
```

Keep the manifest compatible with the loaders in `web/src/game/` and
`ios_app/cubacadabra/GamePackage.swift`. If you change a field, update both
loaders and the Rust package model where appropriate.

## Local development

There is no server to run in this repository. Start the dependent services
from [backend/README.md](../backend/README.md) and
[web/README.md](../web/README.md). From `web/`, `npm run sync:game` copies the
current sibling package into `web/public/games/first-game/`; the normal
`npm run dev` and `npm run build` commands run that sync automatically.

For a LAN session, use `npm run dev:lan` in `backend/` and start
`web/` with `VITE_BACKEND_WS_URL=ws://<mac-lan-ip>:8787 npm run dev:lan`.
For iOS, also set the package and backend URLs in the Xcode scheme as described
in [ios_app/README.md](../ios_app/README.md).

For the iOS app, start the backend and web server first, then run the Debug
scheme in Xcode. The app reads the package from the web server and connects to
the backend's `lobby` socket. A physical device uses the Mac's LAN address in
the Xcode environment variables described in [ios_app/README.md](../ios_app/README.md).

## Production

The package is part of the web deployment, not a separate package service. The
web deployment publishes it under:

```text
https://cubacadabra.com/games/first-game/
```

The production iOS build defaults to that package URL. A local web build also
uses this package but connects to the production Worker when built with Vite's
production commands; see [web/README.md](../web/README.md) for the exact
commands and endpoint override. The web deployment's package sync runs during
`npm run build`, so deploy from `web/` after changing this repository.

## Where to look next

- [web/README.md](../web/README.md) — how this package is synced and rendered
- [rust/README.md](../rust/README.md) — simulation, rendering, and package host
- [ios_app/README.md](../ios_app/README.md) — native package loading and input
