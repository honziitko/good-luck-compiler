const std = @import("std");
const config = @import("config");
const tm = @import("tm");

fn GetUintForN(comptime n: usize) type {
    return std.math.IntFittingRange(0, n - 1);
}

fn GenerateEnum(comptime n: usize) type {
    comptime var fields: [n]std.builtin.Type.EnumField = undefined;
    inline for (0..n) |i| {
        fields[i] = .{
            .name = std.fmt.comptimePrint("state_{d}", .{i}),
            .value = i,
        };
    }
    return @Type(.{ .@"enum" = .{
        .tag_type = GetUintForN(n),
        .fields = &fields,
        .decls = &.{},
        .is_exhaustive = true,
    } });
}

const Symbol = GenerateEnum(config.num_symbols);
const State = GenerateEnum(config.num_states);

// Apprently Zig's standard RNG is runtime-only
// so we rolled our own
const rng = struct {
    pub const Int = u31;
    pub fn linearCongruential(x: u31) u31 {
        const m = 1 << 31;
        const a = 1103515245;
        const c = 1345;

        const y: u62 = @intCast(x);
        const out = (a * y + c) % m;
        return out;
    }
    const hash: fn (Int) Int = linearCongruential;

    pub fn intUpTo(seed: Int, n: comptime_int) comptime_int {
        // Without this, n could be teturned which we don't want
        // due to bias.
        if (seed == std.math.maxInt(Int)) {
            return n - 1;
        }
        const x: comptime_float = @floatFromInt(seed);
        const max: comptime_float = @floatFromInt(std.math.maxInt(Int));
        const normalized = x / max;
        const scaled = normalized * n;
        return @intFromFloat(scaled);
    }

    fn slice(comptime seed: Int, T: type, comptime xs: []const T) T {
        return xs[intUpTo(seed, xs.len)];
    }

    pub fn getEnum(comptime seed: Int, E: type) E {
        const field = slice(seed, std.builtin.Type.EnumField, @typeInfo(E).@"enum".fields);
        return @enumFromInt(field.value);
    }
};

fn iterStruct(x: anytype) []const std.builtin.Type.StructField {
    return std.meta.fields(@TypeOf(x));
}

fn generateConfig() tm.Config(State, Symbol) {
    comptime var rngState: comptime_int = @intCast(config.seed);

    const Config = tm.Config(State, Symbol);
    comptime var out = Config{
        .value = undefined,
        .defaultSymbol = .state_0,
    };

    inline for (iterStruct(out.value)) |f| {
        comptime var entry: Config.Entry = undefined;
        inline for (iterStruct(entry)) |f2| {
            rngState = rng.hash(rngState);
            const dir = comptime rng.getEnum(rngState, tm.Direction);
            rngState = rng.hash(rngState);
            const write = comptime rng.getEnum(rngState, Symbol);
            rngState = rng.hash(rngState);
            // Gotta include halting
            const newStateNum = rng.intUpTo(rngState, config.num_states + 1);
            const newState: ?State = if (newStateNum == 0) null else @enumFromInt(newStateNum - 1);
            @field(entry, f2.name) = .{
                .move = dir,
                .write = write,
                .state = newState,
            };
        }
        @field(out.value, f.name) = entry;
    }
    return out;
}

pub fn haveFun() bool {
    const tmConfig = comptime generateConfig();
    const tmState = tm.State(tmConfig).init(.state_0);
    return comptime tmState.halts();
}
