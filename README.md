# Cubacadabra First Game

This repository is the portable game source package. It contains content data
and Luau rules, but no web, iOS, or Android code. `scripts/build_game.sh`
turns it into the runtime package consumed by all clients:

- `web` builds it into `public/games/first-game/` before each dev or production
  build and serves the generated package in the browser.
- `ios_app` and `android_app` build the same generated package into their app
  bundles, then refresh a validated copy from the web host for the next launch.
- `rust` parses the manifest and hosts the generated Luau entry script for
  native and browser clients. Native builds use `mlua`; the browser build uses
  the pure-Rust `luaur-rt` runtime behind the same host API.

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

## Source and package layout

- `manifest.json` — declarative world content and presentation-independent
  settings; it remains the package metadata source of truth
- `src/main.luau` — portable lifecycle entry point
- `src/ui/` — game-owned UI document, styles, and actions
- `assets/` — optional shared assets, when the game needs them

The shared `cubacadabra build-game` command writes a generated package directory containing `manifest.json`,
`game.luau`, `package.json`, and optional assets. `game.luau` is a single
runtime entry script assembled from the source includes; clients do not need a
filesystem or a Luau `require` implementation. Pass `--zip path` when an
exportable archive is useful:

```sh
./scripts/build_game.sh --output build/package --zip build/first-game-v1.zip
```

The shell script is a compatibility entrypoint for the shared CLI in the
sibling `tools` repository. New game repositories can use the same command
directly, for example `cubacadabra build-game ../second-game`.

The manifest starts players in the `lobby`. `BUILD TOGETHER` is the first live
launch pad; the other two remain visible as muted `COMING SOON` destinations.
The backend owns the synchronized countdown and cohort selection. Players then
enter a shared build round in `real-game`, where the web client can place,
rotate, remove, recolor, save, and tour blocks together.

The important package URLs on a running web host remain:

```text
http://<web-host>:5173/games/first-game/manifest.json
http://<web-host>:5173/games/first-game/game.luau
```

Keep the manifest compatible with the loaders in `web/src/game/`,
`ios_app/cubacadabra/GamePackage.swift`, and
`android_app/app/src/main/java/dev/andrewarrow/cubacadabra/game/GamePackage.kt`.
If you change a field, update all loaders and the Rust package model where
appropriate.

## Local development

There is no server to run in this repository. Start the dependent services
from [backend/README.md](../backend/README.md) and
[web/README.md](../web/README.md). From `web/`, `npm run sync:game` builds the
current sibling source into `web/public/games/first-game/`; the normal
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

## Distribution guidance

The generated directory is the canonical runtime distribution because all
three clients can stream its small files and static web hosting can serve it
without an archive runtime. A ZIP is available for exports, CI artifacts, or a
future CDN cache, but it is not required at runtime. Production remote updates
should eventually add a signed package metadata file and signature verification
before accepting downloaded Luau rules; the current clients validate size,
encoding, JSON, and world references before caching.

## Where to look next

- [web/README.md](../web/README.md) — how this package is synced and rendered
- [rust/README.md](../rust/README.md) — simulation, rendering, and package host
- [ios_app/README.md](../ios_app/README.md) — native package loading and input
