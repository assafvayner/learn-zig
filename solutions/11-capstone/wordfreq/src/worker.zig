//! Per-file worker: one thread reads one file and builds one local map.
//!
//! No shared mutable state during counting — each thread writes only its own
//! `Job`. The buffer a thread reads is stored in the same `Job`, keeping it
//! alive (its slices are the map's keys) until the orchestrator merges and
//! frees everything after `join`.

const std = @import("std");
const counter = @import("counter.zig");

/// Work item for one input file. The thread fills in `text`, `counts`, and
/// `err`; the orchestrator reads them after `join`.
pub const Job = struct {
    alloc: std.mem.Allocator,
    io: std.Io,
    path: []const u8,

    /// File contents; keys in `counts` point into this. Freed by the owner.
    text: []u8 = &.{},
    counts: ?counter.Counts = null,
    err: ?anyerror = null,
};

const max_file_bytes = 64 * 1024 * 1024;

/// Thread entry point: read the file named by `job.path`, count its words, and
/// store the result (or the first error) back into `*job`. Never returns an
/// error — failures are recorded in `job.err` so `join` always succeeds and the
/// orchestrator decides what to do.
pub fn run(job: *Job) void {
    const text = std.Io.Dir.cwd().readFileAlloc(
        job.io,
        job.path,
        job.alloc,
        .limited(max_file_bytes),
    ) catch |e| {
        job.err = e;
        return;
    };
    job.text = text;

    job.counts = counter.countText(job.alloc, text) catch |e| {
        job.err = e;
        return;
    };
}

/// Release everything a finished `Job` owns: its map and its file buffer.
pub fn deinitJob(job: *Job) void {
    if (job.counts) |*c| c.deinit();
    job.alloc.free(job.text);
}
