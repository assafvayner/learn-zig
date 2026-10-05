//! Chapter 4 — Structs, Enums & Unions
//! Task: define a Vec2 struct with add, dot, and length methods; exercise them in main.
//! Run: zig run exercises/04-structs-enums-unions/01_vec2.zig
//! Expected output:
//!   a+b = (4.00, 6.00)
//!   a·b = 11.00
//!   |a| = 5.00

const std = @import("std");

const Vec2 = struct {
    x: f64,
    y: f64,

    pub fn add(self: Vec2, o: Vec2) Vec2 {
        // TODO: return a new Vec2 whose components are the sums of self and o
        const x = self.x + o.x;
        const y = self.y + o.y;
        return Vec2{ .x = x, .y = y };
    }

    pub fn dot(self: Vec2, o: Vec2) f64 {
        // TODO: return the dot product of self and o
        return self.x * o.x + self.y * o.y;
    }

    pub fn length(self: Vec2) f64 {
        // TODO: return the Euclidean length (hint: @sqrt)
        return @sqrt(self.x * self.x + self.y * self.y);
    }
};

pub fn main() void {
    const a = Vec2{ .x = 3, .y = 4 };
    const b = Vec2{ .x = 1, .y = 2 };
    const s = a.add(b);
    // TODO: print "a+b = (4.00, 6.00)" using {d:.2} for each component
    std.debug.print("a+b = ({d:.2}, {d:.2})\n", .{ s.x, s.y });
    // TODO: print "a·b = 11.00"
    const dot = a.dot(b);
    std.debug.print("a·b = ({d:.2})\n", .{dot});
    // TODO: print "|a| = 5.00"
    const len = a.length();
    std.debug.print("|a| = {d:.2}\n", .{len});
}
