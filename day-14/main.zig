const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const start = std.time.microTimestamp();

    // part1();
    try part2();

    const end = std.time.microTimestamp();
    const micros = end - start;
    const millis = @as(f32, @floatFromInt(micros)) / 1000;
    print("\nExecution time: {d:.3}ms\n", .{millis});
}

fn part1() void {
    var quadrant_counts = [_]u32{ 0, 0, 0, 0 };

    var input_iterator = InputIterator.init();
    while (input_iterator.next()) |line| {
        var coord, const move = line;
        for (0..100) |_| coord = coord.makeMove(move);
        const quadrant = coord.getQuadrant() orelse continue;
        quadrant_counts[@intFromEnum(quadrant)] += 1;
    }

    var safety_factor: u32 = 1;
    for (quadrant_counts) |count| {
        safety_factor *= count;
    }

    print("Safety factor: {}\n", .{safety_factor});
}

const Robots = std.BoundedArray(CoordinateAndMove, INPUPT_LINES);

fn part2() !void {
    var robots = try Robots.init(0);

    var input_iterator = InputIterator.init();
    while (input_iterator.next()) |coordAndMove| try robots.append(coordAndMove);

    try Grid.fromRobots(robots).printGrid(0);

    for (0..100000) |seconds| {
        for (robots.slice(), 0..) |robot, i| {
            var coord, const move = robot;
            robots.set(i, CoordinateAndMove{ coord.makeMove(move), move });
        }

        var in_a_row = false;
        var grid = Grid.fromRobots(robots);
        outer: for (grid.grid) |row| {
            var num_in_a_row: u8 = 0;
            for (row) |cell| {
                switch (cell) {
                    true => num_in_a_row += 1,
                    false => num_in_a_row = 0,
                }
                if (num_in_a_row == 20) {
                    in_a_row = true;
                    break :outer;
                }
            }
        }

        if (in_a_row) {
            try grid.printGrid(seconds + 1);
        }
    }
}

const Grid = struct {
    grid: [ROWS][COLUMNS]bool,

    fn init() Grid {
        const grid: [ROWS][COLUMNS]bool = [_][COLUMNS]bool{
            [_]bool{false} ** COLUMNS,
        } ** ROWS;
        return Grid{ .grid = grid };
    }

    fn fromRobots(robots: Robots) Grid {
        var self = Grid.init();
        for (robots.constSlice()) |robot| {
            const coord, _ = robot;
            self.grid[coord.y][coord.x] = true;
        }
        return self;
    }

    fn printGrid(self: *const Grid, seconds: usize) !void {
        const file = try std.fs.cwd().createFile(
            try std.fmt.allocPrint(std.heap.page_allocator, "{}.txt", .{seconds}),
            .{ .read = true },
        );
        defer file.close();
        for (self.grid) |row| {
            for (row) |cell| {
                const c = switch (cell) {
                    true => "🤖",
                    false => "⬛",
                };
                _ = try file.write(c);
            }
            _ = try file.write("\n");
        }
    }
};

const ROWS = 103;
const COLUMNS = 101;

const Move = struct { x: isize, y: isize };

const Quadrant = enum(u2) { TopLeft, TopRight, BottomRight, BottomLeft };

const Coordinate = struct {
    x: usize,
    y: usize,

    fn getQuadrant(self: *const Coordinate) ?Quadrant {
        const columns_half = comptime @divFloor(COLUMNS, 2);
        const rows_half = comptime @divFloor(ROWS, 2);

        if (self.x < columns_half and self.y < rows_half) {
            return .TopLeft;
        }

        if (self.x > columns_half and self.y < rows_half) {
            return .TopRight;
        }

        if (self.x > columns_half and self.y > rows_half) {
            return .BottomRight;
        }

        if (self.x < columns_half and self.y > rows_half) {
            return .BottomLeft;
        }

        return null;
    }

    fn makeMove(self: *const Coordinate, move: Move) Coordinate {
        var x = @as(isize, @intCast(self.x)) + move.x;
        if (x < 0) x += COLUMNS;
        if (x >= COLUMNS) x -= COLUMNS;

        var y = @as(isize, @intCast(self.y)) + move.y;
        if (y < 0) y += ROWS;
        if (y >= ROWS) y -= ROWS;

        return Coordinate{
            .x = @as(usize, @intCast(x)),
            .y = @as(usize, @intCast(y)),
        };
    }
};

