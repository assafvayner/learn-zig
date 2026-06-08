//! wordfreq core logic: tokenize + count, merge per-file maps, collect and sort.
//!
//! Key-lifetime contract (you must honor this):
//!   * `countText` stores keys that point *into* the `text` buffer it is given.
//!     That buffer must outlive the returned map.
//!   * `mergeInto` should **dupe** every key into the destination allocator, so
//!     the merged map owns its keys and stays valid even after the source
//!     buffers (and source maps) are freed.
//!
//! Implement the function bodies. The tests at the bottom describe the exact
//! behavior expected; run `zig build test` until they pass.

const std = @import("std");

/// A word and how many times it occurred. `word` is borrowed; see `topN`.
pub const Count = struct {
    word: []const u8,
    count: u32,
};

/// A word -> frequency map.
pub const Counts = std.StringHashMap(u32);

/// Count word frequencies in `text`. A "word" is a maximal run of ASCII
/// alphanumeric characters; everything else separates words. Keys in the
/// returned map are slices into `text`, so `text` must outlive the map. Caller
/// owns the map and must `deinit` it.
pub fn countText(alloc: std.mem.Allocator, text: []const u8) !Counts {
    var counts = Counts.init(alloc);
    errdefer counts.deinit();

    // TODO: tokenize `text` (try std.mem.tokenizeAny on whitespace +
    // punctuation) and, for each word, getOrPut into `counts`, bumping the
    // value (start at 1 for a new key, +1 for an existing one).
    _ = text;

    return counts;
}

/// Add every entry of `src` into `dst`, duplicating keys with `dst`'s allocator
/// so `dst` owns them independently of `src`. Free the duped keys in
/// `deinitOwned`.
pub fn mergeInto(dst: *Counts, src: *const Counts) !void {
    // TODO: iterate `src`; for each entry getOrPut into `dst`. If found, add the
    // counts. If new, replace `gop.key_ptr.*` with `try dst.allocator.dupe(u8,
    // key)` so `dst` owns the key, then set the value.
    _ = dst;
    _ = src;
}

/// Free a map whose keys were allocated by `mergeInto` (owned keys), then the
/// map itself.
pub fn deinitOwned(map: *Counts) void {
    // TODO: iterate and `map.allocator.free` each key, then `map.deinit()`.
    _ = map;
}

fn moreFrequent(_: void, a: Count, b: Count) bool {
    // TODO: order by count descending; tie-break by word ascending
    // (std.mem.lessThan(u8, a.word, b.word)).
    _ = a;
    _ = b;
    return false;
}

/// Collect all entries of `map` into a freshly allocated, sorted slice (count
/// descending, then word ascending) and return the first `n` (or fewer). The
/// returned `Count.word` slices borrow `map`'s keys, so `map` must outlive the
/// result. Caller owns the slice and frees it with `alloc`.
pub fn topN(alloc: std.mem.Allocator, map: *const Counts, n: usize) ![]Count {
    // TODO:
    //   1. alloc a `[]Count` of length `map.count()`.
    //   2. fill it by iterating `map` (word = key_ptr.*, count = value_ptr.*).
    //   3. std.sort.pdq(Count, entries, {}, moreFrequent).
    //   4. return the first @min(n, len) entries (resize/dupe down to that len).
    _ = map;
    _ = n;
    return alloc.alloc(Count, 0);
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
