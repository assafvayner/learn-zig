//! Chapter 8 — Multi-file Programs & the Build System
//! Library module: text statistics. Only `pub` declarations are visible to importers.

const std = @import("std");

/// Count whitespace-separated tokens (split on the space character).
pub fn wordCount(s: []const u8) usize {
    var it = std.mem.tokenizeScalar(u8, s, ' ');
    var n: usize = 0;
    while (it.next()) |_| n += 1;
    return n;
}

/// Count the number of bytes in the slice.
pub fn charCount(s: []const u8) usize {
    return s.len;
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
