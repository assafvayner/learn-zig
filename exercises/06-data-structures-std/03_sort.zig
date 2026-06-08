//! Chapter 6 — Data Structures & the Standard Library
//! Exercise 03: Sort an array of i32 in descending order
//! Run: zig run exercises/06-data-structures-std/03_sort.zig
//! Expected output:
//!   { 9, 8, 5, 3, 2, 1 }

const std = @import("std");

pub fn main() void {
    // Change `const` to `var` once you add the sort call (sort mutates the slice).
    const nums = [_]i32{ 5, 3, 8, 1, 9, 2 };

    // TODO: sort nums in descending order with std.sort.pdq

    // TODO: print nums with {any}
    _ = nums;
}
