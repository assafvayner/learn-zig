# Capstone

`wordfreq` is the project that ties the course together: a CLI built with
`clap` (chapter 9), `std.StringHashMap` and `std.sort` (chapter 6), raw threads
(chapter 10), and a multi-file build (chapter 8). It counts word frequencies
across several text files **in parallel** and prints the top N most frequent
words.

## Spec

```
wordfreq [--top N] <file>...
```

- `--top N` selects how many words to print (default 10).
- one or more file positionals; each file is counted on its own thread.

One `std.Thread` per file. Each thread reads its file and builds a **local**
`std.StringHashMap(u32)` — no shared mutable state during counting, so there is
nothing to lock. After `join`, the per-file maps are merged into one, the
entries are collected into an array and sorted with `std.sort.pdq` (count
descending, ties broken by word ascending), and the top N are printed as
`word: count`.

This is the same partitioning idea from chapter 10: give each thread its own
result and combine after the join, rather than sharing one map behind a mutex
(which 0.16 removed anyway).

## Suggested decomposition

- `src/counter.zig` — the library. `countText` tokenizes and counts into a map;
  `mergeInto` folds one map into another; `topN` collects and sorts the entries.
  The `test` blocks live here and cover counting, merging, and the sort order.
- `src/worker.zig` — the per-file thread body: read the file, count it, store
  the result (or an error) in a private `Job` struct.
- `src/main.zig` — parse args with clap, spawn and join the threads, merge, and
  print.

### The lifetime trap

`StringHashMap` keys are `[]const u8` *slices*, not owned strings. `countText`'s
keys point into the file buffer it was handed, so that buffer has to outlive the
map. When you merge maps you have a choice: keep every source buffer alive for
as long as the merged map lives, or **dupe** each key into the merged map's
allocator so the merged map owns its keys outright. The reference solution dupes
on merge — it is the version that does not break when you later free a source
buffer. This is the chapter-5 ownership lesson showing up in a real program.

### Reading files in 0.16

File I/O goes through the new I/O interface. The whole-file read is
`std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(max))`, where `io`
comes from `init.io` in `main`. The returned buffer is owned by the caller.

## Stretch goals

- **Case-insensitive folding** — lowercase each word before counting. You now
  own the lowercased keys, so the free logic changes.
- **Stop-word filtering** — skip common words (`the`, `a`, `is`, ...) so the
  output surfaces meaningful terms.
- **A `--min-count` flag** — only print words seen at least N times.

## Where to go next

- **C interop** — `@cImport` pulls C headers straight into Zig; the build system
  can `translate-c` a header or compile C sources alongside your Zig code, so
  reusing an existing C library is a few lines of `build.zig`.
- **The new concurrency model** — `std.Io` lets the *caller* pick the backend
  (threads, an event loop, `io_uring`), and `std.Io.Group` gives structured
  concurrency: tasks spawned into a group are guaranteed to finish (or cancel)
  by the time you `await` it. That is where `wordfreq`'s threads-and-join shape
  is heading.
- **Cross-compilation** — `zig build -Dtarget=aarch64-linux-musl` (and friends)
  produces a binary for another OS/arch with no extra toolchain; Zig ships the
  libc headers and is itself a C/C++ cross-compiler.
