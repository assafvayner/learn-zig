//! Chapter 8 — Multi-file Programs & the Build System
//! Library module: text statistics. Only `pub` declarations are visible to importers.
//! Implement the two functions below so the `test` blocks pass (`zig build test`).

const std = @import("std");

/// Count whitespace-separated tokens (split on the space character).
pub fn wordCount(s: []const u8) usize {
    // TODO: tokenize `s` on the space character with std.mem.tokenizeScalar
    // and count how many tokens it yields.
    _ = s;
    return 0;
}

/// Count the number of bytes in the slice.
pub fn charCount(s: []const u8) usize {
    // TODO: return the byte length of `s`.
    _ = s;
    return 0;
}

test "wordCount counts space-separated tokens" {
    try std.testing.expectEqual(@as(usize, 4), wordCount("a b c d"));
    try std.testing.expectEqual(@as(usize, 7), wordCount("the quick brown fox the lazy dog"));
    try std.testing.expectEqual(@as(usize, 0), wordCount(""));
}

test "charCount returns the byte length" {
    try std.testing.expectEqual(@as(usize, 4), charCount("abcd"));
    try std.testing.expectEqual(@as(usize, 32), charCount("the quick brown fox the lazy dog"));
}
