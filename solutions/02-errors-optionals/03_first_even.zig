//! Chapter 2 — Errors & Optionals
//! Task: find the first even number in a slice, returning null if none.
//! Run: zig run solutions/02-errors-optionals/03_first_even.zig
//! Expected output:
//!   first even: 4
//!   first even: none

const std = @import("std");

fn firstEven(items: []const u32) ?u32 {
    for (items) |v| {
        if (v % 2 == 0) return v;
    }
    return null;
}

pub fn main() void {
    const has_even = &[_]u32{ 1, 3, 4, 7 };
    const no_even = &[_]u32{ 1, 3, 5 };

    // orelse provides a sentinel when null; we still want to print "none" for null,
    // so use if-capture for the no_even case and orelse for the has_even case.
    const a = firstEven(has_even) orelse {
        std.debug.print("first even: none\n", .{});
        return;
    };
    std.debug.print("first even: {d}\n", .{a});

    const b = firstEven(no_even) orelse {
        std.debug.print("first even: none\n", .{});
        return;
    };
    std.debug.print("first even: {d}\n", .{b});
}
