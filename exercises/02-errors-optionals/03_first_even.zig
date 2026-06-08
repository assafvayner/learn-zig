//! Chapter 2 — Errors & Optionals
//! Task: find the first even number in a slice, returning null if none.
//! Run: zig run exercises/02-errors-optionals/03_first_even.zig
//! Expected output:
//!   first even: 4
//!   first even: none

const std = @import("std");

fn firstEven(items: []const u32) ?u32 {
    // TODO: iterate over items; return the first value where v % 2 == 0
    //       return null if no even value found
    _ = items;
    return null;
}

pub fn main() void {
    const has_even = &[_]u32{ 1, 3, 4, 7 };
    const no_even = &[_]u32{ 1, 3, 5 };

    // TODO: call firstEven(has_even); if the result is non-null print "first even: {d}\n",
    //       otherwise print "first even: none\n"
    //       Hint: use `orelse` with a block that prints "none" and returns
    _ = has_even;

    // TODO: same for no_even
    _ = no_even;
}
