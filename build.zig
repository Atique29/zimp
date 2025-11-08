const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const core_mod = b.addModule("core", .{
        .root_source_file = b.path("src/core.zig"),
    });

    const image_io_mod = b.addModule("image_io", .{
        .root_source_file = b.path("src/image_io.zig"),
        .imports = &.{
            .{ .name = "core", .module=core_mod},
        }
    });

    //point to stb files
    image_io_mod.addIncludePath(b.path("src/"));
    image_io_mod.addCSourceFile(.{
        .file = b.path("src/stb/test.c"),
        .flags = &[_][]const u8{
            "-std=c11", 
            "-Wall",
        }, 
    });

    const fun_mod = b.addModule("fun", .{
        .root_source_file = b.path("src/fun.zig"),
        .imports = &.{
            .{ .name = "core", .module=core_mod},
        }
    });


    const exe = b.addExecutable(.{
        .name = "zimp",
        .root_module = b.createModule(.{
            
            .root_source_file = b.path("src/main.zig"),
            
            .target = target,
            .optimize = optimize,

            .link_libc = true, //NEW WAY TO LINK LIBC, FORGET OLD TUTORIALSS!!
            
            .imports = &.{
                .{ .name = "image_io", .module = image_io_mod },
                .{ .name = "core", .module = core_mod },
                .{ .name = "fun", .module = fun_mod },
            },
        }),
    });


    
    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());
    
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    
}
