# Packages & Open-Source Libraries

Chapter 8 split a program across files inside one package. Real programs also pull in *other people's* packages. Zig ships a [package manager](https://ziglang.org/documentation/0.16.0/#Zig-Build-System) built into the compiler — no separate tool, no central registry. A dependency is a URL plus a content hash, recorded in `build.zig.zon` and fetched on demand.

This chapter is three small projects, each consuming a real third-party library:

- **9.1 `repeat`** — a CLI built on **zig-clap** (your first dependency).
- **9.2 bouncing balls** — a window built on **raylib**, a native C library.
- **9.3 quote API** — a JSON server built on **httpz**, pure Zig.

---

## How the package manager works

### `build.zig.zon`

Alongside `build.zig`, a project has a `build.zig.zon` — a Zig Object Notation manifest describing the package itself and its dependencies:

```zig
.{
    .name = .repeat,                 // an enum literal, not a string
    .version = "0.1.0",
    .fingerprint = 0xa857b3c0ffff6f17, // generated once; identifies this package
    .minimum_zig_version = "0.16.0",
    .dependencies = .{},             // filled in by `zig fetch --save`
    .paths = .{ "build.zig", "build.zig.zon", "src" },
}
```

`zig init` generates `.name` and `.fingerprint` for you. The fingerprint is a stable id for *your* package; if you write the manifest by hand and the value is wrong, the compiler prints the correct one to paste in.

### `zig fetch --save`

You don't edit `.dependencies` by hand. You run:

```sh
zig fetch --save git+https://github.com/Hejsil/zig-clap
```

This downloads the package, computes its hash, and records both under a key in `build.zig.zon`:

```zig
.dependencies = .{
    .clap = .{
        .url = "git+https://github.com/Hejsil/zig-clap#bf56f229…",
        .hash = "clap-0.12.0-oBajB9no…",
    },
},
```

Two things to note on 0.16:

- Use the **`git+`** URL scheme for GitHub repos. A bare `https://github.com/…` URL fails — the server answers with an HTML page, not a tarball.
- The `--save` key (`clap` here) is the name you'll pass to `b.dependency(...)` in `build.zig`. You can force a different key with `--save=<name>`.

### Wiring a dependency in `build.zig`

A fetched package is inert until you reference it. In `build.zig`, ask the builder for the dependency by its manifest key, pull a *module* out of it, and add that module to your executable's imports:

```zig
const clap = b.dependency("clap", .{ .target = target, .optimize = optimize });

const exe = b.addExecutable(.{
    .name = "repeat",
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "clap", .module = clap.module("clap") },
        },
    }),
});
```

The `.name` in `.imports` is the string you'll `@import`. The `.module(...)` argument is the import name the *dependency* exposes (set in the library's own `build.zig`) — usually, but not always, the same word.

### Using it in code

```zig
const clap = @import("clap");
```

Now `clap` resolves to the dependency's module, exactly like `@import("std")`.

### Where deps live

On 0.16, `zig build` fetches dependencies into a project-local `zig-pkg/` directory (next to `build.zig`), in addition to the global cache. Don't commit `zig-pkg/` — the `.url` + `.hash` in `build.zig.zon` is the source of truth, and any machine can reproduce the tree from it. (`.zig-cache/` and `zig-out/` are likewise generated.)

---

## 9.1 clap-cli — your first dependency

