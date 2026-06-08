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
            self.items[self.len] = v;
            self.len += 1;
        }

        fn pop(self: *Self) ?T {
            if (self.len == 0) return null;
            self.len -= 1;
            return self.items[self.len];
        }
    };
}

pub fn main() void {
    var s = Stack(i32, 8){};
    s.push(10);
    s.push(20);
    s.push(30);
    std.debug.print("{?d}\n", .{s.pop()});
    std.debug.print("{?d}\n", .{s.pop()});
    std.debug.print("{?d}\n", .{s.pop()});
}
