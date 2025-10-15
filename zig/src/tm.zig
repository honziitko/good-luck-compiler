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

pub fn Config(States: type, Symbol: type) type {
    std.debug.assert(isEnum(States));
    const Field2 = struct {
        move: Direction,
        write: Symbol,
        state: ?States,
    };
    const Entry2 = Struct2(Symbol, Field2);
    return struct {
        value: std.enums.EnumFieldStruct(States, Entry2, null),
        defaultSymbol: Symbol,
        pub const Tape = []Symbol;
        pub const State = States;
        pub const Field = Field2;
        pub const Entry = Entry2;
    };
}

pub fn State(comptime cfg: anytype) type {
    const Cfg = @TypeOf(cfg);
    return struct {
        const Self = @This();
        const State = Cfg.State;
        const Tape = Cfg.Tape;
        const Symbol = std.meta.Child(Tape);
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

        fn refillTape(comptime self: Self) bool {
            if (self.head < 0) {
                return -self.head > self.tapeLeft.len;
            } else {
                return self.head >= self.tapeRight.len;
            }
        }

        fn indexTape(comptime self: Self) Symbol {
            if (self.head < 0) {
                return self.tapeLeft[-self.head - 1];
            } else {
                return self.tapeRight[self.head];
            }
        }

        fn getField(comptime self: Self) Cfg.Field {
            const entry = @field(cfg.value, @tagName(self.state.?));
            const symbol = if (self.refillTape()) cfg.defaultSymbol else self.indexTape();
            switch (@typeInfo(Self.Symbol)) {
                .@"enum" => return @field(entry, @tagName(symbol)),
                .int => return entry[symbol],
                else => unreachable,
            }
        }

        pub fn next(comptime self: Self) Self {
            if (self.state == null) return self;
            const field = self.getField();
            comptime var out = self;
            if (self.refillTape()) {
                const T = []Symbol;
                if (self.head >= 0) {
                    out.tapeRight = out.tapeRight ++ @as(T, @constCast(([1]Symbol{field.write})[0..1]));
                } else {
                    out.tapeLeft = out.tapeLeft ++ [1]Symbol{field.write};
                }
            } else {
                if (self.head >= 0) {
                    out.tapeRight[self.head] = field.write;
                } else {
                    out.tapeLeft[-self.head - 1] = field.write;
                }
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
