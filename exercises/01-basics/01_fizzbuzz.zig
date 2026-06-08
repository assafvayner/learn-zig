//! Chapter 1 — Values, Types & Control Flow: Exercise 1
//!
//! Task: Print integers 1..=20, but `Fizz` for multiples of 3, `Buzz` for
//! multiples of 5, and `FizzBuzz` for multiples of both — one per line.
//! Use `for (1..21) |i|`.
//!
//! Run: zig run solutions/01-basics/01_fizzbuzz.zig
//!
//! Expected output:
//! 1
//! 2
//! Fizz
//! 4
//! Buzz
//! Fizz
//! 7
//! 8
//! Fizz
//! Buzz
//! 11
//! Fizz
//! 13
//! 14
//! FizzBuzz
//! 16
//! 17
//! Fizz
//! 19
//! Buzz

const std = @import("std");

pub fn main() void {
    for (1..21) |i| {
        // TODO: print "FizzBuzz", "Fizz", "Buzz", or the number
        _ = i;
    }
}
