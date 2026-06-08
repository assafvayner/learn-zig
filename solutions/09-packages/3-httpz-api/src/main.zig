//! Chapter 9.3 — httpz-api: a tiny JSON API served by the pure-Zig httpz server.
//!
//! Route:  GET /quote  ->  {"author":"...","quote":"..."}
//! Flag:   --port N    (default 8080), parsed with clap (reused from 9.1).
//!
//! Run:  zig build run -- --port 8080
//! Test: curl http://localhost:8080/quote

const std = @import("std");
const httpz = @import("httpz");
const clap = @import("clap");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // Parse --port with clap. On error, report via the 0.16 I/O interface.
    const params = comptime clap.parseParamsComptime(
        \\-h, --help        Display this help and exit.
        \\-p, --port <u16>  Port to listen on (default 8080).
        \\
    );
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, init.minimal.args, .{
        .diagnostic = &diag,
        .allocator = gpa,
    }) catch |err| {
        try diag.reportToFile(init.io, .stderr(), err);
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) {
        std.debug.print("usage: quoteapi [--port N]\n", .{});
        return;
    }
    const port = res.args.port orelse 8080;

    // Server(void): a stateless handler, so we pass {} as the handler instance.
    // The first argument is init.io — the 0.16 I/O interface httpz runs on.
    var server = try httpz.Server(void).init(init.io, gpa, .{
        .address = .localhost(port),
    }, {});
    defer {
        server.stop();
        server.deinit();
    }

    var router = try server.router(.{});
    router.get("/quote", quote, .{});

    std.debug.print("listening on http://localhost:{d}/quote\n", .{port});
    try server.listen(); // blocks until server.stop()
}

/// Handler signature on 0.16: fn (req, res) !void. `res.json` serializes any
/// struct to a JSON body and sets the content type.
fn quote(_: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    try res.json(.{
        .author = "Andrew Kelley",
        .quote = "Zig is a general-purpose programming language and toolchain.",
    }, .{});
}
