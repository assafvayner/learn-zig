//! Chapter 2 — Errors & Optionals
//! Task: implement divide() that returns error.DivByZero when b==0.
//! Run: zig run solutions/02-errors-optionals/01_safe_divide.zig
//! Expected output:
//!   10 / 2 = 5
//!   cannot divide by zero

const std = @import("std");

fn divide(a: i32, b: i32) error{DivByZero}!i32 {
    if (b == 0) return error.DivByZero;
    return @divTrunc(a, b);
}

pub fn main() void {
    const result = divide(10, 2) catch unreachable;
    std.debug.print("10 / 2 = {d}\n", .{result});

    if (divide(10, 0)) |v| {
        std.debug.print("result: {d}\n", .{v});
    } else |_| {
        std.debug.print("cannot divide by zero\n", .{});
    }
}
