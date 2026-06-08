//! Chapter 4 — Structs, Enums & Unions
//! Task: evaluate a reverse-Polish expression using a fixed array as a stack.
//! Run: zig run solutions/04-structs-enums-unions/03_rpn.zig
//! Expected output:
//!   result = 35

const std = @import("std");

pub fn main() !void {
    const tokens = [_][]const u8{ "3", "4", "+", "5", "*" };
    var stack: [16]i64 = undefined;
    var top: usize = 0;

    for (tokens) |tok| {
        if (tok.len == 1 and (tok[0] == '+' or tok[0] == '-' or tok[0] == '*' or tok[0] == '/')) {
            const b = stack[top - 1];
            const a = stack[top - 2];
            top -= 2;
            const result = switch (tok[0]) {
                '+' => a + b,
                '-' => a - b,
                '*' => a * b,
                '/' => @divTrunc(a, b),
                else => unreachable,
            };
            stack[top] = result;
            top += 1;
        } else {
            stack[top] = try std.fmt.parseInt(i64, tok, 10);
            top += 1;
        }
    }

    const result = stack[top - 1];
    std.debug.print("result = {d}\n", .{result});
    std.debug.assert(result == 35);
}
