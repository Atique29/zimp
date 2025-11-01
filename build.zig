const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const img_mod = b.addModule("img_loader", .{
        .root_source_file = b.path("src/img_loader.zig"),
        .target = target,
    });

    //point to stb files
    img_mod.addIncludePath(b.path("src/"));
    img_mod.addCSourceFile(.{
        .file = b.path("src/stb/test.c"),
        .flags = &[_][]const u8{
            "-std=c11", 
            "-Wall",
        }, 
    });

    const exe = b.addExecutable(.{
        .name = "imzg",
        .root_module = b.createModule(.{
            
            .root_source_file = b.path("src/main.zig"),
            
            .target = target,
            .optimize = optimize,

            .link_libc = true, //NEW WAY TO LINK LIBC, FORGET OLD TUTORIALSS!!
            
            .imports = &.{
                .{ .name = "img_loader", .module = img_mod },
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
