//! Chapter 9.1 — clap-cli: `repeat`, our first program with a third-party dependency.
//!
//! Usage:
//!   repeat --count 3 --upper hello   -> prints HELLO three times (one per line)
//!   repeat hello                     -> prints hello once
//!
//! Run: zig build run -- --count 3 --upper hello

const std = @import("std");
const clap = @import("clap");

pub fn main(init: std.process.Init) !void {
    // Declare the CLI grammar at comptime. Each line is one parameter; the help
    // text after the flag is what `--help` prints. `<usize>` / `<str>` name the
    // value parser to use (from clap.parsers.default).
    const params = comptime clap.parseParamsComptime(
        \\-h, --help           Display this help and exit.
        \\-c, --count <usize>  How many times to repeat (default 1).
        \\-u, --upper          Upper-case the word before printing.
        \\<str>                The word to repeat.
        \\
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, init.minimal.args, .{
        .diagnostic = &diag,
        .allocator = init.gpa,
    }) catch |err| {
        // On a parse error, report it via the 0.16 I/O interface and re-raise.
        try diag.reportToFile(init.io, .stderr(), err);
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) {
        std.debug.print("usage: repeat [--count N] [--upper] <word>\n", .{});
        return;
    }

    const count = res.args.count orelse 1;
    // A single `<str>` positional is an optional ?[]const u8, not a slice.
    const word = res.positionals[0] orelse "hello";

    if (res.args.upper != 0) {
        // Upper-case into a stack buffer (words longer than 256 bytes are truncated).
        var buf: [256]u8 = undefined;
        const n = @min(word.len, buf.len);
        for (word[0..n], 0..) |ch, i| buf[i] = std.ascii.toUpper(ch);
        const upper = buf[0..n];
        var i: usize = 0;
        while (i < count) : (i += 1) std.debug.print("{s}\n", .{upper});
    } else {
        var i: usize = 0;
        while (i < count) : (i += 1) std.debug.print("{s}\n", .{word});
    }
}
