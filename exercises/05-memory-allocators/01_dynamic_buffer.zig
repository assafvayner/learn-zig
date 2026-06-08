//! Exercise 01 — Dynamic Buffer
//! Task: Use a DebugAllocator to allocate a []u8 of length 5, fill it so
//!       buf[i] = 'a' + i (i.e. "abcde"), print it with {s}, and free it.
//!       The defer on gpa.deinit() demonstrates leak detection: remove the
//!       free and it will print a leak report.
//!
//! Run: zig run exercises/05-memory-allocators/01_dynamic_buffer.zig
//! Expected output:
//!   abcde

const std = @import("std");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // TODO: allocate a []u8 of length 5, fill it with 'a'..'e',
    //       print it with std.debug.print("{s}\n", .{buf}),
    //       and free it with defer alloc.free(buf).
    _ = alloc;
}
