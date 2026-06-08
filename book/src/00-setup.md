# Chapter 0 — Setup & Hello

## Verify your install

```
zig version   # must print 0.16.0
```

Every file in this course targets **Zig 0.16.0**. Online tutorials mostly target older releases; do not follow them without checking.

## Four commands you'll use constantly

| Command | What it does |
|---|---|
| `zig run <file>.zig` | Compile and run a single-file program. No `build.zig` needed. |
| `zig fmt <file>.zig` | Auto-format in place. Run after every edit. `--check` exits non-zero if formatting differs. |
| `zig test <file>.zig` | Compile and run `test` blocks in a file. |
| `zig build` | Run the project's `build.zig` (multi-file projects, later chapters). |

## Printing: two paths

### `std.debug.print` — easy, goes to stderr

No setup, no flush, always works:

```zig
const std = @import("std");

pub fn main() void {
    const x: u32 = 42;
    std.debug.print("value: {d}\n", .{x});
}
```

Format specifiers: `{s}` string, `{d}` integer, `{x}`/`{X}` hex, `{c}` byte-as-char, `{any}` anything, `{?d}` optional int, `{d:.2}` float precision, `{}` default.

Use `std.debug.print` for all exercises unless told otherwise. It writes to **stderr**, so it won't interfere with programs that produce meaningful stdout.

### Buffered stdout writer — real stdout, needs setup + flush

When a program's output *is* the point (pipelines, files), use the buffered writer. It requires the `init` parameter:

```zig
const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buf: [1024]u8 = undefined;
    var fw: std.Io.File.Writer = .init(.stdout(), io, &buf);
    const out = &fw.interface;
    try out.print("Hello, Zig!\n", .{});
    try out.flush();  // required — buffered output won't appear without this
}
```

Key differences from `std.debug.print`:
- Entry point is `pub fn main(init: std.process.Init) !void` (takes the `Init` arg, returns `!void`).
- You must call `flush()` or output is silently lost.
- Writes to **stdout**, not stderr.

## Exercise convention

Each exercise file has:
- A `//!` doc-comment header with the task description and `Expected output:`.
- A scaffold body with `// TODO:` comments where your code goes.
- Boilerplate (imports, consts, writer setup) already in place when it isn't the learning target.

Self-check with `std.debug.assert`:

```zig
std.debug.assert(result == 42);  // panics at runtime if false
```

Run your solution with `zig run exercises/00-setup/<file>.zig`. When output matches the header, move on.

## Exercises

### 01 — Hello, Zig! (buffered stdout)

File: `exercises/00-setup/01_hello.zig`

Print exactly `Hello, Zig!` using the buffered stdout writer. The writer boilerplate is already in place — fill in the `print` and `flush` calls.

Expected output:
```
Hello, Zig!
```

### 02 — Greeting (debug.print with format specifiers)

File: `exercises/00-setup/02_greeting.zig`

Given `const name = "world"` and `const year: u32 = 2026`, use `std.debug.print` to produce:

```
Hello, world! It is 2026.
```

Use `{s}` for the string and `{d}` for the integer.
