//! Exercise 03 — Leak Detection with std.testing.allocator
//! Task: Complete the test so it allocates a slice, writes to it, and frees it.
//!       std.testing.allocator fails the test automatically if any allocation
//!       is not freed — remove the free call to see that failure in action.
//!
//! Run: zig test exercises/05-memory-allocators/03_leak_test.zig
//! Expected output:
//!   All 2 tests passed.

const std = @import("std");

test "alloc and free leaves no leaks" {
    const alloc = std.testing.allocator;
    // TODO: alloc a slice of u8 (length 8), write to it, assert something,
    //       and free it with defer alloc.free(buf).
    //       (Removing the free makes this test fail with a leak report —
    //       that's the teaching point of std.testing.allocator.)
    _ = alloc;
}

test "create and destroy leaves no leaks" {
    const alloc = std.testing.allocator;
    // TODO: alloc.create(u64), set the value, assert it, alloc.destroy(p).
    _ = alloc;
}
