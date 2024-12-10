const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const start = std.time.microTimestamp();

    try part1();
    try part2();

    const end = std.time.microTimestamp();
    const micros = end - start;
    const millis = @as(f32, @floatFromInt(micros)) / 1000;
    print("\nExecution time: {d:.3}ms\n", .{millis});
}

fn part1() !void {
    const total_antinodes = try solve(.SameDistance);
    print("Total antinodes Part 1: {}\n", .{total_antinodes});
}

fn part2() !void {
    const total_antinodes = try solve(.Resonant);
    print("Total antinodes Part 2: {}\n", .{total_antinodes});
}

const SolveMode = enum { SameDistance, Resonant };

fn solve(solve_mode: SolveMode) !u16 {
    var previousAntennasByAntenna = PreviousAntennasByAntenna.init();

    var antinodes: [ROWS][COLUMNS]bool = [_][COLUMNS]bool{
        [_]bool{false} ** COLUMNS,
    } ** ROWS;

    for (0..ROWS) |y| {
        for (0..COLUMNS) |x| {
            const coord = Coordinate{ .x = x, .y = y };

            const antenna = coord.getAntenna() orelse continue;

            const previousAntennas = previousAntennasByAntenna.get(antenna);

            for (previousAntennas.*.slice()) |previousAntenna| {
                const pairs = [_]struct { Coordinate, Coordinate }{
                    .{ coord, previousAntenna },
                    .{ previousAntenna, coord },
                };
                for (pairs) |pair| {
                    const a, const b = pair;
                    const move = Move.betweenCoordinates(a, b);
                    switch (solve_mode) {
                        .SameDistance => {
                            const antinode = b.makeMove(move) orelse continue;
                            antinodes[antinode.y][antinode.x] = true;
                        },
                        .Resonant => {
                            var move_iterator = MoveIterator.init(b, move);
                            while (move_iterator.next()) |antinode| {
                                antinodes[antinode.y][antinode.x] = true;
                            }
                        },
                    }
                }
            }

            try previousAntennas.append(coord);
        }
    }

    var total_antinodes: u16 = 0;
    for (antinodes) |row| {
        for (row) |is_antinode| {
            if (is_antinode) total_antinodes += 1;
        }
    }

    return total_antinodes;
}

const PreviousAntennas = std.BoundedArray(Coordinate, 4);

fn initPreviousAntennas() PreviousAntennas {
    return PreviousAntennas.init(0) catch unreachable;
}

const PreviousAntennasByAntenna = struct {
    const DATA_LEN = 'z' - '0' + 1;

    data: [DATA_LEN]PreviousAntennas,

    fn getIdx(antenna: u8) u8 {
        return antenna - 48;
    }

    const ALL_ANTENNAS = blk: {
        @setEvalBranchQuota(5000);
        var antennas = std.BoundedArray(u8, input.len).init(0) catch unreachable;
        for (input) |char| {
            if (char != '.' and char != '\n') {
                antennas.append(char) catch unreachable;
            }
        }
        break :blk antennas;
    };

    fn init() PreviousAntennasByAntenna {
        var data: [DATA_LEN]PreviousAntennas = undefined;
        for (ALL_ANTENNAS.slice()) |antenna| {
            data[getIdx(antenna)] = initPreviousAntennas();
        }
        return PreviousAntennasByAntenna{ .data = data };
    }

    fn get(self: *PreviousAntennasByAntenna, antenna: u8) *PreviousAntennas {
        return &self.data[getIdx(antenna)];
    }
};

const ROWS = 50;
const COLUMNS = 50;

const Move = struct {
    x: isize,
    y: isize,

    fn betweenCoordinates(a: Coordinate, b: Coordinate) Move {
        const a_x = @as(isize, @intCast(a.x));
        const a_y = @as(isize, @intCast(a.y));
        const b_x = @as(isize, @intCast(b.x));
        const b_y = @as(isize, @intCast(b.y));
        return Move{ .x = b_x - a_x, .y = b_y - a_y };
    }
};

