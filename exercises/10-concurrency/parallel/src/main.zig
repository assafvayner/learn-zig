//! Chapter 10 — Concurrency demo.
//! Runs the three parallel routines and prints their results.
//! Implement the functions in `parallel.zig` so the output matches the README.

const std = @import("std");
const parallel = @import("parallel.zig");

pub fn main() void {
    var data: [1000]u64 = undefined;
    for (&data, 0..) |*v, i| v.* = @intCast(i);

    const sum = parallel.parallelSum(&data);
    std.debug.print("parallel sum 0..999 = {d}\n", .{sum});

    const counter = parallel.atomicCounter(8, 1000);
    std.debug.print("atomic counter = {d}\n", .{counter});

    var out: [1000]u64 = undefined;
    parallel.parallelMap(&data, &out);
    // TODO: once parallelMap is implemented, out[9] should be 81.
    std.debug.print("parallel_map[9] = {d}\n", .{out[9]});
}

// Pull the library tests into the exe's root module so `zig build test`
// (which tests `exe.root_module`) exercises them.
comptime {
    _ = parallel;
}
