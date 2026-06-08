# Structs, Enums & Unions

## Structs

A struct is a named, ordered collection of fields. It is a value type: assigning or passing a struct copies all its fields.

```zig
const Vec2 = struct {
    x: f64,
    y: f64 = 0.0, // default field value
};

const v = Vec2{ .x = 1.0, .y = 2.0 };
const w: Vec2 = .{ .x = 3.0 }; // .y defaults to 0.0
```

When the type is already known from context (a return expression, a function argument, a variable with an explicit type), you can omit the type name and write `.{ .field = value }`.

### Methods

Methods are regular functions declared inside the struct body. The receiver is explicit and must be named:

```zig
const Vec2 = struct {
    x: f64,
    y: f64,

    // value receiver — self is a copy, mutation doesn't affect the caller
    pub fn add(self: Vec2, o: Vec2) Vec2 {
        return .{ .x = self.x + o.x, .y = self.y + o.y };
    }

    // pointer receiver — required to mutate the original
    pub fn scale(self: *Vec2, factor: f64) void {
        self.x *= factor;
        self.y *= factor;
    }
};
```

Call methods with `.` syntax: `v.add(w)`. Zig automatically takes the address when calling a pointer-receiver method on an addressable value.

### Anonymous structs and tuples

An anonymous struct has no name; its type is inferred from the literal:

```zig
const point = .{ .x = 1, .y = 2 }; // anonymous struct
const triple = .{ 10, "hi", true }; // tuple — fields accessed as triple[0], triple[1], …
```

Tuples are anonymous structs with no field names; fields are numbered starting at 0.

## Enums

An enum defines a set of named integer values. By default the backing integer is the smallest `u`-type that fits.

```zig
const Direction = enum { north, south, east, west };

const d = Direction.north;
const n: u2 = @intFromEnum(d);       // 0
const d2: Direction = @enumFromInt(1); // .south
```

Enums can have methods, just like structs. Use `@tagName(value)` to get the variant name as a `[]const u8`.

## Tagged Unions

A plain `union` stores one of several types in a shared memory region but does not track which variant is active. A **tagged union** (`union(enum)`) adds a hidden discriminant field so the active variant is always known and safe to read.

```zig
const Shape = union(enum) {
    circle: f64,                          // payload is the radius
    rect: struct { w: f64, h: f64 },      // payload is an anonymous struct
};
```

Construct a tagged union by naming the active field:

```zig
const c = Shape{ .circle = 2.0 };
const r: Shape = .{ .rect = .{ .w = 3, .h = 4 } };
```

### switch with payload capture

The standard way to consume a tagged union is `switch` with `|capture|`:

```zig
fn area(s: Shape) f64 {
    return switch (s) {
        .circle => |r| std.math.pi * r * r,
        .rect   => |d| d.w * d.h,
    };
}
```

The capture binds the payload of the active variant. For a pointer receiver use `|*ptr|` to get a mutable pointer to the payload. Every variant must be covered; a missing arm is a compile error.

## Exercises

- **01_vec2** — `Vec2` struct with `add`, `dot`, and `length` methods.
- **02_shape_area** — tagged union `Shape` with an `area` function using `switch` capture.
- **03_rpn** — RPN evaluator using a `[16]i64` array as a stack.
