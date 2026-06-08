//! Chapter 0 — Setup & Hello: Exercise 2
//!
//! Task: Given `name` and `year`, print `Hello, world! It is 2026.` using
//! `std.debug.print` with `{s}` for the string and `{d}` for the integer.
//!
//! Run: zig run exercises/00-setup/02_greeting.zig
//!
//! Expected output:
//! Hello, world! It is 2026.

const std = @import("std");

pub fn main() void {
    const name = "world";
    const year: u32 = 2026;
    // TODO: use std.debug.print to print "Hello, {s}! It is {d}.\n"
    _ = name;
    _ = year;
}
