const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tm_module = b.addModule("tm", .{
        .root_source_file = b.path("src/tm.zig"),
    });

    const glc_module = b.addModule("glcompiler", .{
        .root_source_file = b.path("src/root.zig"),
    });
    glc_module.addImport("tm", tm_module);

    const exe = b.addExecutable(.{
        .root_source_file = b.path("example.zig"),
        .name = "example",
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("tm", tm_module);
    exe.root_module.addImport("glcompiler", glc_module);
    b.getInstallStep().dependOn(&b.addInstallArtifact(exe, .{}).step);

    const options = b.addOptions();
    options.addOption(usize, "num_states", 10);
    options.addOption(usize, "num_symbols", 2);
    // Chosen by a fair dice roll.
    // Guranteed to be random.
    options.addOption(u64, "seed", 4);
    glc_module.addOptions("config", options);
}
