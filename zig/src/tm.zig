const std = @import("std");

fn isEnum(T: type) bool {
    return std.meta.activeTag(@typeInfo(T)) == .@"enum";
}

fn Struct2(Key: type, Value: type) type {
    const keyInfo = @typeInfo(Key);
    switch (keyInfo) {
        .@"enum" => return std.enums.EnumFieldStruct(Key, Value, null),
        .int => |int| {
            std.debug.assert(int.signedness == .unsigned);
            return [std.math.maxInt(Key) + 1]Value;
        },
        else => @compileError(std.fmt.comptimePrint("Cannot make a struct from {s}", .{@typeName(Key)})),
    }
}

pub const Direction = enum { left, right };

pub fn Config(States: type, Symbol2: type) type {
    std.debug.assert(isEnum(States));
    const Field2 = struct {
        move: Direction,
        write: Symbol2,
        state: ?States,
    };
    const Entry2 = Struct2(Symbol2, Field2);
    return struct {
        value: std.enums.EnumFieldStruct(States, Entry2, null),
        defaultSymbol: Symbol2,
        pub const Symbol = Symbol2;
        pub const State = States;
        pub const Field = Field2;
        pub const Entry = Entry2;
    };
}

pub fn State(comptime cfg: anytype) type {
    const Cfg = @TypeOf(cfg);
    return struct {
        const Self = @This();
        const Symbol = Cfg.Symbol;
        const State = Cfg.State;
        const Tape = []const Symbol;
        state: ?Self.State,
        head: comptime_int,
        tapeRight: Tape,
        tapeLeft: Tape,

        pub fn init(comptime state: Self.State) Self {
            return .{
                .state = state,
                .head = 0,
                .tapeRight = &.{},
                .tapeLeft = &.{},
            };
        }

        fn getField(comptime self: Self, comptime tape: Tape, index: comptime_int) Cfg.Field {
            const entry = @field(cfg.value, @tagName(self.state.?));
            const symbol = if (index >= tape.len) cfg.defaultSymbol else tape[index];
            switch (@typeInfo(Self.Symbol)) {
                .@"enum" => return @field(entry, @tagName(symbol)),
                .int => return entry[symbol],
                else => unreachable,
            }
        }

        fn set(comptime xs: []const Symbol, i: comptime_int, comptime x: Symbol) []const Symbol {
            const left = xs[0..i];
            const right = xs[i + 1 ..];
            return left ++ [1]Symbol{x} ++ right;
        }

        pub fn next(comptime self: Self) Self {
            if (self.state == null) return self;
            comptime var out = self;
            const currentTape = if (self.head >= 0) &out.tapeRight else &out.tapeLeft;
            const index = if (self.head >= 0) self.head else -self.head - 1;
            const field = self.getField(currentTape.*, index);
            if (index >= currentTape.len) {
                const toAppend = [1]Symbol{field.write};
                currentTape.* = currentTape.* ++ toAppend;
            } else {
                currentTape.* = set(currentTape.*, index, field.write);
            }
            switch (field.move) {
                .left => out.head -= 1,
                .right => out.head += 1,
            }
            out.state = field.state;
            return out;
        }

        pub fn halts(comptime self: Self) bool {
            comptime var state = self;
            inline while (true) {
                if (state.state == null) return true;
                state = state.next();
            }
        }
    };
}
