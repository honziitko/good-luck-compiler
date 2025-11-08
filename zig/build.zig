const std = @import("std");

const default_states = 6;
const default_symbols = 2;
// Chosen by a fair dice roll.
// Guranteed to be random.
const default_seed = 4;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const num_states = b.option(usize, "states", "How many states (excluding halt) does the TM have") orelse default_states;
    const num_symbols = b.option(usize, "symbols", "How many symbols does the tape have") orelse default_symbols;
    const seed = b.option(u64, "seed", "The initial seed") orelse default_seed;
    if (num_states == 0) {
        std.debug.panic("There must be at least one state\n", .{});
    }
    if (num_symbols == 0) {
        std.debug.panic("There must be at least one symbol\n", .{});
    }

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
    options.addOption(usize, "num_states", num_states);
    options.addOption(usize, "num_symbols", num_symbols);
    options.addOption(u64, "seed", seed);
    glc_module.addOptions("config", options);
}
