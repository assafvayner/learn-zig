//! Chapter 2 — Errors & Optionals
//! Task: parse integers from strings, falling back to 0 on failure.
//! Run: zig run solutions/02-errors-optionals/02_parse_or_default.zig
//! Expected output:
//!   123
//!   0

const std = @import("std");

pub fn main() void {
    const good = "123";
    const bad = "oops";

    const a = std.fmt.parseInt(i32, good, 10) catch 0;
    const b = std.fmt.parseInt(i32, bad, 10) catch 0;

    std.debug.print("{d}\n", .{a});
    std.debug.print("{d}\n", .{b});
}
