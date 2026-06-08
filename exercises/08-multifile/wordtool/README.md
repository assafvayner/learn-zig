# Exercise: `wordtool`

A two-file program plus tests, wired together by `build.zig`.

- `src/textstats.zig` — the library: `wordCount` and `charCount` (plus the tests that check them).
- `src/main.zig` — the entry point: imports `textstats` and prints the counts for a sample string.
- `build.zig` — already complete; defines the `run` and `test` steps.

## Tasks

1. Implement `wordCount` and `charCount` in `src/textstats.zig`.
2. Fill in `main` in `src/main.zig` to print `words: N` and `chars: N`.

## Run it

From inside this directory:

```sh
zig build test   # runs the textstats tests — make these pass first
zig build run    # builds and runs wordtool; should print "words: 7" then "chars: 32"
```
