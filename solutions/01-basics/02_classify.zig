//! Chapter 1 — Values, Types & Control Flow: Exercise 2
//!
//! Task: Classify each temperature in `const temps = [_]i32{ -5, 10, 22, 35 }`
//! using a `switch` on ranges into: freezing (<0), cold (0..14), mild (15..27),
//! hot (>=28). Print `<temp>: <label>` per line.
//!
//! Run: zig run solutions/01-basics/02_classify.zig
//!
//! Expected output:
//! -5: freezing
//! 10: cold
//! 22: mild
//! 35: hot

const std = @import("std");

pub fn main() void {
    const temps = [_]i32{ -5, 10, 22, 35 };
    for (temps) |t| {
        const label = switch (t) {
            std.math.minInt(i32)...-1 => "freezing",
            0...14 => "cold",
            15...27 => "mild",
            else => "hot",
        };
        std.debug.print("{d}: {s}\n", .{ t, label });
    }
}
