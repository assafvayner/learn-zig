//! Per-file worker: one thread reads one file and builds one local map.
//!
//! No shared mutable state during counting — each thread writes only its own
//! `Job`. The buffer a thread reads is stored in the same `Job`, keeping it
//! alive (its slices are the map's keys) until the orchestrator merges and
//! frees everything after `join`.
//!
//! Implement `run` and `deinitJob`.

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
/// store the result (or the first error) back into `*job`. Must never return an
/// error — record failures in `job.err` so `join` always succeeds.
pub fn run(job: *Job) void {
    // TODO:
    //   1. read the file:
    //        std.Io.Dir.cwd().readFileAlloc(job.io, job.path, job.alloc,
    //            .limited(max_file_bytes))
    //      on error, set `job.err` and return; on success store it in `job.text`.
    //   2. count it: counter.countText(job.alloc, job.text) into `job.counts`
    //      (again, set `job.err` and return on error).
    _ = job;
}

/// Release everything a finished `Job` owns: its map and its file buffer.
pub fn deinitJob(job: *Job) void {
    // TODO: deinit `job.counts` if present, then free `job.text`.
    _ = job;
}
