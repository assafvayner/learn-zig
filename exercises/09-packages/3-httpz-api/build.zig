const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Two dependencies: the httpz web server, and clap for the --port flag.
    const httpz = b.dependency("httpz", .{ .target = target, .optimize = optimize });
    const clap = b.dependency("clap", .{ .target = target, .optimize = optimize });

    const exe = b.addExecutable(.{
        .name = "quoteapi",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "httpz", .module = httpz.module("httpz") },
                .{ .name = "clap", .module = clap.module("clap") },
            },
        }),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the quote API server");
    run_step.dependOn(&run_cmd.step);
}
