//! Chapter 3 — Arrays, Slices & Strings
//! Task: count whitespace-separated words using std.mem.tokenizeScalar.
//! Run: zig run solutions/03-arrays-slices-strings/02_word_count.zig
//! Expected output:
//!   4

const std = @import("std");

pub fn main() void {
    const line = "the quick brown fox";
    var iter = std.mem.tokenizeScalar(u8, line, ' ');
    var count: usize = 0;
    while (iter.next()) |_| {
        count += 1;
    }
    std.debug.print("{d}\n", .{count});
    std.debug.assert(count == 4);
}