const CoordinateAndMove = struct { Coordinate, Move };

const InputIterator = struct {
    lines_iterator: std.mem.SplitIterator(u8, .sequence),

    fn init() InputIterator {
        const lines_iterator = std.mem.splitSequence(u8, input, "\n");
        return InputIterator{ .lines_iterator = lines_iterator };
    }

    fn next(self: *InputIterator) ?CoordinateAndMove {
        const line = self.lines_iterator.next() orelse return null;

        var line_iterator = std.mem.splitAny(u8, line, "=, ");

        _ = line_iterator.next().?; // => "p"
        const x_str = line_iterator.next().?;
        const y_str = line_iterator.next().?;

        _ = line_iterator.next().?; // => "v"
        const vx_str = line_iterator.next().?;
        const vy_str = line_iterator.next().?;

        return .{
            Coordinate{
                .x = std.fmt.parseInt(usize, x_str, 10) catch unreachable,
                .y = std.fmt.parseInt(usize, y_str, 10) catch unreachable,
            },
            Move{
                .x = std.fmt.parseInt(isize, vx_str, 10) catch unreachable,
                .y = std.fmt.parseInt(isize, vy_str, 10) catch unreachable,
            },
        };
    }
};

const INPUPT_LINES = blk: {
    @setEvalBranchQuota(100000);
    var line_iterator = std.mem.splitSequence(u8, input, "\n");
    var lines = 0;
    while (line_iterator.next()) |_| lines += 1;
    break :blk lines;
};