[zig-clap](https://github.com/Hejsil/zig-clap) is a declarative argument parser. You describe the flags as text, and clap parses `argv` into a typed result.

Fetch it:

```sh
zig fetch --save git+https://github.com/Hejsil/zig-clap
```

> clap's own manifest declares a `minimum_zig_version` of `0.17.0-dev…`. That field is advisory for `zig build`; clap compiles and runs fine on 0.16.0, so the warning (if any) is harmless.

The whole program — `repeat --count 3 --upper hello` prints `HELLO` three times:

```zig
const std = @import("std");
const clap = @import("clap");

pub fn main(init: std.process.Init) !void {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help           Display this help and exit.
        \\-c, --count <usize>  How many times to repeat (default 1).
        \\-u, --upper          Upper-case the word before printing.
        \\<str>                The word to repeat.
        \\
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, init.minimal.args, .{
        .diagnostic = &diag,
        .allocator = init.gpa,
    }) catch |err| {
        try diag.reportToFile(init.io, .stderr(), err);
        return err;
    };
    defer res.deinit();

    const count = res.args.count orelse 1;
    const word = res.positionals[0] orelse "hello";
    // … upper-case if res.args.upper != 0, then print `word` `count` times.
}
```

Three things are new in the 0.16 entry point and worth pinning down:

- **`pub fn main(init: std.process.Init)`.** The runtime hands you an [`std.process.Init`](https://ziglang.org/documentation/0.16.0/std/#std.process.Init) struct instead of you fishing for argv and stdout yourself. `init.minimal.args` is the raw argument iterator clap parses, `init.gpa` is a process-lifetime allocator, and `init.io` is the `std.Io` instance the new standard library threads through every I/O call. That's why diagnostics print via `diag.reportToFile(init.io, .stderr(), err)`.
- **Flags vs. counts.** A boolean flag like `--upper` is a *count* (`res.args.upper != 0` means it was passed); `--count <usize>` is an optional value (`res.args.count orelse 1`).
- **One positional is optional, not a slice.** A single `<str>` makes `res.positionals[0]` a `?[]const u8` — hence `orelse "hello"`. Declare `<str>...` instead and you'd get a slice to iterate. Mixing these up is the most common first mistake.

No system dependencies. `zig build run -- --count 3 --upper hello` prints `HELLO`, `HELLO`, `HELLO`.

---

## 9.2 raylib-demo — a native dependency

[raylib](https://www.raylib.com/) is a C graphics library; [raylib-zig](https://github.com/raylib-zig/raylib-zig) gives it idiomatic Zig bindings. This is the same fetch-and-wire flow as clap, with two differences: the package builds C source (so the *first* build takes minutes), and it exposes both a Zig **module** and a linkable C **artifact**.

Fetch the `devel` branch (v6.0.0), pinned to a commit so the lesson doesn't drift:

```sh
zig fetch --save git+https://github.com/raylib-zig/raylib-zig#97be2c7ae646a2f09856604b138c427c0af1b952
```

> Use the `raylib-zig/raylib-zig` org repo, **not** the older `Not-Nik/raylib-zig` — the latter is deprecated and does not build on 0.16.0.

The wiring needs both halves of the dependency, and on 0.16 they attach to the root **module**:

```zig
const raylib_zig = b.dependency("raylib_zig", .{ .target = target, .optimize = optimize });
const raylib_mod = raylib_zig.module("raylib");        // the @import("raylib") bindings
const raylib_artifact = raylib_zig.artifact("raylib"); // the raylib C library

const exe = b.addExecutable(.{ .name = "balls", .root_module = b.createModule(.{
    .root_source_file = b.path("src/main.zig"),
    .target = target,
    .optimize = optimize,
}) });
exe.root_module.addImport("raylib", raylib_mod);
exe.root_module.linkLibrary(raylib_artifact);
```

> `linkLibrary` / `addImport` go on `exe.root_module`, not on `exe` directly — `exe.linkLibrary(...)` no longer exists on 0.16.

In code, raylib drives its own I/O, so the loop is plain raylib calls (`rl.initWindow`, `rl.beginDrawing`, `rl.drawCircle`, …). This demo still parses `--count`, `--width`, and `--height` with **clap** — reused from 9.1, fetched into the same project — to size the window and the number of balls.

**System requirements.** raylib compiles against your platform's windowing and GL headers:

- **macOS:** just the Xcode Command Line Tools (`xcode-select --install`). raylib links the system Cocoa / IOKit / OpenGL frameworks; no `brew install` needed.
- **Ubuntu / Debian:**
  ```sh
  sudo apt install libasound2-dev libx11-dev libxrandr-dev libxi-dev \
       libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev \
       libwayland-dev libxkbcommon-dev
  ```

`zig build` is the success criterion (and it builds in CI). `zig build run` opens a window, so run it locally to watch the balls bounce.

---

## 9.3 httpz-api — a pure-Zig web server

[httpz](https://github.com/karlseguin/http.zig) (also called http.zig) is an HTTP server written entirely in Zig — no C, no system dependencies. We'll serve one route, `GET /quote`, returning JSON, with `--port` parsed by **clap** (reused again).

Fetch it:

```sh
zig fetch --save git+https://github.com/karlseguin/http.zig
```

The saved key is `httpz` and the import name is `httpz`. Wiring is the by-now-familiar `.imports` entry (this project lists both `httpz` and `clap`).

```zig
const std = @import("std");
const httpz = @import("httpz");

pub fn main(init: std.process.Init) !void {
    // … parse --port with clap (port defaults to 8080) …

    var server = try httpz.Server(void).init(init.io, init.gpa, .{
        .address = .localhost(port),
    }, {});
    defer { server.stop(); server.deinit(); }

    var router = try server.router(.{});
    router.get("/quote", quote, .{});

    try server.listen(); // blocks until server.stop()
}

fn quote(_: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    try res.json(.{
        .author = "Andrew Kelley",
        .quote = "Zig is a general-purpose programming language and toolchain.",
    }, .{});
}
```

Notes on the 0.16 httpz API:

- **`Server(Handler).init(io, allocator, config, handler)`.** The first argument is `init.io`, the I/O interface. Older tutorials pass only `(allocator, config, handler)` and won't compile on 0.16. `Server(void)` means a stateless handler, so the handler instance is `{}`; for shared state you'd use `Server(*App)` and pass `&app`.
- **Handlers are `fn (req: *httpz.Request, res: *httpz.Response) !void`.** `res.json(value, .{})` serializes any struct to a JSON body and sets the content type. Path captures like `:name` come back from `req.param("name")` as `?[]const u8`.
- **`server.listen()` blocks.** The `defer { server.stop(); server.deinit(); }` gives a clean shutdown.

```sh
zig build run -- --port 8080
curl http://localhost:8080/quote
# {"author":"Andrew Kelley","quote":"Zig is a general-purpose programming language and toolchain."}
```

---

## Exercises

- **`1-clap-cli/`** — `build.zig` / `build.zig.zon` are complete (`zig build` fetches clap). Implement `repeat` so `zig build run -- --count 3 --upper hello` prints `HELLO` three times and `zig build run -- hello` prints `hello`.
- **`2-raylib-demo/`** — build files are complete (`zig build` fetches and compiles raylib + clap). Implement the bouncing-balls loop; `zig build` must succeed. Run it locally to see the window.
- **`3-httpz-api/`** — build files are complete (`zig build` fetches httpz + clap). Implement the `GET /quote` route; `curl http://localhost:8080/quote` should return the JSON quote.
