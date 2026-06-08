//! Chapter 7 — Comptime & Generics
//! Task: Build a Fibonacci table at compile time using a labeled block at file scope,
//!       then verify and print an entry at runtime.
//! Run: zig run solutions/07-comptime-generics/03_comptime_table.zig
//! Expected output:
//!   fib[10] = 55

const std = @import("std");

// File-scope constants are evaluated at compile time.
// Fill in the labeled block so that table holds the first 15 Fibonacci numbers.
const table: [15]u64 = blk: {
    var fib: [15]u64 = undefined;
    // TODO: seed fib[0] = 0 and fib[1] = 1
    // TODO: loop from index 2 to 14 and fill each entry
    _ = &fib; // remove once you fill in the TODOs above
    break :blk fib;
};

pub fn main() void {
    std.debug.assert(table[10] == 55);
    std.debug.print("fib[10] = {d}\n", .{table[10]});
}
