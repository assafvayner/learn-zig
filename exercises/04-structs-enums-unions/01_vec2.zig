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
        _ = o;
        return self;
    }

    pub fn dot(self: Vec2, o: Vec2) f64 {
        // TODO: return the dot product of self and o
        _ = o;
        return self.x;
    }

    pub fn length(self: Vec2) f64 {
        // TODO: return the Euclidean length (hint: @sqrt)
        return self.x;
    }
};

pub fn main() void {
    const a = Vec2{ .x = 3, .y = 4 };
    const b = Vec2{ .x = 1, .y = 2 };
    const s = a.add(b);
    // TODO: print "a+b = (4.00, 6.00)" using {d:.2} for each component
    _ = s;
    // TODO: print "a·b = 11.00"
    // TODO: print "|a| = 5.00"
}
