//! Chapter 3 — Arrays, Slices & Strings
//! Task: reverse the bytes of "zig" and print the result.
//! Run: zig run solutions/03-arrays-slices-strings/01_reverse.zig
//! Expected output:
//!   giz

const std = @import("std");

pub fn main() void {
    const s = "zig";
    var buf = s.*; // make it var so you can reverse in place
    // TODO: reverse buf in place and print it as a string
    _ = &buf;
}
