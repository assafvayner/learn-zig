//! Chapter 3 — Arrays, Slices & Strings
//! Task: Caesar-shift "Hello, Zig!" by 3, wrapping within each letter case.
//! Run: zig run solutions/03-arrays-slices-strings/04_caesar.zig
//! Expected output:
//!   Khoor, Clj!

const std = @import("std");

pub fn main() void {
    const msg = "Hello, Zig!";
    var buf: [msg.len]u8 = undefined;
    // TODO: iterate msg with index, shift each letter by 3 within its case
    //       ('a'..'z' or 'A'..'Z'), copy non-letters unchanged, then print buf.
    _ = &buf;
}
