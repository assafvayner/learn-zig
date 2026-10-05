//! Chapter 7 — Comptime & Generics
//! Task: Implement maxOf(comptime T: type, a: T, b: T) T and call it for
//!       integer and float types.
//! Run: zig run exercises/07-comptime-generics/01_generic_min.zig
//! Expected output:
//!   max(3,7)=7
//!   max(2.5,1.5)=2.5

const std = @import("std");

fn maxOf(comptime T: type, a: T, b: T) T {
    // TODO: return the larger of a and b
    if (a >= b) {
        return a;
    }
    return b;
}

pub fn main() void {
    // TODO: call maxOf(i32, 3, 7) and maxOf(f64, 2.5, 1.5)
    std.debug.print("{d}\n", .{maxOf(i32, 3, 7)});
    // TODO: print each result with std.debug.print
    std.debug.print("{d:.1}\n", .{maxOf(f64, 2.5, 1.5)});
}
