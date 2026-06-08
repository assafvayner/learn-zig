//! Exercise 03 — Leak Detection with std.testing.allocator
//! Task: Write tests that allocate memory via std.testing.allocator.
//!       The allocator fails the test if any allocation is not freed.
//!       (Try removing the free call — the test will fail with a leak report.)
//!
//! Run: zig test 03_leak_test.zig
//! Expected output:
//!   All 2 tests passed.

const std = @import("std");

test "alloc and free leaves no leaks" {
    const alloc = std.testing.allocator;
    const buf = try alloc.alloc(u8, 8);
    defer alloc.free(buf);

    for (buf, 0..) |*b, i| b.* = @intCast(i);
    try std.testing.expectEqual(@as(u8, 7), buf[7]);
}

test "create and destroy leaves no leaks" {
    const alloc = std.testing.allocator;
    const p = try alloc.create(u64);
    defer alloc.destroy(p);

    p.* = 42;
    try std.testing.expectEqual(@as(u64, 42), p.*);
}
