# Exercise: bouncing balls (raylib-demo)

A native dependency — **raylib** (a C library) — combined with **clap** for the flags.

- `build.zig` / `build.zig.zon` — already complete. `zig build` fetches raylib + clap
  and compiles the raylib C sources. **The first build is slow (minutes); later builds
  are cached.**
- `src/main.zig` — implement the program logic (follow the `// TODO:` comments).

## System requirements

- **macOS:** just the Xcode Command Line Tools (`xcode-select --install`). raylib links
  the system Cocoa / IOKit / OpenGL frameworks — no `brew install` needed.
- **Ubuntu / Debian:**
  ```sh
  sudo apt install libasound2-dev libx11-dev libxrandr-dev libxi-dev \
       libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev \
       libwayland-dev libxkbcommon-dev
  ```

## Run it

From inside this directory. Building is the success criterion; running opens a window:

```sh
zig build                                          # the gate — must succeed
zig build run -- --count 12 --width 1024 --height 640
```
