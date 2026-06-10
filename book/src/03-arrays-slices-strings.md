# Arrays, Slices & Strings

## Arrays

An [array](https://ziglang.org/documentation/0.16.0/#Arrays) `[N]T` is a value type with a compile-time-fixed length. The length is part of the type: `[3]u8` and `[4]u8` are distinct types.

```zig
const digits = [5]u8{ 1, 2, 3, 4, 5 };
const inferred = [_]u8{ 1, 2, 3 }; // length inferred as 3
```

Arrays live on the stack (or in static memory for constants). Passing an array to a function copies it unless you pass a [pointer](https://ziglang.org/documentation/0.16.0/#Pointers) or slice.

## Slices

A [slice](https://ziglang.org/documentation/0.16.0/#Slices) `[]T` is a fat pointer: a runtime `ptr` + `len`. It does not own memory; it is a view into an array, another slice, or heap memory.

```zig
var arr = [_]u32{ 10, 20, 30, 40 };
const s: []u32 = arr[1..3]; // len == 2, points at 20, 30
const all: []u32 = arr[0..]; // entire array as a slice
```

`[]T` is mutable; `[]const T` is read-only. You can only take a mutable slice of a `var` array. A `[]T` [coerces implicitly](https://ziglang.org/documentation/0.16.0/#Type-Coercion-Stricter-Qualification) to `[]const T` (adding `const` is always safe, the reverse is a compile error) — so take `[]const T` parameters in functions that only read.

A mutable uninitialized buffer:

```zig
var buf: [64]u8 = undefined;
```

## Strings

There is no dedicated string type. A [string literal](https://ziglang.org/documentation/0.16.0/#String-Literals-and-Unicode-Code-Point-Literals) `"zig"` has type `*const [3:0]u8` — a pointer to a null-terminated array — and coerces freely to `[]const u8`. All string-handling functions work on `[]const u8`.

```zig
const greeting: []const u8 = "hello";
std.debug.print("{s}\n", .{greeting});
```

Indexing a `[]const u8` yields bytes (`u8`), not Unicode codepoints — Zig strings are raw UTF-8.

### String length

A string's length is just the slice's `.len` field — no function call, no scan:

```zig
const greeting: []const u8 = "hello";
greeting.len; // 5
"zig".len;    // 3 — works on literals too; the 0 sentinel is not counted
```

Because strings are raw UTF-8, `.len` counts **bytes**, not characters: `"héllo".len` is `6` (the `é` takes two bytes). When you genuinely need the number of Unicode codepoints, use `std.unicode.utf8CountCodepoints("héllo")` — it returns `5` (and an error on invalid UTF-8). For a C-style many-item pointer with no length (`[*:0]const u8`, common at C boundaries), `std.mem.len(ptr)` scans to the 0 sentinel.

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

### Cutting strings: the tokenize/split family

Six functions cover every "cut this slice at delimiters" need, and the names compose from two choices. The **verb** decides what happens to empty pieces; the **suffix** decides what counts as a delimiter:

|                                    | `Scalar` — one element | `Any` — any element of a set | `Sequence` — an exact substring |
|------------------------------------|------------------------|------------------------------|---------------------------------|
| **`tokenize`** — never yields `""` | [`tokenizeScalar`](https://ziglang.org/documentation/0.16.0/std/#std.mem.tokenizeScalar) | [`tokenizeAny`](https://ziglang.org/documentation/0.16.0/std/#std.mem.tokenizeAny) | [`tokenizeSequence`](https://ziglang.org/documentation/0.16.0/std/#std.mem.tokenizeSequence) |
| **`split`** — keeps empty pieces   | [`splitScalar`](https://ziglang.org/documentation/0.16.0/std/#std.mem.splitScalar) | [`splitAny`](https://ziglang.org/documentation/0.16.0/std/#std.mem.splitAny) | [`splitSequence`](https://ziglang.org/documentation/0.16.0/std/#std.mem.splitSequence) |

`tokenize*` collapses runs of delimiters and ignores leading/trailing ones — right for whitespace-style parsing, where `"a  b"` is two words no matter how many spaces separate them. `split*` cuts at *every* delimiter, so consecutive delimiters produce empty slices — right for record formats like CSV, where `"a,,b"` has a genuinely empty middle field.

```zig
// tokenizeScalar: one byte; runs collapse, edges ignored -> "a", "b", "c"
var words = std.mem.tokenizeScalar(u8, "  a  b  c ", ' ');
while (words.next()) |word| { ... }

// splitScalar: every comma cuts; empties kept            -> "a", "", "b"
var fields = std.mem.splitScalar(u8, "a,,b", ',');

// tokenizeAny: ANY byte of the set is a delimiter        -> "a", "b", "c"
var loose = std.mem.tokenizeAny(u8, "a, b;c", " ,;");

// splitSequence: the WHOLE substring is one delimiter    -> "one", "two", "", "three"
var parts = std.mem.splitSequence(u8, "one=>two=>=>three", "=>");
```

All six return an iterator whose `next()` yields `?[]const u8` (`null` when exhausted). The iterators also support `peek()` (look at the next token without consuming it), `rest()` (everything not yet consumed, delimiters included), and `reset()` (start over). Every token is a slice *into the original buffer* — nothing is copied and nothing is allocated, which also means tokens are only valid as long as the input slice is.

The `u8` first argument is the element type: these functions are generic, so you can just as well tokenize a `[]const u32` on a `0` separator. `u8` is simply the common case for strings.

### Other common helpers

```zig
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
- **03_palindrome** — case-insensitive palindrome check using [`std.ascii`](https://ziglang.org/documentation/0.16.0/std/#std.ascii)`.toLower`.
- **04_caesar** — Caesar cipher shift by 3, wrapping within letter case.
