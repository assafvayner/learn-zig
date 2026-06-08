# Exercise: `repeat` (clap-cli)

Your first program with a third-party dependency: a CLI built on **zig-clap**.

- `build.zig` / `build.zig.zon` — already complete. `zig build` fetches clap into a
  local `zig-pkg/` dir and wires `@import("clap")` for you.
- `src/main.zig` — implement the program logic (follow the `// TODO:` comments).

## Goal

```
repeat --count 3 --upper hello   ->  HELLO   (printed three times, one per line)
repeat hello                     ->  hello
```

## Run it

From inside this directory:

```sh
zig build run -- --count 3 --upper hello
zig build run -- hello
```
