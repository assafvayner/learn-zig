//! Chapter 8 — Multi-file Programs & the Build System
//! Entry point: import the textstats module and print counts for `sample`.
//! Run: zig build run
//! Goal output:
//!   words: 7
//!   chars: 32

const std = @import("std");
const textstats = @import("textstats.zig");

pub fn main() void {
    const sample = "the quick brown fox the lazy dog";
    // TODO: print "words: N" and "chars: N" using textstats.wordCount / textstats.charCount.
    _ = sample;
}
