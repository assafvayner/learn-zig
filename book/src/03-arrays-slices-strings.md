# Arrays, Slices & Strings

## Arrays

An array `[N]T` is a value type with a compile-time-fixed length. The length is part of the type: `[3]u8` and `[4]u8` are distinct types.

```zig
const digits = [5]u8{ 1, 2, 3, 4, 5 };
const inferred = [_]u8{ 1, 2, 3 }; // length inferred as 3
```

Arrays live on the stack (or in static memory for constants). Passing an array to a function copies it unless you pass a pointer or slice.

## Slices

A slice `[]T` is a fat pointer: a runtime `ptr` + `len`. It does not own memory; it is a view into an array, another slice, or heap memory.

```zig
var arr = [_]u32{ 10, 20, 30, 40 };
const s: []u32 = arr[1..3]; // len == 2, points at 20, 30
const all: []u32 = arr[0..]; // entire array as a slice
```

`[]T` is mutable; `[]const T` is read-only. You can only take a mutable slice of a `var` array.

A mutable uninitialized buffer:

```zig
var buf: [64]u8 = undefined;
```

## Strings

There is no dedicated string type. A string literal `"zig"` has type `*const [3:0]u8` — a pointer to a null-terminated array — and coerces freely to `[]const u8`. All string-handling functions work on `[]const u8`.

```zig
const greeting: []const u8 = "hello";
std.debug.print("{s}\n", .{greeting});
```

Indexing a `[]const u8` yields bytes (`u8`), not Unicode codepoints — Zig strings are raw UTF-8.

## Pointer kinds

| Type | Meaning |
|------|---------|
| `*T` | single-item pointer |
| `*const T` | single-item, read-only |
| `[*]T` | many-item pointer (no length) |
| `[:0]u8` | sentinel-terminated slice (e.g. C strings) |

`[*]T` is unsafe without a length; prefer slices. `[:0]u8` guarantees a null byte past the last element.

Take an address with `&`:

```zig
var x: u32 = 7;
const p: *u32 = &x;
p.* = 8;
```

## std.mem helpers

```zig
// Iterate words (skips consecutive delimiters)
var it = std.mem.tokenizeScalar(u8, "a  b  c", ' ');
while (it.next()) |word| { ... }

// Iterate fields (empty tokens between consecutive delimiters)
var it2 = std.mem.splitScalar(u8, "a,,b", ',');

// Split on ANY byte in a delimiter set (whitespace + punctuation, etc.)
var it3 = std.mem.tokenizeAny(u8, "a, b;c", " ,;");

// Equality
std.mem.eql(u8, "zig", "zig") // true

// Lexicographic order (handy for sort tie-breaks)
std.mem.lessThan(u8, "abc", "abd") // true

// Search
std.mem.indexOfScalar(u8, s, ':') // ?usize

// Prefix check
std.mem.startsWith(u8, s, "http")

// Trim whitespace
const trimmed = std.mem.trim(u8, "  hi  ", " ");

// In-place reverse (requires mutable slice)
std.mem.reverse(u8, mutable_slice);

// Copy bytes
std.mem.copyForwards(u8, dst, src);
```

These are a slice of `std.mem` — browse the [official `std.mem` docs](https://ziglang.org/documentation/0.16.0/std/#std.mem) for the rest. Two that come back in later chapters: [`tokenizeAny`](https://ziglang.org/documentation/0.16.0/std/#std.mem.tokenizeAny) (chapter 11) and [`lessThan`](https://ziglang.org/documentation/0.16.0/std/#std.mem.lessThan) (sort tie-breaks in chapters 6 and 11).

## std.ascii helpers

```zig
std.ascii.toLower('A')       // 'a'
std.ascii.isAlphabetic('z')  // true
std.ascii.isDigit('3')       // true
```

## Copying a literal into a mutable array

String literals are immutable. To get a mutable copy:

```zig
var buf = "zig".*;        // [3:0]u8 — value copy via .*
var buf2: [3]u8 = undefined;
std.mem.copyForwards(u8, &buf2, "zig");
```

## Exercises

- **01_reverse** — reverse `"zig"` byte-by-byte and print `giz`.
- **02_word_count** — count words in a sentence with `tokenizeScalar`.
- **03_palindrome** — case-insensitive palindrome check using `std.ascii.toLower`.
- **04_caesar** — Caesar cipher shift by 3, wrapping within letter case.
