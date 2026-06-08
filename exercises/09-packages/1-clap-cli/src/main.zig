//! Exercise 9.1 — clap-cli: `repeat`, your first program with a third-party dependency.
//!
//! Goal:
//!   repeat --count 3 --upper hello   -> prints HELLO three times (one per line)
//!   repeat hello                     -> prints hello once
//!
//! build.zig / build.zig.zon are already wired: `zig build` fetches clap for you.
//! Run: zig build run -- --count 3 --upper hello

const std = @import("std");
const clap = @import("clap");

pub fn main(init: std.process.Init) !void {
    // TODO 1: Declare the CLI grammar at comptime with clap.parseParamsComptime.
    //   You need: -h/--help (flag), -c/--count <usize>, -u/--upper (flag),
    //   and a single positional <str> for the word.
    //   Hint: each line is "<short>, <long> <value-type>  Help text.".

    // TODO 2: Parse with clap.parse(clap.Help, &params, clap.parsers.default,
    //   init.minimal.args, .{ .diagnostic = &diag, .allocator = init.gpa }).
    //   On error, call diag.reportToFile(init.io, .stderr(), err) and return err.
    //   Remember to `defer res.deinit();`.

    // TODO 3: If res.args.help != 0, print a usage line and return.

    // TODO 4: Read the count (res.args.count orelse 1) and the word
    //   (res.positionals[0] orelse "hello" — a single <str> is an optional!).

    // TODO 5: If res.args.upper != 0, upper-case the word (std.ascii.toUpper),
    //   then print the word `count` times, one per line.

    _ = init;
}
