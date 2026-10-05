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

fn entry_sort_fn(ctx: void, e1: Entry, e2: Entry) bool {
    _ = ctx;
    if (e1.count > e2.count) {
        return true;
    } else if (e2.count > e1.count) {
        return false;
    }
    return std.mem.lessThan(u8, e1.word, e2.word);
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const text = "the cat sat on the mat the cat";

    var map = std.StringHashMap(u32).init(alloc);
    defer map.deinit();

    // TODO: tokenize `text` on ' ' with std.mem.tokenizeScalar and count each word
    //       using map.getOrPut
    var it = std.mem.tokenizeScalar(u8, text, ' ');
    while (it.next()) |word| {
        if (map.getEntry(word)) |e| {
            e.value_ptr.* += 1;
        } else {
            try map.put(word, 1);
        }
    }

    // TODO: collect map entries into an ArrayList(Entry), sort descending by count
    //       then ascending by word (tie-break with std.mem.lessThan, see Ch3),
    //       and print each "word: count"
    var list: std.ArrayList(Entry) = .empty;
    defer list.deinit(alloc);

    var map_it = map.iterator();
    while (map_it.next()) |e| {
        try list.append(alloc, Entry{ .word = e.key_ptr.*, .count = e.value_ptr.* });
    }

    std.sort.pdq(Entry, list.items, {}, entry_sort_fn);

    for (list.items) |e| {
        std.debug.print("{s}: {d}\n", .{ e.word, e.count });
    }
}
