# Comptime & Generics

Zig has no separate generics syntax. Generics are just functions and values evaluated at compile time. The keyword [`comptime`](https://ziglang.org/documentation/0.16.0/#comptime) marks a parameter, variable, or block as "must be known at compile time." Types are first-class values at comptime — you pass `i32` the same way you pass `42`.

---

## comptime parameters

Any function parameter declared `comptime` must be supplied with a compile-time-known value. The function is then specialized for that value, similar to a template instantiation.

```zig
fn maxOf(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

const x = maxOf(i32, 3, 7);     // x == 7
const y = maxOf(f64, 2.5, 1.5); // y == 2.5
```

`T` is of type `type` — a Zig built-in type whose values are other types. `a` and `b` depend on the comptime `T`, so the compiler generates a separate function body per `T`. There is no runtime overhead.

---

## Types as values

At comptime, types are ordinary values. You can store them in constants, pass them to functions, and return them. The intrinsics `@TypeOf(expr)`, [`@typeInfo`](https://ziglang.org/documentation/0.16.0/#typeInfo)`(T)`, and [`@This()`](https://ziglang.org/documentation/0.16.0/#This) operate on them.

```zig
const T = i32;
const U = @TypeOf(@as(T, 0)); // U == i32
```

`@typeInfo(T)` returns a `std.builtin.Type` tagged union that lets you inspect whether `T` is an integer, struct, enum, etc. This is how the standard library implements `std.fmt` and `std.mem.eql`.

---

## Generic containers: fn returns type

The canonical Zig idiom for a [generic container](https://ziglang.org/documentation/0.16.0/#Generic-Data-Structures) is a function that takes comptime parameters and returns an anonymous `struct` type. The returned type is then used as a normal type.

```zig
fn Stack(comptime T: type, comptime cap: usize) type {
    return struct {
        items: [cap]T = undefined,
        len: usize = 0,

        const Self = @This();

        fn push(self: *Self, v: T) void {
            self.items[self.len] = v;
            self.len += 1;
        }

        fn pop(self: *Self) ?T {
            if (self.len == 0) {
                return null;
            }
            self.len -= 1;
            return self.items[self.len];
        }
    };
}

var s = Stack(i32, 8){};
s.push(10);
_ = s.pop(); // ?i32
```

`@This()` inside the returned struct refers to the anonymous struct type itself — the only way to name it, since it has no declared name.

Every distinct combination of comptime arguments produces a distinct type: `Stack(i32, 8)` and `Stack(u8, 16)` are different types with no shared identity.

---

## Comptime blocks

A labeled block that initializes a file-scope `const` (or one placed inside a `comptime { }` block) is evaluated entirely at compile time — it is the surrounding context, not the `blk:` label, that forces comptime evaluation. File-scope `const` initializers are themselves comptime contexts. This is how you build lookup tables, precompute constants, or validate invariants without runtime cost.

```zig
const table: [15]u64 = blk: {
    var fib: [15]u64 = undefined;
    fib[0] = 0;
    fib[1] = 1;
    var i: usize = 2;
    while (i < 15) : (i += 1) {
        fib[i] = fib[i - 1] + fib[i - 2];
    }
    break :blk fib;
};
```

`table` is embedded in the binary as a constant. There is no runtime computation.

Inside a comptime context you can use [`@compileError`](https://ziglang.org/documentation/0.16.0/#compileError)`("msg")` to emit a compile-time diagnostic — useful for enforcing constraints on type parameters.

```zig
fn onlyInts(comptime T: type) void {
    comptime {
        if (@typeInfo(T) != .int) {
            @compileError("T must be an integer type");
        }
    }
}
```

---

## inline for

[`inline for`](https://ziglang.org/documentation/0.16.0/#inline-for) unrolls the loop at compile time. Each iteration is a separate copy in the compiled output, with the loop variable known at comptime. Use it when iterating over a comptime-known range or tuple.

```zig
inline for (0..4) |i| {
    std.debug.print("{d}\n", .{i}); // four separate print calls in the binary
}
```

---

## Exercises

- **`01_generic_min.zig`** — implement `maxOf(comptime T: type, a: T, b: T) T`; call it for `i32` and `f64`.
- **`02_generic_stack.zig`** — implement `Stack(comptime T: type, comptime cap: usize) type` with `push` and `pop`; push 10/20/30, pop and print all three.
- **`03_comptime_table.zig`** — fill a `[15]u64` Fibonacci table in a compile-time labeled block; assert and print `table[10] == 55`.
