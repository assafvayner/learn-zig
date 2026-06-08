//! Chapter 3 — Arrays, Slices & Strings
//! Task: reverse the bytes of "zig" and print the result.
//! Run: zig run solutions/03-arrays-slices-strings/01_reverse.zig
//! Expected output:
//!   giz

const std = @import("std");

pub fn main() void {
    const s = "zig";
    var buf = s.*;
    std.mem.reverse(u8, &buf);
    std.debug.print("{s}\n", .{buf});
}
