//! wordfreq — count word frequencies across multiple files in parallel and
//! print the top N most frequent words.
//!
//! Pipeline:
//!   1. Parse `--top N` and the file positionals with clap.
//!   2. Spawn one thread per file; each thread reads its file and builds a
//!      LOCAL StringHashMap (no shared mutable state during counting).
//!   3. After join, merge the per-file maps into one (dup keys so the merged
//!      map owns them), collect entries, sort by count desc / word asc, and
//!      print the top N as `word: count`.

const std = @import("std");
const clap = @import("clap");
const counter = @import("counter.zig");
const worker = @import("worker.zig");

const default_top = 10;

pub fn main(init: std.process.Init) !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const io = init.io;

    const params = comptime clap.parseParamsComptime(
        \\-h, --help        Display this help and exit.
        \\-t, --top <usize> Print the top N most frequent words (default 10).
        \\<str>...          One or more text files to count.
        \\
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, init.minimal.args, .{
        .diagnostic = &diag,
        .allocator = init.gpa,
    }) catch |err| {
        try diag.reportToFile(io, .stderr(), err);
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) {
        std.debug.print(
            \\usage: wordfreq [--top N] <file>...
            \\
            \\Counts word frequencies across the given files in parallel and
            \\prints the top N most frequent words (word: count).
            \\
        , .{});
        return;
    }

    const top = res.args.top orelse default_top;
    const paths = res.positionals[0];
    if (paths.len == 0) {
        std.debug.print("error: no input files (try --help)\n", .{});
        return error.NoInputFiles;
    }

    // One job + one thread per file. Jobs outlive the threads; their buffers
    // outlive the merge (their slices are the per-file maps' keys).
    const jobs = try alloc.alloc(worker.Job, paths.len);
    defer alloc.free(jobs);
    for (jobs, paths) |*job, path| job.* = .{ .alloc = alloc, .io = io, .path = path };
    defer for (jobs) |*job| worker.deinitJob(job);

    const threads = try alloc.alloc(std.Thread, paths.len);
    defer alloc.free(threads);

    // Spawn all, THEN join all, so the file reads and counting overlap.
    for (threads, jobs) |*t, *job| t.* = try std.Thread.spawn(.{}, worker.run, .{job});
    for (threads) |t| t.join();

    // Merge each per-file map into one owned map.
    var merged = counter.Counts.init(alloc);
    defer counter.deinitOwned(&merged);
    for (jobs) |*job| {
        if (job.err) |e| {
            std.debug.print("error: reading '{s}': {s}\n", .{ job.path, @errorName(e) });
            return e;
        }
        if (job.counts) |*c| try counter.mergeInto(&merged, c);
    }

    const ranked = try counter.topN(alloc, &merged, top);
    defer alloc.free(ranked);

    for (ranked) |entry| std.debug.print("{s}: {d}\n", .{ entry.word, entry.count });
}
