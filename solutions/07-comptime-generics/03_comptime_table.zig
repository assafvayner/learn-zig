//! Chapter 7 — Comptime & Generics
//! Task: Build a Fibonacci table at compile time using a labeled block at file scope,
//!       then verify and print an entry at runtime.
//! Run: zig run solutions/07-comptime-generics/03_comptime_table.zig
//! Expected output:
//!   fib[10] = 55

const std = @import("std");

const table: [15]u64 = blk: {
    var fib: [15]u64 = undefined;
    fib[0] = 0;
    fib[1] = 1;
    var i: usize = 2;
    while (i < 15) : (i += 1) {
        fib[i] = fib[i - 1] + fib[i - 2];
    }
    break :blk fib;
};

pub fn main() void {
    std.debug.assert(table[10] == 55);
    std.debug.print("fib[10] = {d}\n", .{table[10]});
}
