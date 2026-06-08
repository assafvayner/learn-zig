# Learn Zig — a short, dense course for experienced programmers

A fork-and-go course that gets you from zero Zig to multi-file programs, third-party
packages, and basic concurrency. It assumes you already program well (Rust / Python / JS) —
it only teaches what's *Zig-specific*.

**Pinned to Zig 0.16.0.** Zig is pre-1.0 and changes between releases; install exactly this
version or the exercises may not compile.

## Setup

1. Install Zig **0.16.0**: <https://ziglang.org/download/0.16.0/> — verify with `zig version`.
2. Read the book: <!-- PAGES_URL --> (or build it locally: `cd book && mdbook serve`).
3. Work the exercises in `exercises/`. Each file says how to run it and what output to expect.

## How it works

- `book/` — the reading, one chapter per topic.
- `exercises/NN-topic/` — programs with `// TODO`s for you to fill in.
  - Chapters 0–7: `zig run exercises/NN-topic/xx.zig`
  - Chapters 8–11: `cd` into the project, then `zig build run` / `zig build test`
- `solutions/` — reference answers if you get stuck. Try first!

Every exercise file has a header comment with the task, how to run it, and the expected
output. Some also use `std.debug.assert`, so a wrong answer fails loudly when you run it.

## Course map

0. Setup & Hello
1. Values, Types & Control Flow
2. Errors & Optionals
3. Arrays, Slices & Strings
4. Structs, Enums & Unions
5. Memory & Allocators
6. Data Structures & the Standard Library
7. Comptime & Generics
8. Multi-file Programs & the Build System
9. Packages & Open-Source Libraries
10. Concurrency
11. Capstone

## License

MIT — fork it, remix it, teach with it.
