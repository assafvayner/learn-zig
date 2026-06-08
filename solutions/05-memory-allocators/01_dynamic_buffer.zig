//! Exercise 01 — Dynamic Buffer
//! Task: Use a DebugAllocator to allocate a []u8 of length 5, fill it with
//!       'a'..'e', print it, and free it. The defer on gpa.deinit() shows
//!       leak detection: remove the free and it will report a leak.
//!
//! Run: zig run 01_dynamic_buffer.zig
//! Expected output:
//!   abcde

const std = @import("std");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const buf = try alloc.alloc(u8, 5);
    defer alloc.free(buf);

    for (buf, 0..) |*b, i| b.* = 'a' + @as(u8, @intCast(i));

    std.debug.print("{s}\n", .{buf});
}
