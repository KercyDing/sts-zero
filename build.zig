const std = @import("std");
const impeller_pkg = @import("impeller_zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const strip = b.option(bool, "strip", "Strip debug symbols") orelse false;

    const os_tag = target.result.os.tag;

    const impeller_dep = b.dependency("impeller_zig", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl3_dep = b.dependency("sdl3", .{
        .target = target,
        .optimize = optimize,
    });

    const backend_mod = b.createModule(.{
        .root_source_file = b.path("src/backend/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "impeller", .module = impeller_dep.module("impeller") },
            .{ .name = "sdl3", .module = sdl3_dep.module("sdl3") },
        },
    });

    const config_mod = b.createModule(.{
        .root_source_file = b.path("src/config.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .strip = strip,
        .imports = &.{
            // Third party
            .{ .name = "impeller", .module = impeller_dep.module("impeller") },
            .{ .name = "sdl3", .module = sdl3_dep.module("sdl3") },
            // Mods
            .{ .name = "backend", .module = backend_mod },
            .{ .name = "config", .module = config_mod },
        },
    });
    const exe = b.addExecutable(.{
        .name = "sts-zero",
        .root_module = exe_mod,
    });

    impeller_pkg.linkRuntime(exe, impeller_dep);
    switch (os_tag) {
        .macos => {
            const metal_file = "src/backend/metal/metal.m";
            exe.root_module.addCSourceFile(.{
                .file = b.path(metal_file),
                .flags = &.{ "-fobjc-arc", "-Wno-deprecated-declarations", "-Wno-unguarded-availability-new" },
                .language = .objective_c,
            });
            exe.root_module.linkFramework("AppKit", .{});
            exe.root_module.linkFramework("Metal", .{});
            exe.root_module.linkFramework("QuartzCore", .{});

            exe.root_module.addRPathSpecial("@executable_path");

            b.getInstallStep().dependOn(impeller_pkg.installRuntime(.{
                .compile_step = exe,
                .dependency = impeller_dep,
            }));
        },
        .linux => {
            exe.root_module.linkSystemLibrary("vulkan", .{});
            exe.root_module.linkSystemLibrary("dl", .{});
            exe.root_module.linkSystemLibrary("pthread", .{});
            exe.root_module.linkSystemLibrary("m", .{});

            exe.root_module.addRPathSpecial("$ORIGIN");

            b.getInstallStep().dependOn(impeller_pkg.installRuntime(.{
                .compile_step = exe,
                .dependency = impeller_dep,
            }));
        },
        .windows => {
            b.getInstallStep().dependOn(impeller_pkg.installRuntime(.{
                .compile_step = exe,
                .dependency = impeller_dep,
            }));
        },
        else => {},
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
