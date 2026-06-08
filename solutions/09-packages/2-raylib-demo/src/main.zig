//! Chapter 9.2 — raylib-demo: a bouncing-balls window.
//!
//! A native dependency (raylib, a C library) combined with a pure-Zig one (clap).
//! clap parses the window/ball options; raylib opens the window and draws.
//!
//! Flags:  --count N (default 3), --width W (default 800), --height H (default 450)
//!
//! Build:  zig build              (the success criterion — links the raylib C library)
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

    // Parse the window/ball options with clap (reused from 9.1).
    const params = comptime clap.parseParamsComptime(
        \\-h, --help          Display this help and exit.
        \\-c, --count <usize> Number of balls (default 3).
        \\-W, --width <i32>   Window width (default 800).
        \\-H, --height <i32>  Window height (default 450).
        \\
    );
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, init.minimal.args, .{
        .diagnostic = &diag,
        .allocator = gpa,
    }) catch |err| {
        try diag.reportToFile(init.io, .stderr(), err);
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) {
        std.debug.print("usage: balls [--count N] [--width W] [--height H]\n", .{});
        return;
    }

    const count = @max(res.args.count orelse 3, 1);
    const width = res.args.width orelse 800;
    const height = res.args.height orelse 450;

    // Build `count` balls with deterministic pseudo-random starting state.
    const balls = try gpa.alloc(Ball, count);
    defer gpa.free(balls);

    var prng = std.Random.DefaultPrng.init(0x1234_5678);
    const rand = prng.random();
    const palette = [_]rl.Color{ .red, .blue, .green, .gold, .maroon, .violet, .orange, .sky_blue };
    const w: f32 = @floatFromInt(width);
    const h: f32 = @floatFromInt(height);
    for (balls, 0..) |*ball, i| {
        const radius = rand.float(f32) * 20 + 10; // 10..30
        ball.* = .{
            .pos = .{
                .x = rand.float(f32) * (w - 2 * radius) + radius,
                .y = rand.float(f32) * (h - 2 * radius) + radius,
            },
            .vel = .{
                .x = (rand.float(f32) - 0.5) * 8,
                .y = (rand.float(f32) - 0.5) * 8,
            },
            .radius = radius,
            .color = palette[i % palette.len],
        };
    }

    // raylib drives its own I/O, so no `init` plumbing is needed past this point.
    rl.initWindow(width, height, "bouncing balls");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        for (balls) |*ball| {
            ball.pos.x += ball.vel.x;
            ball.pos.y += ball.vel.y;
            if (ball.pos.x - ball.radius < 0 or ball.pos.x + ball.radius > w) ball.vel.x = -ball.vel.x;
            if (ball.pos.y - ball.radius < 0 or ball.pos.y + ball.radius > h) ball.vel.y = -ball.vel.y;
        }

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.ray_white);
        for (balls) |ball| {
            rl.drawCircle(@intFromFloat(ball.pos.x), @intFromFloat(ball.pos.y), ball.radius, ball.color);
        }
    }
}
