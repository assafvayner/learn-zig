//! Chapter 4 — Structs, Enums & Unions
//! Task: define a tagged union Shape and an area function using switch with captures.
//! Run: zig run exercises/04-structs-enums-unions/02_shape_area.zig
//! Expected output:
//!   circle area = 12.57
//!   rect area   = 12.00

const std = @import("std");

const Shape = union(enum) {
    circle: f64,
    rect: struct { w: f64, h: f64 },
};

fn area(s: Shape) f64 {
    // TODO: switch on s, capturing the payload of each variant, and return the area.
    // circle: π * r²  (use std.math.pi)
    // rect:   w * h
    _ = s;
    return 0;
}

pub fn main() void {
    const c = Shape{ .circle = 2.0 };
    const r = Shape{ .rect = .{ .w = 3, .h = 4 } };
    // TODO: print "circle area = {d:.2}" and "rect area   = {d:.2}"
    _ = c;
    _ = r;
}
