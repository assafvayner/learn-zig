//! Exercise 9.2 — raylib-demo: a bouncing-balls window.
//!
//! A native dependency (raylib, a C library) plus a pure-Zig one (clap).
//! clap parses the options; raylib opens the window and draws the balls.
//!
//! Flags:  --count N (default 3), --width W (default 800), --height H (default 450)
//!
//! build.zig / build.zig.zon are already wired: `zig build` fetches raylib + clap
//! and compiles the raylib C sources (the first build is slow — minutes).
//! Build:  zig build              (the gate; building is success)
//! Run:    zig build run -- --count 12 --width 1024 --height 640   (opens a window)

const std = @import("std");
const rl = @import("raylib");
const clap = @import("clap");

const Ball = struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    radius: f32,
    color: rl.Color,
};

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // TODO 1: Parse --count <usize>, --width <i32>, --height <i32> (and -h/--help)
    //   with clap — same pattern as 9.1, using init.minimal.args / init.gpa.
    //   Default count=3, width=800, height=450.

    // TODO 2: Allocate `count` Ball values (gpa.alloc(Ball, count); defer free)
    //   and initialize each with a position, a velocity, a radius, and a color
    //   (rl.Color values like .red, .blue, .green ...).
    //   Use std.Random for variety — the Zig RNG idiom is:
    //       var prng = std.Random.DefaultPrng.init(0xBA11_5EED);
    //       const rand = prng.random();
    //       // rand.float(f32) -> [0,1) ; rand.intRangeLessThan(i32, lo, hi) -> [lo,hi)
    //   Docs: https://ziglang.org/documentation/0.16.0/std/#std.Random

    // TODO 3: Open the window:
    //   rl.initWindow(width, height, "bouncing balls");
    //   defer rl.closeWindow();
    //   rl.setTargetFPS(60);

    // TODO 4: Main loop `while (!rl.windowShouldClose())`:
    //   - advance each ball by its velocity; flip vel.x / vel.y at the edges.
    //   - rl.beginDrawing(); defer rl.endDrawing();
    //   - rl.clearBackground(.ray_white);
    //   - rl.drawCircle(@intFromFloat(ball.pos.x), @intFromFloat(ball.pos.y),
    //         ball.radius, ball.color) for each ball.

    _ = gpa;
}
