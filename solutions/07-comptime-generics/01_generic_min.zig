//! Chapter 7 — Comptime & Generics
//! Task: Implement maxOf(comptime T: type, a: T, b: T) T and call it for
//!       integer and float types.
//! Run: zig run solutions/07-comptime-generics/01_generic_min.zig
//! Expected output:
//!   max(3,7)=7
//!   max(2.5,1.5)=2.5

const std = @import("std");

fn maxOf(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

pub fn main() void {
    const a = maxOf(i32, 3, 7);
    const b = maxOf(f64, 2.5, 1.5);
    std.debug.print("max(3,7)={d}\n", .{a});
    std.debug.print("max(2.5,1.5)={d}\n", .{b});
}
