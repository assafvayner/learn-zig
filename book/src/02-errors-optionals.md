# Errors & Optionals

Zig has two distinct mechanisms for "something went wrong or missing": **[error unions](https://ziglang.org/documentation/0.16.0/#Error-Union-Type)** for failure, and **optionals** for absence. They are different types and serve different purposes.

---

## Error Unions

An error union `E!T` holds either a value of type `T` or an error from error set `E`. The inferred form `!T` lets the compiler collect errors automatically.

```zig
const MathError = error{ DivByZero, Overflow };

fn divide(a: i32, b: i32) MathError!i32 {
    if (b == 0) return error.DivByZero;
    return @divTrunc(a, b);
}
```

### Handling errors

**[`try`](https://ziglang.org/documentation/0.16.0/#try)** — propagates on error, unwraps on success. Requires the calling function to return `!T`.

```zig
const v = try divide(10, 2); // v is i32; propagates DivByZero upward
```

**[`catch`](https://ziglang.org/documentation/0.16.0/#catch)** — handle inline. The payload form `catch |e| { ... }` names the error.

```zig
const v = divide(10, 0) catch 0;           // default value
const v2 = divide(10, 0) catch |e| blk: { // inspect e
    log(e);
    break :blk -1;
};
```

**`if`/`else` capture** — branch on success or error:

```zig
if (divide(10, 0)) |result| {
    use(result);
} else |e| {
    std.debug.print("error: {}\n", .{e});
}
```

**[`errdefer`](https://ziglang.org/documentation/0.16.0/#errdefer)** — runs a cleanup expression only when the enclosing function returns an error, not on a normal return.

```zig
fn openAndProcess() !void {
    const file = try std.fs.cwd().openFile("x", .{});
    errdefer file.close(); // called only if we return an error below
    try process(file);
}
```

### Named vs. inferred error sets

`error{A, B}!T` is explicit. `!T` infers — the compiler merges all `return error.X` in the function body. Prefer inferred sets while prototyping; use named sets in public APIs so callers can exhaustively switch.

---

## Optionals

[`?T`](https://ziglang.org/documentation/0.16.0/#Optionals) holds either a value of type `T` or `null`. No error information, just presence vs. absence.

```zig
fn firstEven(items: []const u32) ?u32 {
    for (items) |v| {
        if (v % 2 == 0) return v;
    }
    return null;
}
```

### Unwrapping optionals

**`orelse`** — provide a default or execute a block:

```zig
const v = maybeVal orelse 0;
const v2 = maybeVal orelse {
    std.debug.print("none\n", .{});
    return;
};
```

**`.?`** — assert non-null, panic if null (use only when logically certain):

```zig
const v = maybeVal.?;
```

**`if` capture** — safe branching:

```zig
if (firstEven(items)) |v| {
    std.debug.print("found: {d}\n", .{v});
} else {
    std.debug.print("none\n", .{});
}
```

**`while` capture** — standard iterator pattern:

```zig
while (iter.next()) |item| {
    process(item);
}
```

---

## Absent vs. Failed

| | Type | Meaning |
|---|---|---|
| Optional | `?T` | value may not exist — no error |
| Error union | `!T` / `E!T` | operation may fail — carries an error |

Use `?T` when "no result" is a normal outcome (searching, parsing optional config). Use `!T` when failure indicates something unexpected or diagnosable (I/O, format errors, resource exhaustion).

---

## Exercises

- **`01_safe_divide.zig`** — implement `divide()` with `error{DivByZero}!i32`; handle both call sites in `main`.
- **`02_parse_or_default.zig`** — parse `"123"` and `"oops"` using `catch 0`.
- **`03_first_even.zig`** — implement `firstEven([]const u32) ?u32`; print results with `orelse`.
