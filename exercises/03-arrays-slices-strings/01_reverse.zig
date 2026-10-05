//! Chapter 3 — Arrays, Slices & Strings
//! Task: reverse the bytes of "zig" and print the result.
//! Run: zig run exercises/03-arrays-slices-strings/01_reverse.zig
//! Expected output:
//!   giz

const std = @import("std");

pub fn main() void {
    const s = "zig";
    var buf = s.*; // make it var so you can reverse in place
    const len = s.len;
    // TODO: reverse buf in place and print it as a string
    var i: usize = 0;
    while (i < len / 2) : (i += 1) {
        const save = buf[i];
        buf[i] = buf[len - i - 1];
        buf[len - i - 1] = save;
    }
    std.debug.print("{s}\n", .{buf});
}
