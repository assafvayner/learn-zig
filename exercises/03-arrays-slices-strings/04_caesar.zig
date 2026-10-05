//! Chapter 3 — Arrays, Slices & Strings
//! Task: Caesar-shift "Hello, Zig!" by 3, wrapping within each letter case.
//! Run: zig run exercises/03-arrays-slices-strings/04_caesar.zig
//! Expected output:
//!   Khoor, Clj!

const std = @import("std");

pub fn main() void {
    const msg = "Hello, Zig!";
    var buf: [msg.len]u8 = undefined;
    // TODO: iterate msg with index, shift each letter by 3 within its case
    //       ('a'..'z' or 'A'..'Z'), copy non-letters unchanged, then print buf.
    for (msg, 0..msg.len) |c, i| {
        const new_char = switch (c) {
            'a'...'w', 'A'...'W' => c + 3,
            'x'...'z', 'X'...'Z' => c + 3 - 26,
            else => c,
        };
        buf[i] = new_char;
    }
    std.debug.print("{s}\n", .{buf});
}
