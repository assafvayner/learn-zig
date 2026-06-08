//! Exercise 02 — Linked List with ArenaAllocator
//! Task: Build a singly linked list of i32 using an ArenaAllocator.
//!       Push 1, 2, 3 via head-insertion (newest at front), traverse from
//!       head, and print values space-separated on one line.
//!       arena.deinit() frees all nodes at once — no individual frees needed.
//!
//! Run: zig run exercises/05-memory-allocators/02_linked_list.zig
//! Expected output:
//!   3 2 1

const std = @import("std");

const Node = struct { value: i32, next: ?*Node };

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // TODO: head-insert the values 1, 2, 3 by creating Node pointers with
    //       alloc.create(Node), setting node.* = .{ .value = v, .next = head },
    //       and updating head = node.
    //       Then traverse head and print each value space-separated.
    _ = alloc;
}
