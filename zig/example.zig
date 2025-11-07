const std = @import("std");
const tm = @import("tm");
const glc = @import("glcompiler");

const config = tm.Config(enum { A }, u1){
    .defaultSymbol = 0,
    .value = .{
        .A = .{
            .{ .move = .right, .write = 1, .state = .A }, //on 0
            .{ .move = .right, .write = 0, .state = .A }, //on 1
        },
    },
};
const state = tm.State(config).init(.A);

pub fn main() !void {
    // @setEvalBranchQuota(std.math.maxInt(u32));
    std.debug.print("TM halts: {}\n", .{glc.haveFun()});
}
