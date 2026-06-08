//! Chapter 2 — Errors & Optionals
//! Task: parse integers from strings, falling back to 0 on failure.
//! Run: zig run exercises/02-errors-optionals/02_parse_or_default.zig
//! Expected output:
//!   123
//!   0

const std = @import("std");

pub fn main() void {
    const good = "123";
    const bad = "oops";

    // TODO: parse `good` with std.fmt.parseInt(i32, good, 10), defaulting to 0 on error
    //       print the result with "{d}\n"
    _ = good;

    // TODO: parse `bad` with std.fmt.parseInt(i32, bad, 10), defaulting to 0 on error
    //       print the result with "{d}\n"
    _ = bad;
}
