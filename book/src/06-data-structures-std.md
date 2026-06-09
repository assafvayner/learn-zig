# Data Structures & the Standard Library

## ArrayList

`std.ArrayList(T)` is **unmanaged**: it holds no allocator internally. Every method that may allocate takes an `Allocator` argument. This keeps the struct small and makes allocator choice explicit at each call site.

```zig
var gpa: std.heap.DebugAllocator(.{}) = .init;
defer _ = gpa.deinit();
const alloc = gpa.allocator();

var list: std.ArrayList(u32) = .empty;
defer list.deinit(alloc);

try list.append(alloc, 42);
try list.appendSlice(alloc, &[_]u32{ 1, 2, 3 });

std.debug.print("{any}\n", .{list.items}); // items is []T — current contents

const last: ?u32 = list.pop();   // returns ?T; null if empty
const owned = try list.toOwnedSlice(alloc); // caller now owns the slice; list is left empty
defer alloc.free(owned);
```

The `.empty` sentinel initializes a zero-capacity list without allocating. Compare with `std.ArrayListUnmanaged` — that's a type alias; `std.ArrayList` is the same thing.

## HashMap

`std.StringHashMap(V)` and `std.AutoHashMap(K, V)` are **managed**: they store an allocator and you call `init(alloc)` once.

```zig
var map = std.StringHashMap(u32).init(alloc);
defer map.deinit();

try map.put("hits", 1);
const v: ?u32 = map.get("hits"); // returns optional

// Upsert pattern — one lookup instead of get + put:
const gop = try map.getOrPut("hits");
if (!gop.found_existing) gop.value_ptr.* = 0;
gop.value_ptr.* += 1;
```

Use `std.AutoHashMap` for integer, enum, or other non-string keys; it derives the hash automatically.

### Iteration order is unspecified

The hash map does not preserve insertion order. Iterate the entries with `map.iterator()`:

```zig
var it = map.iterator();
while (it.next()) |e| {
    // e.key_ptr.*  e.value_ptr.*
}
```

Each entry exposes `key_ptr` and `value_ptr`. For deterministic output, copy the entries into a slice and sort it with `std.sort.pdq` (see the next section) — exactly what exercise 02 does. `map.count()` returns the number of entries.

## Sorting

`std.sort.pdq` is the general-purpose sort (pattern-defeating quicksort). Signature:

```zig
std.sort.pdq(T, slice, context, compareFn)
```

Built-in comparators for ordered types:

```zig
std.sort.pdq(i32, &nums, {}, std.sort.asc(i32));
std.sort.pdq(i32, &nums, {}, std.sort.desc(i32));
```

Custom comparator — receives `context` as first argument:

```zig
fn byCountDesc(ctx: void, a: Entry, b: Entry) bool {
    _ = ctx;
    return a.count > b.count;
}
std.sort.pdq(Entry, entries, {}, byCountDesc);
```

The sort operates on a slice (`[]T`), so pass `&array` to sort an array in place.

## Tokenizing strings

`std.mem.tokenizeScalar` splits on a single delimiter byte and skips consecutive delimiters:

```zig
var it = std.mem.tokenizeScalar(u8, "the cat sat", ' ');
while (it.next()) |word| {
    // word is []const u8
}
```

## JSON

`std.json.parseFromSlice` parses JSON bytes into a Zig struct. The returned `Parsed(T)` owns any heap allocations (strings, nested structs); call `.deinit()` to free them.

```zig
const Info = struct { name: []const u8, year: u32 };

const parsed = try std.json.parseFromSlice(Info, alloc, text, .{});
defer parsed.deinit();

std.debug.print("{s} {d}\n", .{ parsed.value.name, parsed.value.year });
```

Field names must match JSON keys. Unknown keys are silently ignored by default; pass `.{ .ignore_unknown_fields = false }` to make them errors.

## Exercises

- **01_arraylist** — collect the squares of 1..=5 into an ArrayList and print with `{any}`.
- **02_word_freq** — count word frequencies with `StringHashMap`, then print sorted by count descending, word ascending.
- **03_sort** — sort `[_]i32{ 5, 3, 8, 1, 9, 2 }` descending and print.
- **04_json** — parse `{"name":"zig","year":2026}` into a struct and print the fields.
