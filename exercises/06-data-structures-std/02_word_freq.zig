//! Chapter 6 — Data Structures & the Standard Library
//! Exercise 02: Word frequency with StringHashMap, sorted output
//! Run: zig run exercises/06-data-structures-std/02_word_freq.zig
//! Expected output:
//!   the: 3
//!   cat: 2
//!   mat: 1
//!   on: 1
//!   sat: 1

const std = @import("std");

const Entry = struct { word: []const u8, count: u32 };

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const text = "the cat sat on the mat the cat";

    var map = std.StringHashMap(u32).init(alloc);
    defer map.deinit();

    // TODO: tokenize `text` on ' ' with std.mem.tokenizeScalar and count each word
    //       using map.getOrPut
    _ = text;

    // TODO: collect map entries into an ArrayList(Entry), sort descending by count
    //       then ascending by word (tie-break with std.mem.lessThan, see Ch3),
    //       and print each "word: count"
}
