# Multi-file Programs & the Build System

Up to now every example was a single file run with `zig run`. Real programs span multiple files and are driven by `build.zig` — a Zig program that describes how to compile, run, and test your code. This chapter builds a small project called `wordtool` to introduce both, using the [build system](https://ziglang.org/documentation/0.16.0/#Zig-Build-System).

The project layout:

```
wordtool/
├── build.zig
└── src/
    ├── main.zig        // entry point
    └── textstats.zig   // library: wordCount, charCount + tests
```

---

## @import and pub visibility

[A file is a struct](https://ziglang.org/documentation/0.16.0/#Source-File-Structs). You bring one file into another with [`@import`](https://ziglang.org/documentation/0.16.0/#import), passing the path relative to the importing file:

```zig
const std = @import("std");
const textstats = @import("textstats.zig");

const n = textstats.wordCount("a b c"); // 3
```

`@import("textstats.zig")` evaluates to the file's namespace. Only declarations marked `pub` are reachable from the importer — everything else is private to the file. This is the entire module boundary: no headers, no export lists.

```zig
// textstats.zig
pub fn wordCount(s: []const u8) usize { ... } // visible to importers
fn helper() void { ... }                       // file-private
```

`@import("std")` works the same way; `std` is just a module the compiler makes available by name.

---

## Splitting a program: library + main + tests

Put reusable logic in its own file. `textstats.zig` exposes two functions and keeps its tests alongside the code they exercise:

```zig
// src/textstats.zig
const std = @import("std");

pub fn wordCount(s: []const u8) usize {
    var it = std.mem.tokenizeScalar(u8, s, ' ');
    var n: usize = 0;
    while (it.next()) |_| {
        n += 1;
    }
    return n;
}

pub fn charCount(s: []const u8) usize {
    return s.len;
}

test "wordCount" {
    try std.testing.expectEqual(@as(usize, 4), wordCount("a b c d"));
}
```

`main.zig` is a thin entry point that imports the library and produces output:

```zig
// src/main.zig
const std = @import("std");
const textstats = @import("textstats.zig");

pub fn main() void {
    const sample = "the quick brown fox the lazy dog";
    std.debug.print("words: {d}\n", .{textstats.wordCount(sample)});
    std.debug.print("chars: {d}\n", .{textstats.charCount(sample)});
}
```

Tests live in the same file as the code they cover. Keeping them there means a test build of `textstats.zig` compiles the library and its tests together.

---

## Anatomy of build.zig

`build.zig` defines a single `pub fn build(b: *std.Build) void`. The `b` builder, typed as [`std.Build`](https://ziglang.org/documentation/0.16.0/std/#std.Build), is your handle for declaring artifacts and steps.

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "wordtool",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run wordtool");
    run_step.dependOn(&run_cmd.step);

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/textstats.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
```

Piece by piece:

- **`standardTargetOptions` / `standardOptimizeOption`** expose `-Dtarget=` and `-Doptimize=` on the command line, so users can cross-compile or pick `Debug`/`ReleaseFast` without editing the build file.
- **`addExecutable`** declares a binary. In 0.16 the source and build settings live in a *module*: `.root_module = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = ..., .optimize = ... })`. (`b.path` resolves a path relative to the project root.) Note `main.zig` imports `textstats.zig` directly — no separate module wiring is needed for files within one package.
- **`installArtifact(exe)`** adds the exe to the default `install` step, so a bare `zig build` writes it to `zig-out/bin/`.
- **The run step**: `addRunArtifact(exe)` creates a command that runs the built binary; depending on the install step ensures it is built first; `b.args` forwards anything after `--`; and `b.step("run", ...)` names it so `zig build run` works.
- **The test step**: `addTest` compiles a file's [`test`](https://ziglang.org/documentation/0.16.0/#Test-Declarations) blocks into a test runner — here against `src/textstats.zig`. `addRunArtifact` runs it, and `b.step("test", ...)` exposes `zig build test`.

---

## Running and testing

From inside the project directory:

```sh
zig build          # build and install to zig-out/bin/wordtool
zig build run      # build, then run wordtool
zig build test     # run the textstats tests (silent on success)
```

`zig build run` prints:

```
words: 7
chars: 32
```

Anything after `--` is forwarded to the program via `b.args`:

```sh
zig build run -- --verbose some-file.txt
```

Here those arguments reach `wordtool` as `std.process.args`; the build system passes them straight through.

---

## Exercises

- **`wordtool/`** — a multi-file project. `build.zig` is complete. Implement `wordCount` and `charCount` in `src/textstats.zig` so `zig build test` passes, then fill in `main` in `src/main.zig` so `zig build run` prints `words: 7` and `chars: 32`.
