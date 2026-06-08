//! Chapter 3 — Arrays, Slices & Strings
//! Task: implement isPalindrome that ignores ASCII case, test with "Racecar" and "hello".
//! Run: zig run solutions/03-arrays-slices-strings/03_palindrome.zig
//! Expected output:
//!   Racecar: true
//!   hello: false

const std = @import("std");

fn isPalindrome(s: []const u8) bool {
    var i: usize = 0;
    var j: usize = s.len;
    while (i < j) {
        j -= 1;
        if (std.ascii.toLower(s[i]) != std.ascii.toLower(s[j])) return false;
        i += 1;
    }
    return true;
}

pub fn main() void {
    std.debug.print("Racecar: {}\n", .{isPalindrome("Racecar")});
    std.debug.print("hello: {}\n", .{isPalindrome("hello")});
}
