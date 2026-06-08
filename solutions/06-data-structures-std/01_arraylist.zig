//! Chapter 6 — Data Structures & the Standard Library
//! Exercise 01: ArrayList — collect squares of 1..=5
//! Run: zig run solutions/06-data-structures-std/01_arraylist.zig
//! Expected output:
//!   { 1, 4, 9, 16, 25 }

const std = @import("std");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var list: std.ArrayList(u32) = .empty;
    defer list.deinit(alloc);

    for (1..6) |i| {
        const n: u32 = @intCast(i);
        try list.append(alloc, n * n);
    }

    std.debug.print("{any}\n", .{list.items});
}
