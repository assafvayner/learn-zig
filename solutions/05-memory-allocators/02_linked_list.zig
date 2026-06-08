//! Exercise 02 — Linked List with ArenaAllocator
//! Task: Build a singly linked list of i32 using an ArenaAllocator.
//!       Push 1, 2, 3 via head-insertion (newest at front), traverse, and
//!       print values space-separated. arena.deinit() frees all nodes at once.
//!
//! Run: zig run 02_linked_list.zig
//! Expected output:
//!   3 2 1

const std = @import("std");

const Node = struct { value: i32, next: ?*Node };

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var head: ?*Node = null;

    // Head-insert 1, 2, 3 — results in 3 -> 2 -> 1
    for ([_]i32{ 1, 2, 3 }) |v| {
        const node = try alloc.create(Node);
        node.* = .{ .value = v, .next = head };
        head = node;
    }

    // Traverse and print
    var cur = head;
    var first = true;
    while (cur) |n| {
        if (!first) std.debug.print(" ", .{});
        std.debug.print("{d}", .{n.value});
        first = false;
        cur = n.next;
    }
    std.debug.print("\n", .{});
}
