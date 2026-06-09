const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Pull in the clap dependency declared in build.zig.zon (key "clap").
    const clap = b.dependency("clap", .{ .target = target, .optimize = optimize });

    const exe = b.addExecutable(.{
        .name = "wordfreq",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            // Make `@import("clap")` resolve to clap's module.
            .imports = &.{
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
    const run_step = b.step("run", "Run wordfreq");
    run_step.dependOn(&run_cmd.step);

    // Tests live in counter.zig; build a module rooted there so `zig build test`
    // exercises the counting/merge/sort logic without needing clap.
    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/counter.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
