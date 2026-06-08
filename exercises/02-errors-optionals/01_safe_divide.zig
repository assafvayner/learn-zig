//! Chapter 2 — Errors & Optionals
//! Task: implement divide() that returns error.DivByZero when b==0.
//! Run: zig run exercises/02-errors-optionals/01_safe_divide.zig
//! Expected output:
//!   10 / 2 = 5
//!   cannot divide by zero

const std = @import("std");

fn divide(a: i32, b: i32) error{DivByZero}!i32 {
    // TODO: return error.DivByZero if b == 0, otherwise return @divTrunc(a, b)
    _ = a;
    _ = b;
    return 0;
}

pub fn main() void {
    // TODO: call divide(10, 2), store result (hint: use catch unreachable for the
    //       "known good" call), and print "10 / 2 = {d}\n"

    // TODO: call divide(10, 0); when it returns an error, print "cannot divide by zero\n"
    //       Hint: if (divide(...)) |v| { ... } else |_| { ... }
}
