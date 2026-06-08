//! Chapter 4 — Structs, Enums & Unions
//! Task: define a tagged union Shape and an area function using switch with captures.
//! Run: zig run solutions/04-structs-enums-unions/02_shape_area.zig
//! Expected output:
//!   circle area = 12.57
//!   rect area   = 12.00

const std = @import("std");

const Shape = union(enum) {
    circle: f64,
    rect: struct { w: f64, h: f64 },
};

fn area(s: Shape) f64 {
    return switch (s) {
        .circle => |r| std.math.pi * r * r,
        .rect => |d| d.w * d.h,
    };
}

pub fn main() void {
    const c = Shape{ .circle = 2.0 };
    const r = Shape{ .rect = .{ .w = 3, .h = 4 } };
    std.debug.print("circle area = {d:.2}\n", .{area(c)});
    std.debug.print("rect area   = {d:.2}\n", .{area(r)});
}
