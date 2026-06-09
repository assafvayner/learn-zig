# Values, Types & Control Flow

## Sized integers and overflow traps

Every [integer type](https://ziglang.org/documentation/0.16.0/#Integers) carries its width and signedness in the name: `u8`, `i32`, `u64`, `usize`, `isize`. There is no implicit promotion. Integer overflow [**panics at runtime**](https://ziglang.org/documentation/0.16.0/#Integer-Overflow) in debug builds — unlike C's undefined behavior or Rust's `wrapping_add`. When you genuinely want [wrapping semantics](https://ziglang.org/documentation/0.16.0/#Wrapping-Operations), use the dedicated operators: `+%`, `-%`, `*%`. Casting uses `@intCast(x)` (traps if the value doesn't fit) or `@as(T, x)` (compile-time-checked coercion).

```zig
var x: u8 = 255;
x +%= 1; // 0 — wrapping add, no panic
```

## `const` vs `var`

`const` binds a name to a value that never changes; `var` is mutable. Zig enforces this strictly — mutating a `const` is a compile error. Prefer `const` by default; the compiler will tell you when you need `var`.

```zig
const limit: u32 = 100;
var count: u32 = 0;
count += 1;
```

## `if`

No parentheses around the condition. There is no implicit boolean coercion — the condition must be `bool`.

```zig
if (x > 0) {
    std.debug.print("positive\n", .{});
} else if (x < 0) {
    std.debug.print("negative\n", .{});
} else {
    std.debug.print("zero\n", .{});
}
```

`if` is also an expression: `const sign: i32 = if (x >= 0) 1 else -1;`

## `while`

```zig
var i: u32 = 0;
while (i < 10) : (i += 1) {
    std.debug.print("{d}\n", .{i});
}
```

The `continue expression` (`: (i += 1)`) runs after every iteration including after a `continue` statement — a common gotcha if you're used to manually incrementing inside the body.

## `for`

Two forms:

**Range** — `for (start..end) |i| {}` yields `usize` values from `start` up to but not including `end`:

```zig
for (0..5) |i| {
    std.debug.print("{d}\n", .{i});
}
```

**Slice with index** — iterate items and positions in one shot:

```zig
const words = [_][]const u8{ "hello", "world" };
for (words, 0..) |w, i| {
    std.debug.print("{d}: {s}\n", .{ i, w });
}
```

## `switch`

[`switch`](https://ziglang.org/documentation/0.16.0/#switch) is exhaustive — the compiler rejects unhandled cases. Use `else` to cover a default. Ranges use `...` (three dots, inclusive on both ends). Multiple values share a branch with commas. `switch` is an expression.

```zig
const label = switch (score) {
    90...100 => "A",
    80...89  => "B",
    70...79  => "C",
    0...69   => "D",
    else     => unreachable,
};
```

For a negative lower bound on a signed integer, use `std.math.minInt(T)` as the start of the range:

```zig
switch (t) {
    std.math.minInt(i32)...-1 => "negative",
    0                         => "zero",
    1...std.math.maxInt(i32)  => "positive",
}
```

## Labeled loops and blocks

Any loop or block can carry a label. `break :label` exits the labeled construct; `continue :label` jumps to the next iteration of a labeled loop. Labeled blocks are also expressions — `break :blk value` returns `value` from the block:

```zig
const result = blk: {
    const a = expensive();
    if (a > 10) break :blk a * 2;
    break :blk a;
};

outer: for (0..5) |i| {
    for (0..5) |j| {
        if (i + j == 6) break :outer;
    }
}
```

## `defer`

[`defer`](https://ziglang.org/documentation/0.16.0/#defer) schedules a statement to run when the enclosing scope exits, regardless of how (normal return, early return, error). Multiple `defer`s in the same scope execute in **LIFO** order — last registered, first run.

```zig
{
    const f = openFile();
    defer closeFile(f);
    // use f — closeFile runs when the block exits
}
```

This is Zig's primary resource-cleanup mechanism; there is no RAII, no destructors.

## Exercises

- `01_fizzbuzz.zig` — print 1..=20, with `Fizz`/`Buzz`/`FizzBuzz` for multiples of 3/5/both.
- `02_classify.zig` — label a list of temperatures using a range `switch`.
- `03_collatz.zig` — count the Collatz steps from 27 (and assert it reaches 1 in 111).

Run each with `zig run exercises/01-basics/<file>`.
