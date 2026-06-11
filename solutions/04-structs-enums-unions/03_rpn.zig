//! Chapter 4 — Structs, Enums & Unions
//! Task: evaluate a reverse-Polish expression using an Op enum with a method,
//! a Token tagged union, and a Stack struct with pointer-receiver methods.
//! Run: zig run solutions/04-structs-enums-unions/03_rpn.zig
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
        return switch (self) {
            .add => a + b,
            .sub => a - b,
            .mul => a * b,
            .div => @divTrunc(a, b),
        };
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
        self.items[self.top] = value;
        self.top += 1;
    }

    fn pop(self: *Stack) i64 {
        self.top -= 1;
        return self.items[self.top];
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
        switch (tok) {
            .number => |n| stack.push(n),
            .op => |op| {
                const b = stack.pop();
                const a = stack.pop();
                stack.push(op.apply(a, b));
            },
        }
    }

    const result = stack.pop();
    std.debug.print("result = {d}\n", .{result});
    std.debug.assert(result == 35);
}
