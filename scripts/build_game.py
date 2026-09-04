#!/usr/bin/env python3
"""Build the source tree into the portable first-game package.

The runtime intentionally receives one Luau chunk. Source modules use explicit
``-- @include \"relative/path.luau\"`` directives, which this script expands
recursively in a deterministic order. No third-party package or runtime module
loader is required by the clients.
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
import zipfile
from pathlib import Path, PurePosixPath
import re


INCLUDE_RE = re.compile(r'^\s*--\s*@include\s+"([^"]+)"\s*$')


def source_file(path: Path, source_root: Path, stack: tuple[Path, ...]) -> str:
    relative = path.relative_to(source_root).as_posix()
    if path in stack:
        chain = " -> ".join(item.relative_to(source_root).as_posix() for item in (*stack, path))
        raise ValueError(f"cyclic Luau include: {chain}")

    lines: list[str] = []
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        match = INCLUDE_RE.match(line)
        if not match:
            lines.append(line)
            continue

        include_value = PurePosixPath(match.group(1))
        if include_value.is_absolute() or ".." in include_value.parts:
            raise ValueError(f"{relative}:{line_number}: include must stay inside src/")
        include_path = source_root.joinpath(*include_value.parts)
        if not include_path.is_file():
            raise ValueError(f"{relative}:{line_number}: included file not found: {include_value}")
        lines.append(f"-- begin include: {include_value}")
        lines.append(source_file(include_path, source_root, (*stack, path)))
        lines.append(f"-- end include: {include_value}")

    return "\n".join(lines)


def build(source_root: Path, manifest_path: Path, output: Path, zip_path: Path | None) -> None:
    if not source_root.is_dir():
        raise ValueError(f"source directory not found: {source_root}")
    entry = source_root / "main.luau"
    if not entry.is_file():
        raise ValueError(f"Luau entry point not found: {entry}")
    if not manifest_path.is_file():
        raise ValueError(f"manifest not found: {manifest_path}")

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    game_id = manifest.get("id")
    version = manifest.get("version")
    if not isinstance(game_id, str) or not game_id:
        raise ValueError("manifest.id must be a non-empty string")
    if not isinstance(version, int) or isinstance(version, bool) or version < 1:
        raise ValueError("manifest.version must be a positive integer")

    if output.exists():
        shutil.rmtree(output)
    output.mkdir(parents=True)

    generated_script = (
        "-- GENERATED FILE: do not edit; edit src/ and run scripts/build_game.sh.\n"
        f"-- game: {game_id}\n"
        f"-- version: {version}\n\n"
        + source_file(entry, source_root, ())
        + "\n"
    )
    with (output / "game.luau").open("w", encoding="utf-8", newline="\n") as stream:
        stream.write(generated_script)
    shutil.copyfile(manifest_path, output / "manifest.json")

    assets = manifest_path.parent / "assets"
    if assets.is_dir():
        shutil.copytree(assets, output / "assets")

    payload_files = sorted(
        path.relative_to(output).as_posix()
        for path in output.rglob("*")
        if path.is_file()
    )
    package_info = {
        "formatVersion": 1,
        "id": game_id,
        "version": version,
        "entry": "game.luau",
        "manifest": "manifest.json",
        "files": payload_files,
    }
    with (output / "package.json").open("w", encoding="utf-8", newline="\n") as stream:
        stream.write(json.dumps(package_info, indent=2) + "\n")

    if zip_path is not None:
        zip_path.parent.mkdir(parents=True, exist_ok=True)
        if zip_path.exists():
            zip_path.unlink()
        with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for path in sorted(output.rglob("*")):
                if path.is_file():
                    archive.write(path, path.relative_to(output).as_posix())

    print(f"Built {game_id} v{version} -> {output}")
    if zip_path is not None:
        print(f"Wrote package archive -> {zip_path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path("build/package"))
    parser.add_argument("--zip", dest="zip_path", type=Path)
    args = parser.parse_args()
    project_root = Path(__file__).resolve().parent.parent
    try:
        build(project_root / "src", project_root / "manifest.json", args.output.resolve(),
              args.zip_path.resolve() if args.zip_path else None)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"first-game build failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
