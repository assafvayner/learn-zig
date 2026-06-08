//! Chapter 3 — Arrays, Slices & Strings
//! Task: Caesar-shift "Hello, Zig!" by 3, wrapping within each letter case.
//! Run: zig run solutions/03-arrays-slices-strings/04_caesar.zig
//! Expected output:
//!   Khoor, Clj!

const std = @import("std");

pub fn main() void {
    const msg = "Hello, Zig!";
    var buf: [msg.len]u8 = undefined;
    for (msg, 0..) |c, i| {
        if (c >= 'a' and c <= 'z') {
            buf[i] = (c - 'a' + 3) % 26 + 'a';
        } else if (c >= 'A' and c <= 'Z') {
            buf[i] = (c - 'A' + 3) % 26 + 'A';
        } else {
            buf[i] = c;
        }
    }
    std.debug.print("{s}\n", .{buf});
}
