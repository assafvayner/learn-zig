//! Chapter 4 — Structs, Enums & Unions
//! Task: evaluate a reverse-Polish expression using a fixed array as a stack.
//! Run: zig run exercises/04-structs-enums-unions/03_rpn.zig
//! Expected output:
//!   result = 35

const std = @import("std");

pub fn main() !void {
    const tokens = [_][]const u8{ "3", "4", "+", "5", "*" };
    var stack: [16]i64 = undefined;
    var top: usize = 0;

    // TODO: iterate over tokens.
    // Compare each token to the operators with std.mem.eql (from Ch3), e.g.
    // std.mem.eql(u8, tok, "+"). If it is one of + - * /, pop two values
    // (b = top-1, a = top-2), compute the result, and push it.
    // Otherwise parse the token as i64 with std.fmt.parseInt and push it.
    // Use @divTrunc for integer division.
    _ = &stack;
    _ = &top;
    for (tokens) |tok| {
        _ = tok;
    }

    const result = stack[top - 1];
    std.debug.print("result = {d}\n", .{result});
    std.debug.assert(result == 35);
}