const input =
    \\p=14,11 v=-25,-54
    \\p=58,14 v=-37,28
    \\p=4,96 v=-76,48
    \\p=27,96 v=30,88
    \\p=37,41 v=-63,-26
    \\p=65,86 v=58,1
    \\p=79,18 v=42,-51
    \\p=33,41 v=-3,-94
    \\p=56,63 v=72,11
    \\p=67,74 v=-51,93
    \\p=54,59 v=-43,-59
    \\p=53,21 v=38,95
    \\p=5,38 v=-3,19
    \\p=12,20 v=-67,5
    \\p=97,44 v=73,-66
    \\p=54,55 v=-32,50
    \\p=53,18 v=-85,86
    \\p=5,80 v=-83,69
    \\p=93,48 v=-17,-3
    \\p=69,53 v=28,10
    \\p=21,36 v=-2,-25
    \\p=44,50 v=16,20
    \\p=50,22 v=-92,64
    \\p=52,66 v=15,81
    \\p=22,86 v=38,-65
    \\p=88,2 v=-81,4
    \\p=8,25 v=-61,75
    \\p=94,40 v=12,53
    \\p=14,15 v=47,51
    \\p=5,36 v=55,-96
    \\p=39,19 v=42,61
    \\p=97,36 v=84,76
    \\p=5,35 v=-10,99
    \\p=8,11 v=-76,62
    \\p=89,24 v=-32,-72
    \\p=30,52 v=-70,-3
    \\p=75,52 v=70,-59
    \\p=35,39 v=-85,-94
    \\p=16,27 v=-3,-29
    \\p=31,66 v=60,-80
    \\p=42,48 v=52,-71
    \\p=9,78 v=-39,60
    \\p=81,47 v=85,77
    \\p=64,81 v=8,-67
    \\p=60,99 v=35,61
    \\p=76,32 v=49,-27
    \\p=52,91 v=80,36
    \\p=94,61 v=78,10
    \\p=3,55 v=-25,-72
    \\p=42,11 v=-28,-41
    \\p=48,16 v=88,-18
    \\p=33,57 v=-27,33
    \\p=82,47 v=-38,-25
    \\p=80,70 v=20,45
    \\p=78,12 v=27,72
    \\p=77,98 v=-95,2
    \\p=99,25 v=82,-2
    \\p=35,0 v=67,35
    \\p=20,95 v=-12,94
    \\p=12,12 v=-28,-75
    \\p=34,21 v=-19,-15
    \\p=28,16 v=60,-18
    \\p=69,62 v=50,11
    \\p=7,36 v=-55,-60
    \\p=36,56 v=16,-48
    \\p=17,100 v=75,38
    \\p=14,0 v=-95,26
    \\p=14,97 v=54,84
    \\p=39,23 v=-14,39
    \\p=57,69 v=1,-59
    \\p=26,42 v=70,-34
    \\p=4,9 v=66,-27
    \\p=0,59 v=-25,-36
    \\p=41,38 v=-13,32
    \\p=100,85 v=-9,-8
    \\p=84,31 v=34,30
    \\p=44,3 v=44,-54
    \\p=57,41 v=-8,-70
    \\p=32,11 v=-64,98
    \\p=18,14 v=-26,-7
    \\p=80,75 v=-22,-9
    \\p=7,56 v=46,11
    \\p=60,35 v=66,-61
    \\p=65,83 v=43,-44
    \\p=50,30 v=-28,42
    \\p=29,30 v=-41,98
    \\p=66,92 v=49,27
    \\p=92,32 v=-17,-16
    \\p=71,51 v=-50,-89
    \\p=47,29 v=36,-52
    \\p=11,57 v=-4,33
    \\p=80,101 v=49,59
    \\p=83,98 v=-88,-32
    \\p=52,67 v=-14,69
    \\p=58,66 v=-6,7
    \\p=97,85 v=-46,2
    \\p=29,37 v=-40,-74
    \\p=62,37 v=99,86
    \\p=23,19 v=53,17
    \\p=72,7 v=-16,75
    \\p=80,57 v=48,79
    \\p=52,47 v=51,-14
    \\p=76,76 v=-23,14
    \\p=73,100 v=57,3
    \\p=54,50 v=8,-37
    \\p=73,98 v=-37,4
    \\p=72,17 v=29,13
    \\p=89,8 v=-2,-86
    \\p=0,54 v=-17,-82
    \\p=0,25 v=91,-85
    \\p=90,41 v=41,43
    \\p=91,27 v=-60,17
    \\p=71,55 v=-28,-91
    \\p=22,74 v=-5,-34
    \\p=82,38 v=-51,-3
    \\p=70,89 v=-87,3
    \\p=42,83 v=-93,47
    \\p=84,13 v=-43,46
    \\p=100,34 v=-39,-39
    \\p=49,19 v=40,-79
    \\p=15,52 v=32,-94
    \\p=26,55 v=-55,-71
    \\p=94,24 v=78,97
    \\p=73,32 v=45,42
    \\p=52,68 v=5,74
    \\p=69,64 v=43,-56
    \\p=9,82 v=40,-45
    \\p=48,51 v=8,-36
    \\p=67,6 v=86,85
    \\p=48,14 v=-44,-86
    \\p=54,6 v=72,-76
    \\p=84,29 v=-10,31
    \\p=42,42 v=-36,89
    \\p=59,16 v=49,-73
    \\p=52,80 v=-14,-79
    \\p=92,93 v=-64,-93
    \\p=32,15 v=-56,17
    \\p=46,48 v=80,40
    \\p=30,89 v=38,36
    \\p=23,0 v=32,-77
    \\p=40,5 v=52,-30
    \\p=60,95 v=36,-73
    \\p=41,68 v=-12,-47
    \\p=71,96 v=-30,47
    \\p=96,58 v=48,32
    \\p=87,35 v=-81,-84
    \\p=7,38 v=-42,76
    \\p=70,63 v=92,68
    \\p=70,74 v=14,71
    \\p=74,36 v=-66,21
    \\p=93,0 v=-97,-25
    \\p=97,69 v=4,-44
    \\p=99,96 v=-60,-41
    \\p=8,90 v=47,95
    \\p=20,35 v=-99,16
    \\p=58,23 v=-50,18
    \\p=41,50 v=64,-50
    \\p=29,7 v=81,84
    \\p=13,16 v=-37,46
    \\p=34,8 v=-34,4
    \\p=16,80 v=-61,42
    \\p=48,34 v=66,63
    \\p=76,83 v=52,-52
    \\p=71,71 v=64,69
    \\p=68,58 v=-95,-3
    \\p=10,71 v=-83,46
    \\p=58,41 v=58,-3
    \\p=37,43 v=66,-61
    \\p=32,95 v=-33,-42
    \\p=40,75 v=-42,70
    \\p=29,10 v=85,-4
    \\p=61,53 v=72,55
    \\p=21,68 v=23,-42
    \\p=4,88 v=-35,-6
    \\p=16,22 v=-5,-95
    \\p=64,11 v=50,28
    \\p=14,35 v=-33,19
    \\p=14,34 v=87,37
    \\p=17,72 v=-2,13
    \\p=62,10 v=29,39
    \\p=15,72 v=10,10
    \\p=85,96 v=26,-31
    \\p=95,83 v=-3,-46
    \\p=32,42 v=-41,66
    \\p=38,1 v=82,87
    \\p=68,16 v=57,28
    \\p=92,8 v=-33,31
    \\p=17,57 v=-47,-26
    \\p=75,102 v=6,26
    \\p=59,24 v=-22,29
    \\p=50,20 v=32,-5
    \\p=12,17 v=54,75
    \\p=96,53 v=-10,-70
    \\p=21,1 v=74,25
    \\p=38,101 v=-2,30
    \\p=13,57 v=-3,63
    \\p=57,91 v=-36,72
    \\p=54,98 v=-36,-68
    \\p=51,56 v=-50,68
    \\p=100,59 v=12,-36
    \\p=38,49 v=9,-85
    \\p=78,93 v=-95,28
    \\p=2,48 v=-25,21
    \\p=71,78 v=-4,-71
    \\p=91,10 v=-76,-37
    \\p=74,84 v=-23,-56
    \\p=31,73 v=80,-2
    \\p=65,15 v=13,-29
    \\p=49,74 v=22,-11
    \\p=69,35 v=72,-78
    \\p=90,66 v=-53,-81
    \\p=84,95 v=78,25
    \\p=80,93 v=77,-73
    \\p=48,85 v=66,15
    \\p=76,63 v=2,11
    \\p=64,52 v=28,66
    \\p=59,53 v=87,-82
    \\p=30,0 v=-19,-54
    \\p=50,101 v=-74,-1
    \\p=29,53 v=-99,44
    \\p=63,24 v=-42,-82
    \\p=70,94 v=86,2
    \\p=19,88 v=49,67
    \\p=60,78 v=-53,79
    \\p=1,35 v=48,-39
    \\p=54,3 v=51,-20
    \\p=14,4 v=82,72
    \\p=77,34 v=-95,20
    \\p=3,97 v=55,-55
    \\p=32,30 v=-82,64
    \\p=64,60 v=8,-34
    \\p=3,97 v=26,-55
    \\p=90,21 v=-81,-30
    \\p=26,64 v=17,-80
    \\p=69,68 v=40,35
    \\p=89,72 v=-67,1
    \\p=42,99 v=85,39
    \\p=96,29 v=15,-32
    \\p=26,27 v=-12,6
    \\p=20,77 v=10,-10
    \\p=57,102 v=92,37
    \\p=93,78 v=70,82
    \\p=47,61 v=-29,67
    \\p=99,50 v=62,21
    \\p=39,66 v=95,56
    \\p=30,96 v=31,-66
    \\p=34,42 v=-62,-71
    \\p=91,20 v=70,63
    \\p=27,73 v=-55,-46
    \\p=45,79 v=14,51
    \\p=34,99 v=8,-43
    \\p=84,9 v=-83,80
    \\p=30,29 v=33,51
    \\p=56,75 v=36,-39
    \\p=97,48 v=12,-2
    \\p=69,25 v=-75,92
    \\p=63,57 v=29,-1
    \\p=38,14 v=-50,15
    \\p=7,51 v=9,20
    \\p=8,6 v=-19,95
    \\p=82,65 v=-51,-34
    \\p=80,2 v=-12,-38
    \\p=2,54 v=-92,26
    \\p=33,79 v=17,-34
    \\p=21,71 v=32,90
    \\p=96,34 v=-16,-40
    \\p=22,6 v=-79,79
    \\p=54,74 v=-72,80
    \\p=45,76 v=95,35
    \\p=48,84 v=-93,-44
    \\p=59,29 v=8,-76
    \\p=67,12 v=50,51
    \\p=81,61 v=34,-53
    \\p=97,71 v=-86,-87
    \\p=45,84 v=-20,95
    \\p=28,30 v=11,87
    \\p=66,72 v=80,-70
    \\p=1,45 v=62,-81
    \\p=65,85 v=16,1
    \\p=2,51 v=25,42
    \\p=62,9 v=-22,17
    \\p=83,28 v=-49,-97
    \\p=92,15 v=76,28
    \\p=72,94 v=-30,-89
    \\p=9,79 v=-11,35
    \\p=83,62 v=-15,-93
    \\p=18,60 v=82,-70
    \\p=29,41 v=-71,30
    \\p=67,34 v=-3,-7
    \\p=12,24 v=-47,-17
    \\p=84,91 v=-84,54
    \\p=1,23 v=40,6
    \\p=74,17 v=42,-75
    \\p=21,9 v=75,-86
    \\p=47,63 v=-28,90
    \\p=51,19 v=-4,1
    \\p=27,45 v=24,7
    \\p=79,9 v=-48,39
    \\p=20,15 v=75,5
    \\p=100,30 v=-10,74
    \\p=71,61 v=31,-30
    \\p=48,73 v=22,-55
    \\p=81,6 v=-23,52
    \\p=56,74 v=24,32
    \\p=55,34 v=-86,-4
    \\p=78,86 v=-95,48
    \\p=93,27 v=11,-4
    \\p=57,53 v=-7,56
    \\p=42,16 v=-85,-52
    \\p=6,14 v=53,98
    \\p=26,2 v=10,-65
    \\p=37,13 v=-41,56
    \\p=63,6 v=7,15
    \\p=49,99 v=-60,75
    \\p=21,11 v=-47,-39
    \\p=30,63 v=-84,-58
    \\p=14,29 v=-76,-74
    \\p=10,101 v=-48,94
    \\p=92,3 v=-32,86
    \\p=55,90 v=88,58
    \\p=50,76 v=-71,14
    \\p=54,17 v=58,-23
    \\p=81,72 v=-52,58
    \\p=69,41 v=50,55
    \\p=14,85 v=32,-44
    \\p=86,29 v=-74,53
    \\p=66,65 v=-37,56
    \\p=75,11 v=63,-54
    \\p=61,74 v=14,80
    \\p=84,59 v=-59,84
    \\p=22,34 v=-92,96
    \\p=95,33 v=55,30
    \\p=55,102 v=68,-45
    \\p=47,5 v=59,-8
    \\p=70,43 v=86,9
    \\p=93,42 v=34,-83
    \\p=5,17 v=-93,-79
    \\p=11,81 v=-47,36
    \\p=93,41 v=-31,89
    \\p=25,10 v=88,-88
    \\p=72,60 v=-98,4
    \\p=25,2 v=-62,-65
    \\p=65,101 v=80,40
    \\p=67,51 v=-65,9
    \\p=94,19 v=60,-22
    \\p=9,37 v=-32,53
    \\p=68,100 v=33,87
    \\p=95,8 v=41,-41
    \\p=94,54 v=-88,-80
    \\p=6,50 v=-60,89
    \\p=77,71 v=-52,-80
    \\p=87,63 v=28,-22
    \\p=98,96 v=55,-9
    \\p=79,6 v=-58,50
    \\p=69,74 v=58,-32
    \\p=54,10 v=-35,26
    \\p=8,67 v=56,-54
    \\p=94,39 v=-23,53
    \\p=21,65 v=-98,-1
    \\p=89,62 v=-9,-14
    \\p=16,42 v=65,67
    \\p=55,42 v=31,-46
    \\p=36,42 v=45,56
    \\p=15,67 v=-26,13
    \\p=79,36 v=85,77
    \\p=8,96 v=47,-43
    \\p=35,70 v=74,-8
    \\p=58,38 v=-91,-44
    \\p=17,98 v=2,-43
    \\p=93,15 v=-68,38
    \\p=9,90 v=19,-91
    \\p=18,47 v=-25,53
    \\p=41,98 v=66,-8
    \\p=43,85 v=-34,-88
    \\p=13,16 v=68,61
    \\p=9,63 v=17,-48
    \\p=1,59 v=12,-2
    \\p=61,15 v=-36,-98
    \\p=21,63 v=-84,-93
    \\p=70,35 v=-9,64
    \\p=67,33 v=-16,54
    \\p=94,58 v=-53,-48
    \\p=52,28 v=-51,-51
    \\p=63,9 v=86,4
    \\p=47,41 v=-7,-4
    \\p=24,10 v=-28,-20
    \\p=95,71 v=19,-68
    \\p=16,50 v=-19,-60
    \\p=34,86 v=53,-17
    \\p=32,24 v=74,52
    \\p=27,65 v=60,45
    \\p=63,102 v=7,-88
    \\p=20,66 v=-96,71
    \\p=78,42 v=73,-32
    \\p=75,68 v=64,-69
    \\p=85,25 v=26,-75
    \\p=65,98 v=56,-56
    \\p=96,83 v=-24,-60
    \\p=71,12 v=-70,-51
    \\p=25,30 v=-4,52
    \\p=38,21 v=82,62
    \\p=0,34 v=-73,-33
    \\p=77,23 v=35,-76
    \\p=68,33 v=51,41
    \\p=83,91 v=6,-66
    \\p=63,84 v=68,23
    \\p=98,5 v=-75,-74
    \\p=35,23 v=44,87
    \\p=92,25 v=-8,-34
    \\p=39,95 v=-27,94
    \\p=1,102 v=11,3
    \\p=22,79 v=-55,-72
    \\p=80,28 v=-94,21
    \\p=57,70 v=22,45
    \\p=2,56 v=-64,-2
    \\p=96,24 v=50,-45
    \\p=93,74 v=-81,56
    \\p=68,25 v=-22,-39
    \\p=61,46 v=50,-58
    \\p=1,101 v=-77,85
    \\p=44,58 v=-30,-70
    \\p=50,101 v=41,-17
    \\p=90,40 v=35,-48
    \\p=36,68 v=40,57
    \\p=96,86 v=18,38
    \\p=64,38 v=-87,9
    \\p=71,21 v=-43,45
    \\p=46,97 v=-6,60
    \\p=10,102 v=-94,-57
    \\p=51,81 v=56,26
    \\p=36,18 v=-41,-6
    \\p=78,0 v=-91,1
    \\p=92,93 v=96,42
    \\p=83,31 v=83,29
    \\p=61,25 v=43,75
    \\p=61,94 v=76,81
    \\p=41,99 v=87,-68
    \\p=94,16 v=-83,-43
    \\p=56,51 v=-86,90
    \\p=84,15 v=20,-5
    \\p=15,97 v=-39,60
    \\p=66,27 v=43,-74
    \\p=60,95 v=28,85
    \\p=61,41 v=-29,-71
    \\p=23,9 v=-43,-81
    \\p=9,72 v=47,-57
    \\p=54,50 v=-16,-83
    \\p=61,35 v=-6,-80
    \\p=17,37 v=-83,19
    \\p=12,68 v=-5,31
    \\p=85,100 v=-16,-66
    \\p=37,1 v=-85,16
    \\p=18,66 v=-63,1
    \\p=20,35 v=-91,-37
    \\p=54,56 v=65,56
    \\p=96,16 v=33,5
    \\p=94,8 v=95,62
    \\p=98,59 v=84,10
    \\p=16,80 v=-3,-32
    \\p=79,95 v=-58,27
    \\p=64,24 v=-70,-70
    \\p=53,1 v=80,-31
    \\p=23,88 v=-55,-55
    \\p=75,95 v=56,39
    \\p=6,39 v=20,-92
    \\p=36,23 v=95,-6
    \\p=30,100 v=96,26
    \\p=8,10 v=-18,-40
    \\p=69,7 v=-14,96
    \\p=37,24 v=16,-29
    \\p=63,12 v=-58,-74
    \\p=39,88 v=28,16
    \\p=33,56 v=67,11
    \\p=68,30 v=28,88
    \\p=82,40 v=-52,66
    \\p=4,87 v=62,-55
    \\p=75,9 v=-37,17
    \\p=54,77 v=-74,-4
    \\p=87,63 v=-9,-92
    \\p=56,96 v=-18,70
    \\p=49,9 v=37,3
    \\p=13,42 v=91,43
    \\p=20,48 v=89,-26
    \\p=12,51 v=-46,-12
    \\p=44,68 v=-28,46
    \\p=24,20 v=25,67
    \\p=31,91 v=-9,-22
    \\p=35,11 v=-55,65
    \\p=57,5 v=-57,15
    \\p=28,31 v=2,-5
    \\p=82,6 v=-82,-63
    \\p=53,7 v=-93,4
    \\p=69,102 v=64,-6
    \\p=16,4 v=97,49
    \\p=86,36 v=96,-80
    \\p=28,4 v=-5,4
    \\p=45,101 v=-64,-44
    \\p=98,21 v=-13,30
    \\p=25,35 v=18,-5
    \\p=13,0 v=-60,-27
;
