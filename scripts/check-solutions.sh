#!/usr/bin/env bash
# Compile/run every reference solution against the pinned Zig version so the course
# can't silently rot. Single-file solutions (chapters 0-7) are run directly; project
# solutions (chapters 8-11) are built (and tested/run where applicable).
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== zig version =="
zig version

echo "== fmt check =="
zig fmt --check solutions exercises

echo "== single-file solutions (chapters 0-7) =="
while IFS= read -r -d '' f; do
  # Skip anything inside a project chapter directory (those have their own build.zig).
  case "$f" in
    */0[89]-*|*/1[01]-*) continue ;;
  esac
  if [[ "$f" == *_test.zig ]]; then
    echo "-- test $f"
    zig test "$f"
  else
    echo "-- run  $f"
    zig run "$f"
  fi
done < <(find solutions -type f -name '*.zig' -print0 | sort -z)

echo "== project solutions (chapters 8-11) =="
# Each entry is "<project-dir>:<mode>" where mode is one of:
#   run   -> zig build test && zig build   (fully runnable in CI)
#   build -> zig build                     (build-only, e.g. needs a display)
# Chapter tasks append their project here as they are implemented.
PROJECTS=(
  "solutions/08-multifile/wordtool:run"
  "solutions/10-concurrency/parallel:run"
)
for entry in "${PROJECTS[@]:-}"; do
  [ -z "$entry" ] && continue
  dir="${entry%%:*}"
  mode="${entry##*:}"
  echo "-- $mode $dir"
  if [ "$mode" = "run" ]; then
    ( cd "$dir" && zig build test && zig build )
  else
    ( cd "$dir" && zig build )
  fi
done

echo "== all solutions verified =="
