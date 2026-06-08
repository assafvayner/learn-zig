//! Chapter 10 — Concurrency
//! Raw OS threads (`std.Thread.spawn`/`join`) and lock-free atomics
//! (`std.atomic.Value`). Data races are avoided by partitioning: each
//! thread writes only its own slot or its own disjoint slice region.

const std = @import("std");

/// Number of worker threads used by `parallelSum` and `parallelMap`.
const num_threads = 4;

/// Worker for `parallelSum`: sums `chunk` and writes the total into `out`.
/// Each worker owns a distinct `out` pointer, so no synchronization is needed.
fn sumChunk(chunk: []const u64, out: *u64) void {
    var acc: u64 = 0;
    for (chunk) |v| acc += v;
    out.* = acc;
}

/// Sum a slice by splitting it into `num_threads` chunks, summing each chunk
/// on its own thread, then adding the partial sums after the threads join.
pub fn parallelSum(data: []const u64) u64 {
    var threads: [num_threads]std.Thread = undefined;
    var partials: [num_threads]u64 = .{0} ** num_threads;

    const chunk_len = (data.len + num_threads - 1) / num_threads;
    for (&threads, 0..) |*t, i| {
        const start = @min(i * chunk_len, data.len);
        const end = @min(start + chunk_len, data.len);
        t.* = std.Thread.spawn(.{}, sumChunk, .{ data[start..end], &partials[i] }) catch unreachable;
    }
    for (threads) |t| t.join();

    var total: u64 = 0;
    for (partials) |p| total += p;
    return total;
}

/// Worker for `atomicCounter`: increments the shared counter `iterations`
/// times. The atomic read-modify-write makes concurrent increments safe.
fn bump(counter: *std.atomic.Value(u64), iterations: usize) void {
    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        _ = counter.fetchAdd(1, .seq_cst);
    }
}

/// Spawn `thread_count` threads that each increment a single shared atomic
/// counter `per_thread` times, and return the final value.
pub fn atomicCounter(comptime thread_count: usize, per_thread: usize) u64 {
    var counter = std.atomic.Value(u64).init(0);
    var threads: [thread_count]std.Thread = undefined;
    for (&threads) |*t| {
        t.* = std.Thread.spawn(.{}, bump, .{ &counter, per_thread }) catch unreachable;
    }
    for (threads) |t| t.join();
    return counter.load(.seq_cst);
}

/// Worker for `parallelMap`: squares `in[i]` into `out[i]` for its range.
/// Each worker owns a disjoint `[start, end)` slice, so the writes never
/// overlap and no locking is required.
fn squareRange(in: []const u64, out: []u64, start: usize, end: usize) void {
    var i = start;
    while (i < end) : (i += 1) out[i] = in[i] * in[i];
}

/// Square every element of `in` into `out`, partitioning the index range
/// across `num_threads` threads that write to disjoint regions of `out`.
/// Asserts `in.len == out.len`.
pub fn parallelMap(in: []const u64, out: []u64) void {
    std.debug.assert(in.len == out.len);
    var threads: [num_threads]std.Thread = undefined;

    const chunk_len = (in.len + num_threads - 1) / num_threads;
    for (&threads, 0..) |*t, i| {
        const start = @min(i * chunk_len, in.len);
        const end = @min(start + chunk_len, in.len);
        t.* = std.Thread.spawn(.{}, squareRange, .{ in, out, start, end }) catch unreachable;
    }
    for (threads) |t| t.join();
}

fn serialSum(data: []const u64) u64 {
    var total: u64 = 0;
    for (data) |v| total += v;
    return total;
}

test "parallelSum equals the serial sum of 0..=999" {
    var data: [1000]u64 = undefined;
    for (&data, 0..) |*v, i| v.* = @intCast(i);

    const got = parallelSum(&data);
    try std.testing.expectEqual(@as(u64, 499500), got);
    try std.testing.expectEqual(serialSum(&data), got);
}

test "atomicCounter: 8 threads x 1000 increments == 8000" {
    try std.testing.expectEqual(@as(u64, 8000), atomicCounter(8, 1000));
}

test "parallelMap squares each element into a disjoint output slot" {
    var in: [1000]u64 = undefined;
    for (&in, 0..) |*v, i| v.* = @intCast(i);
    var out: [1000]u64 = undefined;

    parallelMap(&in, &out);

    for (out, 0..) |o, i| try std.testing.expectEqual(@as(u64, @intCast(i * i)), o);
}
