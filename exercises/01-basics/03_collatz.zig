//! Chapter 1 — Values, Types & Control Flow: Exercise 3
//!
//! Task: Count Collatz steps to reach 1 from `const start: u64 = 27`.
//! Rule: n → n/2 if even, 3n+1 if odd.
//! Print `27 reaches 1 in <count> steps` and assert the count equals 111.
//!
//! Run: zig run exercises/01-basics/03_collatz.zig
//!
//! Expected output:
//! 27 reaches 1 in 111 steps

const std = @import("std");

pub fn main() void {
    const start: u64 = 27;
    var steps: u64 = 0;
    // TODO: loop until `n` reaches 1, applying the Collatz rule each iteration,
    // incrementing `steps`. Then assert steps == 111 and print the result.
    _ = start;
    _ = steps;
}
