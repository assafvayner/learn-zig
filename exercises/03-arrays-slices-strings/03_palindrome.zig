//! Chapter 3 — Arrays, Slices & Strings
//! Task: implement isPalindrome that ignores ASCII case, test with "Racecar" and "hello".
//! Run: zig run solutions/03-arrays-slices-strings/03_palindrome.zig
//! Expected output:
//!   Racecar: true
//!   hello: false

const std = @import("std");

fn isPalindrome(s: []const u8) bool {
    // TODO: compare mirrored characters using std.ascii.toLower;
    //       return true if all pairs match, false otherwise.
    _ = s;
    return false;
}

pub fn main() void {
    // TODO: print the results for "Racecar" and "hello".
}
