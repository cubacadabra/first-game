#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tools_dir="$script_dir/../../tools"

if [ ! -f "$tools_dir/pyproject.toml" ] || [ ! -d "$tools_dir/src/cubacadabra" ]; then
  echo "The shared Cubacadabra tools checkout is missing: $tools_dir" >&2
  exit 1
fi

project_dir="$script_dir/.."
PYTHONPATH="$tools_dir/src${PYTHONPATH:+:$PYTHONPATH}" \
  exec python3 -m cubacadabra build-game "$project_dir" "$@"
