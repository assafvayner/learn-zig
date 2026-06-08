//! Chapter 6 — Data Structures & the Standard Library
//! Exercise 03: Sort an array of i32 in descending order
//! Run: zig run solutions/06-data-structures-std/03_sort.zig
//! Expected output:
//!   { 9, 8, 5, 3, 2, 1 }

const std = @import("std");

pub fn main() void {
    var nums = [_]i32{ 5, 3, 8, 1, 9, 2 };
    std.sort.pdq(i32, &nums, {}, std.sort.desc(i32));
    std.debug.print("{any}\n", .{nums});
}
