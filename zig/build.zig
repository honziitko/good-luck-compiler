const std = @import("std");

const default_states = 6;
const default_symbols = 2;

const EntropySource = union(enum) {
    hardcoded: u64,
    fair_dice_roll_guranteed_to_be_random: void,
    time_s: void,
    time_ms: void,
    time_us: void,
    time_ns: void,

    pub fn seed(self: EntropySource) u64 {
        switch (self) {
            .hardcoded => |num| return num,
            .fair_dice_roll_guranteed_to_be_random => return 4,
            .time_s => return @bitCast(std.time.timestamp()),
            .time_ms => return @bitCast(std.time.milliTimestamp()),
            .time_us => return @bitCast(std.time.microTimestamp()),
            .time_ns => return @truncate(@as(u128, @bitCast(std.time.nanoTimestamp()))),
        }
    }
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const num_states = b.option(usize, "states", "How many states (excluding halt) does the TM have") orelse default_states;
    const num_symbols = b.option(usize, "symbols", "How many symbols does the tape have") orelse default_symbols;
    const entropy_type = b.option(std.meta.FieldEnum(EntropySource), "entropy", "Where to get entropy from") orelse .fair_dice_roll_guranteed_to_be_random;
    const seed = b.option(u64, "seed", "The initial seed");

    if (num_states == 0) {
        std.debug.panic("There must be at least one state\n", .{});
    }
    if (num_symbols == 0) {
        std.debug.panic("There must be at least one symbol\n", .{});
    }
    if (entropy_type != .hardcoded and seed != null) {
        std.debug.panic("Cannot specify seed for {s}\n", .{@tagName(entropy_type)});
    }
    if (entropy_type == .hardcoded and seed == null) {
        std.debug.panic(".hardcoded requires a seed\n", .{});
    }
    const entropy: EntropySource = switch (entropy_type) {
        .hardcoded => .{ .hardcoded = seed.? },
        inline else => |t| @unionInit(EntropySource, @tagName(t), undefined),
    };

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
    options.addOption(u64, "seed", entropy.seed());
    glc_module.addOptions("config", options);
}
