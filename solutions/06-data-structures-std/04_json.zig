//! Chapter 6 — Data Structures & the Standard Library
//! Exercise 04: Parse JSON into a struct with std.json
//! Run: zig run solutions/06-data-structures-std/04_json.zig
//! Expected output:
//!   name=zig year=2026

const std = @import("std");

const Info = struct { name: []const u8, year: u32 };

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const text = "{\"name\":\"zig\",\"year\":2026}";

    const parsed = try std.json.parseFromSlice(Info, alloc, text, .{});
    defer parsed.deinit();

    std.debug.print("name={s} year={d}\n", .{ parsed.value.name, parsed.value.year });
}
