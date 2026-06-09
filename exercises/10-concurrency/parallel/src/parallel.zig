//! Chapter 10 — Concurrency
//! Raw OS threads (`std.Thread.spawn`/`join`) and lock-free atomics
//! (`std.atomic.Value`). Data races are avoided by partitioning: each
//! thread writes only its own slot or its own disjoint slice region.
//!
//! Fill in the three functions below so `zig build test` passes. In 0.16
//! `std.Thread.Mutex`/`Pool`/`WaitGroup` no longer exist — use only
//! `std.Thread.spawn`/`join`, partitioned data, and `std.atomic.Value`.

const std = @import("std");

/// Number of worker threads used by `parallelSum` and `parallelMap`.
const num_threads = 4;

/// Sum a slice by splitting it into `num_threads` chunks, summing each chunk
/// on its own thread, then adding the partial sums after the threads join.
pub fn parallelSum(data: []const u64) u64 {
    // TODO: spawn `num_threads` workers, each summing one chunk of `data`
    // into its own `partials[i]` slot; join them, then add the partials.
    _ = data;
    return 0;
}

/// Spawn `thread_count` threads that each increment a single shared atomic
/// counter `per_thread` times, and return the final value.
pub fn atomicCounter(comptime thread_count: usize, per_thread: usize) u64 {
    // TODO: create a `std.atomic.Value(u64)`, spawn `thread_count` threads
    // that each call `fetchAdd(1, .seq_cst)` `per_thread` times, join, then
    // `load(.seq_cst)` the final value.
    _ = thread_count;
    _ = per_thread;
    return 0;
}

/// Square every element of `in` into `out`, partitioning the index range
/// across `num_threads` threads that write to disjoint regions of `out`.
/// Asserts `in.len == out.len`.
pub fn parallelMap(in: []const u64, out: []u64) void {
    std.debug.assert(in.len == out.len);
    // TODO: give each thread a disjoint `[start, end)` range and have it
    // write `out[i] = in[i] * in[i]` for that range. No locking needed.
}

fn serialSum(data: []const u64) u64 {
    var total: u64 = 0;
    for (data) |v| {
        total += v;
    }
    return total;
}

test "parallelSum equals the serial sum of 0..=999" {
    var data: [1000]u64 = undefined;
    for (&data, 0..) |*v, i| {
        v.* = @intCast(i);
    }

    const got = parallelSum(&data);
    try std.testing.expectEqual(@as(u64, 499500), got);
    try std.testing.expectEqual(serialSum(&data), got);
}

test "atomicCounter: 8 threads x 1000 increments == 8000" {
    try std.testing.expectEqual(@as(u64, 8000), atomicCounter(8, 1000));
}

test "parallelMap squares each element into a disjoint output slot" {
    var in: [1000]u64 = undefined;
    for (&in, 0..) |*v, i| {
        v.* = @intCast(i);
    }
    var out: [1000]u64 = undefined;

    parallelMap(&in, &out);

    for (out, 0..) |o, i| {
        try std.testing.expectEqual(@as(u64, @intCast(i * i)), o);
    }
}
