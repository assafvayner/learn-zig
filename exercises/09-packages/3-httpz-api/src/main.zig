//! Exercise 9.3 — httpz-api: a tiny JSON API on the pure-Zig httpz server.
//!
//! Goal:  GET /quote  ->  {"author":"...","quote":"..."}
//!        --port N flag (default 8080), parsed with clap (same as 9.1).
//!
//! build.zig / build.zig.zon are already wired: `zig build` fetches httpz + clap.
//! Run:  zig build run -- --port 8080
//! Test: curl http://localhost:8080/quote

const std = @import("std");
const httpz = @import("httpz");
const clap = @import("clap");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // TODO 1: Parse --port <u16> (and -h/--help) with clap, exactly like in 9.1.
    //   Use init.minimal.args and init.gpa; report errors via
    //   diag.reportToFile(init.io, .stderr(), err). Default the port to 8080.

    // TODO 2: Create the server. httpz.Server(void) means a stateless handler:
    //   var server = try httpz.Server(void).init(init.io, gpa,
    //       .{ .address = .localhost(port) }, {});
    //   defer { server.stop(); server.deinit(); }

    // TODO 3: Get the router and register the route:
    //   var router = try server.router(.{});
    //   router.get("/quote", quote, .{});

    // TODO 4: Print a "listening on ..." line, then `try server.listen();` (blocks).

    _ = gpa;
}

/// Handler: fn (req, res) !void. Set res.status = 200 and return a JSON body
/// with res.json(.{ .author = ..., .quote = ... }, .{}).
fn quote(_: *httpz.Request, res: *httpz.Response) !void {
    // TODO 5: set the status and serialize an author/quote struct with res.json.
    _ = res;
}
