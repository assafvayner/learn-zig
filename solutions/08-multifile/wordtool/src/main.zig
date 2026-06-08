//! Chapter 8 — Multi-file Programs & the Build System
//! Entry point: imports the textstats module and prints counts for a sample string.
//! Run: zig build run
//! Expected output:
//!   words: 7
//!   chars: 32

const std = @import("std");
const textstats = @import("textstats.zig");

pub fn main() void {
    const sample = "the quick brown fox the lazy dog";
    std.debug.print("words: {d}\n", .{textstats.wordCount(sample)});
    std.debug.print("chars: {d}\n", .{textstats.charCount(sample)});
}
