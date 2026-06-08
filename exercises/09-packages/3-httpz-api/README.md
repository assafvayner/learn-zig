# Exercise: quote API (httpz-api)

A tiny JSON web server built on **httpz** (pure Zig), with **clap** for the `--port` flag.

- `build.zig` / `build.zig.zon` — already complete. `zig build` fetches httpz + clap and
  wires both modules for you.
- `src/main.zig` — implement the program logic (follow the `// TODO:` comments).

## Goal

```
GET /quote   ->   {"author":"...","quote":"..."}
```

## Run it

From inside this directory:

```sh
zig build run -- --port 8080
# in another terminal:
curl http://localhost:8080/quote
```
