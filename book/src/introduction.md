# Introduction

This is a short, dense Zig course for people who already know how to program. If you write
Rust, Python, or JavaScript and want to *get* Zig quickly, you're in the right place. We do
not explain what a loop, a hashmap, or the heap is. We explain what's **different and
surprising about Zig** — and then you write code.

## What you'll be able to do by the end

- Write and run single-file Zig programs, and split a program across multiple files.
- Manage memory explicitly with allocators (and let the compiler catch your leaks).
- Use the standard library's core data structures and the `comptime` generics that power them.
- Stand up a real project with `build.zig`, and pull in **open-source packages**.
- Write basic concurrent code with OS threads and atomics, dodging data races by partitioning work.

## Pinned to Zig 0.16.0

Zig is pre-1.0. The language, the standard library, and the build system change in meaningful
ways between releases — code written for 0.14 often won't compile on 0.16. **This course is
pinned to Zig 0.16.0.** Install exactly that version:

```console
$ zig version
0.16.0
```

Get it from <https://ziglang.org/download/0.16.0/>.

## Read the official docs alongside this

This course links into the official Zig documentation throughout — follow those links and get comfortable navigating them, because they are the source of truth as the language moves. Two hubs, both pinned to 0.16.0:

- The **[language reference](https://ziglang.org/documentation/0.16.0/)** — syntax and semantics (`comptime`, error unions, slices, the build system, …).
- The **[standard library docs](https://ziglang.org/documentation/0.16.0/std/)** — the searchable `std` API browser.

## How to use this course

Each chapter is a short read followed by exercises you actually run.

- **Chapters 0–7** are single files. Run one with `zig run exercises/NN-topic/xx.zig`.
- **Chapters 8–11** are real projects. `cd` into the project directory and use
  `zig build run` and `zig build test`.

Every exercise file opens with a comment block: the task, the command to run it, and the
**expected output**. Fill in the `// TODO`s until your output matches. Some exercises also
call `std.debug.assert`, so an incorrect answer crashes immediately — that's intentional
feedback.

Stuck? Reference answers live in `solutions/`, mirroring `exercises/` exactly. Try first;
peek second.

Let's go.
