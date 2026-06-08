const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Pull in the clap dependency declared in build.zig.zon (key "clap").
    const clap = b.dependency("clap", .{ .target = target, .optimize = optimize });

    const exe = b.addExecutable(.{
        .name = "repeat",
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
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run repeat");
    run_step.dependOn(&run_cmd.step);
}
