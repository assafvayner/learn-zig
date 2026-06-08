//! Chapter 3 — Arrays, Slices & Strings
//! Task: count whitespace-separated words using std.mem.tokenizeScalar.
//! Run: zig run exercises/03-arrays-slices-strings/02_word_count.zig
//! Expected output:
//!   4

const std = @import("std");

pub fn main() void {
    const line = "the quick brown fox";
    // TODO: use std.mem.tokenizeScalar(u8, line, ' ') to iterate words,
    //       count them, print the count, and assert count == 4.
    _ = line;
}
