//! Chapter 4 — Structs, Enums & Unions
//! Task: evaluate a reverse-Polish expression using an Op enum with a method,
//! a Token tagged union, and a Stack struct with pointer-receiver methods.
//! Run: zig run exercises/04-structs-enums-unions/03_rpn.zig
//! Expected output:
//!   result = 35

const std = @import("std");

// In reverse-Polish notation, "3 4 + 5 *" means (3 + 4) * 5. Numbers are
// pushed onto a stack; an operator pops the top two values and pushes the
// result. A token is either a number or an operator — "one of several
// variants, each with its own payload" is exactly what a tagged union models.

const Op = enum {
    add,
    sub,
    mul,
    div,

    // Enums can have methods, just like structs.
    fn apply(self: Op, a: i64, b: i64) i64 {
        // TODO: switch on self and return a + b, a - b, a * b, or
        // @divTrunc(a, b) for the matching variant.
        _ = self;
        _ = a;
        _ = b;
        return 0;
    }
};

const Token = union(enum) {
    number: i64,
    op: Op,
};

const Stack = struct {
    items: [16]i64 = undefined,
    top: usize = 0, // default field value — Stack{} starts empty

    // Pointer receivers: push and pop must mutate the original, not a copy.
    fn push(self: *Stack, value: i64) void {
        // TODO: store value at self.top, then bump self.top.
        _ = self;
        _ = value;
    }

    fn pop(self: *Stack) i64 {
        // TODO: decrement self.top, then return the value that was on top.
        _ = self;
        return 0;
    }
};

pub fn main() void {
    // (3 + 4) * 5 in RPN. Each token names its active variant, just like
    // Shape{ .circle = 2.0 } in the chapter.
    const tokens = [_]Token{
        .{ .number = 3 },
        .{ .number = 4 },
        .{ .op = .add },
        .{ .number = 5 },
        .{ .op = .mul },
    };

    var stack = Stack{};

    for (tokens) |tok| {
        // TODO: switch on tok with payload capture:
        //   .number => |n|  push n
        //   .op     => |op| pop b, then pop a, then push op.apply(a, b)
        // (the value popped second is the left operand)
        _ = tok;
        _ = &stack;
    }

    const result = stack.pop();
    std.debug.print("result = {d}\n", .{result});
    std.debug.assert(result == 35);
}
