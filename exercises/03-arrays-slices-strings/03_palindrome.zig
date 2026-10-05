//! Chapter 3 — Arrays, Slices & Strings
//! Task: implement isPalindrome that ignores ASCII case, test with "Racecar" and "hello".
//! Run: zig run exercises/03-arrays-slices-strings/03_palindrome.zig
//! Expected output:
//!   Racecar: true
//!   hello: false

const std = @import("std");

fn isPalindrome(s: []const u8) bool {
    // TODO: compare mirrored characters using std.ascii.toLower;
    //       return true if all pairs match, false otherwise.
    var i: usize = 0;
    const len = s.len;
    while (i < len / 2) : (i += 1) {
        const left = std.ascii.toLower(s[i]);
        const right = std.ascii.toLower(s[len - i - 1]);
        if (right != left) {
            return false;
        }
    }
    return true;
}

pub fn main() void {
    // TODO: print the results for "Racecar" and "hello".
    std.debug.print("isPalindrome(\"Racecar\"): {}\n", .{isPalindrome("Racecar")});
    std.debug.print("isPalindrome(\"hello\"): {}\n", .{isPalindrome("hello")});
}
