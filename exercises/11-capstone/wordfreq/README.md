# Capstone: `wordfreq`

Count word frequencies across multiple text files **in parallel** and print the
top N most frequent words. This ties together the whole course: a CLI built with
`clap` (chapter 9), `std.StringHashMap` and `std.sort` (chapter 6), raw threads
(chapter 10), and a multi-file build (chapter 8).

## What it does

```
wordfreq [--top N] <file>...
```

- `--top N` — how many words to print (default 10).
- one or more file positionals — each is counted on its own thread.

It spawns one `std.Thread` per file. Each thread reads its file and builds a
**local** `std.StringHashMap(u32)` (no shared mutable state during counting).
After `join`, the per-file maps are merged into one, the entries are collected
into an array and sorted with `std.sort.pdq` (count descending, ties broken by
word ascending), and the top N are printed as `word: count`.

## File decomposition

- `src/counter.zig` — the library: `countText`, `mergeInto`, `topN` (plus the
  tests that check them). Watch the key-lifetime contract in the doc comments.
- `src/worker.zig` — the per-file thread body: read a file, count it, store the
  result in a private `Job`.
- `src/main.zig` — parse args with clap, orchestrate the threads, merge, print.

## Tasks

1. Implement `countText`, `mergeInto`, `deinitOwned`, `moreFrequent`, and `topN`
   in `src/counter.zig` until the tests pass.
2. Implement `run` and `deinitJob` in `src/worker.zig`.
3. Implement the parallel pipeline in `src/main.zig`.

## Run it

```sh
zig build test          # implement counter.zig until these pass
zig build run -- --top 5 sample1.txt sample2.txt sample3.txt
```

Expected top 5 across the three samples:

```
the: 13
is: 7
and: 6
a: 5
dog: 4
```

## Stretch goals

- **Case-insensitive folding** — lowercase each word before counting so `The`
  and `the` collapse into one entry. (You will now own the lowercased key
  strings — adjust the lifetime/free logic accordingly.)
- **Stop-word filtering** — skip common words (`the`, `a`, `is`, `and`, ...) so
  the output highlights meaningful terms.
- **A `--min-count` flag** — only print words that occur at least N times.
