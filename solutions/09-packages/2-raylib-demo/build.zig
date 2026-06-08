const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // raylib_zig exposes a "raylib" Zig module *and* a "raylib" C-library artifact.
    const raylib_zig = b.dependency("raylib_zig", .{ .target = target, .optimize = optimize });
    const raylib_mod = raylib_zig.module("raylib"); // the @import("raylib") bindings
    const raylib_artifact = raylib_zig.artifact("raylib"); // the raylib C library

    // clap (reused from 9.1) parses --count / --width / --height.
    const clap = b.dependency("clap", .{ .target = target, .optimize = optimize });

    const exe = b.addExecutable(.{
        .name = "balls",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    // 0.16: wire imports and linked libraries on the root *module*.
    exe.root_module.addImport("raylib", raylib_mod);
    exe.root_module.addImport("clap", clap.module("clap"));
    exe.root_module.linkLibrary(raylib_artifact);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run the bouncing-balls demo (opens a window)");
    run_step.dependOn(&run_cmd.step);
}
