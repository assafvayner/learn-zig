//! Chapter 6 — Data Structures & the Standard Library
//! Exercise 01: ArrayList — collect squares of 1..=5
//! Run: zig run exercises/06-data-structures-std/01_arraylist.zig
//! Expected output:
//!   { 1, 4, 9, 16, 25 }

const std = @import("std");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var list: std.ArrayList(u32) = .empty;
    defer list.deinit(alloc);

    // TODO: iterate 1..=5, append the square of each number to `list`

    // TODO: print list.items with {any}
}
