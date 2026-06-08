//! Chapter 6 — Data Structures & the Standard Library
//! Exercise 02: Word frequency with StringHashMap, sorted output
//! Run: zig run solutions/06-data-structures-std/02_word_freq.zig
//! Expected output:
//!   the: 3
//!   cat: 2
//!   mat: 1
//!   on: 1
//!   sat: 1

const std = @import("std");

const Entry = struct { word: []const u8, count: u32 };

fn entryLt(_: void, a: Entry, b: Entry) bool {
    if (a.count != b.count) return a.count > b.count; // descending count
    return std.mem.lessThan(u8, a.word, b.word); // ascending word
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const text = "the cat sat on the mat the cat";

    var map = std.StringHashMap(u32).init(alloc);
    defer map.deinit();

    var it = std.mem.tokenizeScalar(u8, text, ' ');
    while (it.next()) |word| {
        const gop = try map.getOrPut(word);
        if (!gop.found_existing) gop.value_ptr.* = 0;
        gop.value_ptr.* += 1;
    }

    var entries = std.ArrayList(Entry).empty;
    defer entries.deinit(alloc);

    var mit = map.iterator();
    while (mit.next()) |e| {
        try entries.append(alloc, .{ .word = e.key_ptr.*, .count = e.value_ptr.* });
    }

    std.sort.pdq(Entry, entries.items, {}, entryLt);

    for (entries.items) |e| {
        std.debug.print("{s}: {d}\n", .{ e.word, e.count });
    }
}
