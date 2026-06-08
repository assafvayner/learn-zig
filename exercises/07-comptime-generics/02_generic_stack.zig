//! Chapter 7 — Comptime & Generics
//! Task: Implement a generic fixed-capacity Stack using the fn-returns-type idiom.
//! Run: zig run solutions/07-comptime-generics/02_generic_stack.zig
//! Expected output:
//!   30
//!   20
//!   10

const std = @import("std");

fn Stack(comptime T: type, comptime cap: usize) type {
    return struct {
        items: [cap]T = undefined,
        len: usize = 0,

        const Self = @This();

        fn push(self: *Self, v: T) void {
            // TODO: store v at items[self.len] and increment len
            _ = self;
            _ = v;
        }

        fn pop(self: *Self) ?T {
            // TODO: return null if empty, otherwise decrement len and return the top item
            _ = self;
            return null;
        }
    };
}

pub fn main() void {
    var s = Stack(i32, 8){};
    s.push(10);
    s.push(20);
    s.push(30);
    // TODO: pop three times and print each with std.debug.print("{?d}\n", .{...})
}
