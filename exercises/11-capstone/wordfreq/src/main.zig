//! wordfreq — count word frequencies across multiple files in parallel and
//! print the top N most frequent words.
//!
//! Pipeline you will build:
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

    // TODO: implement the parallel pipeline.
    //   1. Allocate one `worker.Job` per path and initialize each with
    //      { .alloc = alloc, .io = io, .path = path }. Arrange to `worker.deinitJob`
    //      each one (e.g. `defer for (jobs) |*job| worker.deinitJob(job);`).
    //   2. Allocate `[]std.Thread`. Spawn ALL threads first
    //      (std.Thread.spawn(.{}, worker.run, .{job})), THEN join them all, so
    //      the file reads and counting overlap.
    //   3. Merge: create an owned `counter.Counts`, and for each job, surface
    //      `job.err` if set, else `counter.mergeInto` its map.
    //   4. Rank: `counter.topN(alloc, &merged, top)` and print each entry as
    //      `{s}: {d}` with the word and count.
    _ = top;
    _ = alloc;
}
