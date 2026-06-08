//! wordfreq core logic: tokenize + count, merge per-file maps, collect and sort.
//!
//! Key-lifetime contract:
//!   * `countText` stores keys that point *into* the `text` buffer it is given.
//!     That buffer must outlive the returned map.
//!   * `mergeInto` **dupes** every key into the destination allocator, so the
//!     merged map owns its keys and stays valid even after the source buffers
//!     (and source maps) are freed.

const std = @import("std");

/// A word and how many times it occurred. `word` is borrowed; see `topN`.
pub const Count = struct {
    word: []const u8,
    count: u32,
};

/// A word -> frequency map. Keys are `[]const u8` slices whose lifetime is
/// documented per producing function.
pub const Counts = std.StringHashMap(u32);

/// Count word frequencies in `text`. A "word" is a maximal run of ASCII
/// alphanumeric characters; everything else (spaces, punctuation, newlines)
/// separates words. Keys in the returned map are slices into `text`, so `text`
/// must outlive the map. Caller owns the map and must `deinit` it.
pub fn countText(alloc: std.mem.Allocator, text: []const u8) !Counts {
    var counts = Counts.init(alloc);
    errdefer counts.deinit();

    var it = std.mem.tokenizeAny(u8, text, " \t\r\n.,;:!?\"'()[]{}<>/\\|-_=+*&^%$#@~`");
    while (it.next()) |word| {
        const gop = try counts.getOrPut(word);
        if (gop.found_existing) {
            gop.value_ptr.* += 1;
        } else {
            gop.value_ptr.* = 1;
        }
    }
    return counts;
}

/// Add every entry of `src` into `dst`. Keys are duplicated with `dst`'s
/// backing allocator so `dst` owns its keys independently of `src` and of any
/// buffer `src`'s keys point into. Free the duped keys in `deinitOwned`.
pub fn mergeInto(dst: *Counts, src: *const Counts) !void {
    var it = src.iterator();
    while (it.next()) |entry| {
        const gop = try dst.getOrPut(entry.key_ptr.*);
        if (gop.found_existing) {
            gop.value_ptr.* += entry.value_ptr.*;
        } else {
            // New key: dst borrowed src's slice in getOrPut; replace it with a
            // copy dst owns, so dst stays valid after src is freed.
            gop.key_ptr.* = try dst.allocator.dupe(u8, entry.key_ptr.*);
            gop.value_ptr.* = entry.value_ptr.*;
        }
    }
}

/// Free a map whose keys were allocated by `mergeInto` (owned keys), then the
/// map itself.
pub fn deinitOwned(map: *Counts) void {
    var it = map.iterator();
    while (it.next()) |entry| map.allocator.free(entry.key_ptr.*);
    map.deinit();
}

fn moreFrequent(_: void, a: Count, b: Count) bool {
    if (a.count != b.count) return a.count > b.count; // count descending
    return std.mem.lessThan(u8, a.word, b.word); // tie-break: word ascending
}

/// Collect all entries of `map` into a freshly allocated, sorted slice (count
/// descending, then word ascending) and return the first `n` (or fewer). The
/// returned `Count.word` slices borrow `map`'s keys, so `map` must outlive the
/// result. Caller owns the slice and frees it with `alloc`.
pub fn topN(alloc: std.mem.Allocator, map: *const Counts, n: usize) ![]Count {
    var entries = try alloc.alloc(Count, map.count());
    errdefer alloc.free(entries);

    var i: usize = 0;
    var it = map.iterator();
    while (it.next()) |entry| : (i += 1) {
        entries[i] = .{ .word = entry.key_ptr.*, .count = entry.value_ptr.* };
    }

    std.sort.pdq(Count, entries, {}, moreFrequent);

    const keep = @min(n, entries.len);
    if (alloc.resize(entries, keep)) {
        return entries[0..keep];
    }
    // resize may decline to shrink in place; copy out and free the original.
    const out = try alloc.dupe(Count, entries[0..keep]);
    alloc.free(entries);
    return out;
}

const testing = std.testing;

test "countText counts words and is case-sensitive" {
    var m = try countText(testing.allocator, "the cat sat on the mat the cat");
    defer m.deinit();

    try testing.expectEqual(@as(?u32, 3), m.get("the"));
    try testing.expectEqual(@as(?u32, 2), m.get("cat"));
    try testing.expectEqual(@as(?u32, 1), m.get("sat"));
    try testing.expectEqual(@as(?u32, null), m.get("dog"));
}

test "countText splits on punctuation and whitespace" {
    var m = try countText(testing.allocator, "hello, world! hello\thello-world");
    defer m.deinit();

    try testing.expectEqual(@as(?u32, 3), m.get("hello"));
    try testing.expectEqual(@as(?u32, 2), m.get("world"));
}

test "mergeInto sums counts and owns its keys" {
    var a = try countText(testing.allocator, "zig zig rust");
    defer a.deinit();
    var b = try countText(testing.allocator, "zig rust go");
    defer b.deinit();

    var merged = Counts.init(testing.allocator);
    defer deinitOwned(&merged);
    try mergeInto(&merged, &a);
    try mergeInto(&merged, &b);

    try testing.expectEqual(@as(?u32, 3), merged.get("zig"));
    try testing.expectEqual(@as(?u32, 2), merged.get("rust"));
    try testing.expectEqual(@as(?u32, 1), merged.get("go"));
}

test "topN sorts by count desc then word asc" {
    var merged = Counts.init(testing.allocator);
    defer deinitOwned(&merged);
    var src = try countText(testing.allocator, "b b a a a c");
    defer src.deinit();
    try mergeInto(&merged, &src);

    const top = try topN(testing.allocator, &merged, 2);
    defer testing.allocator.free(top);

    try testing.expectEqual(@as(usize, 2), top.len);
    try testing.expectEqualStrings("a", top[0].word);
    try testing.expectEqual(@as(u32, 3), top[0].count);
    try testing.expectEqualStrings("b", top[1].word);
    try testing.expectEqual(@as(u32, 2), top[1].count);
}

test "topN tie-breaks equal counts by word ascending" {
    var merged = Counts.init(testing.allocator);
    defer deinitOwned(&merged);
    var src = try countText(testing.allocator, "delta charlie bravo alpha");
    defer src.deinit();
    try mergeInto(&merged, &src);

    const top = try topN(testing.allocator, &merged, 10);
    defer testing.allocator.free(top);

    try testing.expectEqual(@as(usize, 4), top.len);
    try testing.expectEqualStrings("alpha", top[0].word);
    try testing.expectEqualStrings("bravo", top[1].word);
    try testing.expectEqualStrings("charlie", top[2].word);
    try testing.expectEqualStrings("delta", top[3].word);
}

test "topN caps at requested count" {
    var src = try countText(testing.allocator, "a b c d e");
    defer src.deinit();
    var merged = Counts.init(testing.allocator);
    defer deinitOwned(&merged);
    try mergeInto(&merged, &src);

    const top = try topN(testing.allocator, &merged, 3);
    defer testing.allocator.free(top);
    try testing.expectEqual(@as(usize, 3), top.len);
}