const MoveIterator = struct {
    current_coordinate: ?Coordinate,
    move: Move,

    fn init(starting_coordinate: Coordinate, move: Move) MoveIterator {
        return MoveIterator{
            .current_coordinate = starting_coordinate,
            .move = move,
        };
    }

    fn next(self: *MoveIterator) ?Coordinate {
        const current_coordinate = self.current_coordinate orelse return null;
        self.current_coordinate = current_coordinate.makeMove(self.move);
        return current_coordinate;
    }
};

const Coordinate = struct {
    x: usize,
    y: usize,

    fn toInputIdx(self: *const Coordinate) usize {
        return self.y * (COLUMNS + 1) + self.x;
    }

    fn getChar(self: *const Coordinate) u8 {
        return input[self.toInputIdx()];
    }

    fn getAntenna(self: *const Coordinate) ?u8 {
        const char = self.getChar();
        if (char != '.') {
            return char;
        }
        return null;
    }

    fn makeMove(self: *const Coordinate, move: Move) ?Coordinate {
        const is_left_oob = move.x < 0 and @abs(move.x) > self.x;
        if (is_left_oob) return null;

        const is_right_oob = move.x > 0 and move.x > COLUMNS - 1 - self.x;
        if (is_right_oob) return null;

        const is_top_oob = move.y < 0 and @abs(move.y) > self.y;
        if (is_top_oob) return null;

        const is_bottom_oob = move.y > 0 and move.y > ROWS - 1 - self.y;
        if (is_bottom_oob) return null;

        const x = @as(usize, @intCast(@as(isize, @intCast(self.x)) + move.x));
        const y = @as(usize, @intCast(@as(isize, @intCast(self.y)) + move.y));

        return Coordinate{ .x = x, .y = y };
    }

    fn debug(self: *const Coordinate) void {
        print("Coordinate {{ x: {}, y: {} }}\n", .{ self.x, self.y });
    }
};

const input =
    \\...........V..................b.g.................
    \\..................................g...............
    \\.............................c....................
    \\............T........Z.......P....................
    \\.x........................VP......................
    \\..........................PH......................
    \\.................H.....Z.......g.R................
    \\......f............T.V....b......A................
    \\......................P...........................
    \\.......f..................A.............R.........
    \\........x..............T.......l..H.....A.c.......
    \\..k..x..............Z.............................
    \\........5....S...............0.A..................
    \\.............N....L...............................
    \\.f............................T........s.....N....
    \\..................l..........bH.......tc.R..N.....
    \\......Z...6......n......l...k.N...0...............
    \\...........g....S......l.r.................t..s...
    \\..L................b.......K..t...................
    \\................5....n........0.............c.....
    \\.....L......n............................E........
    \\.k.......L................m.....................Es
    \\..............St.....5....Rm......................
    \\............6..5...................3...0..........
    \\...........k.................W........3...........
    \\................n......K...E....2S..........3.....
    \\....................................E....Q........
    \\..........M.....x...............K.................
    \\..h.............................1.................
    \\.6............z..............4...e.........WY....y
    \\........f............a.......Y..y...s.............
    \\...h............r.............v....m..............
    \\.....h.................v....m.....Y.Q.....W3......
    \\.........................Yq....Q.................7
    \\.........6..............7.................9.......
    \\...................X..........y..q.....2..........
    \\............r..............q.....y...........7.8..
    \\..B..............M....4............9..............
    \\...1.......M...X.......CGzp...4..B...2..K.........
    \\.....................z...v....Q.....8...........9.
    \\B.......X.F....rM...v...............2...8..D......
    \\h1..............................7..D.....8....d...
    \\...............F.....................9D....4....d.
    \\..........a......p............F.........W.D......d
    \\.........................G..C...........q.........
    \\...B..................................C...........
    \\.........w..........z....p.....................e..
    \\.a............G....w........p........F........e...
    \\........a...w.....................................
    \\........w...............XC.......G................
;
