//! Chapter 0 — Setup & Hello: Exercise 1
//!
//! Task: Print exactly `Hello, Zig!` followed by a newline using the
//! buffered stdout writer (`std.Io.File.Writer`). This exercises the real
//! stdout path: `pub fn main(init: std.process.Init) !void`, constructing
//! a `std.Io.File.Writer`, calling `.print`, and flushing.
//!
//! Run: zig run solutions/00-setup/01_hello.zig
//!
//! Expected output:
//! Hello, Zig!

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buf: [1024]u8 = undefined;
    var fw: std.Io.File.Writer = .init(.stdout(), io, &buf);
    const out = &fw.interface;
    try out.print("Hello, Zig!\n", .{});
    try out.flush();
}
