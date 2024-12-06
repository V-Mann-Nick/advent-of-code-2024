const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    const start = std.time.microTimestamp();

    var total_found: u16 = 0;
    for (0..ROWS) |y| {
        for (0..COLUMNS) |x| {
            const coord = Coordinate{ .x = x, .y = y };

            const is_top_left = y == 0 and x == 0;
            const is_top_right = y == 0 and x + 1 == COLUMNS;
            const is_down_left = y + 1 == ROWS and x == 0;
            const is_down_right = y + 1 == ROWS and x + 1 == COLUMNS;
            if (is_top_left or is_top_right or is_down_left or is_down_right) {
                total_found += scanFrom(coord, Direction.Left);
                total_found += scanFrom(coord, Direction.UpLeft);
                total_found += scanFrom(coord, Direction.Up);
                total_found += scanFrom(coord, Direction.UpRight);
                total_found += scanFrom(coord, Direction.Right);
                total_found += scanFrom(coord, Direction.DownRight);
                total_found += scanFrom(coord, Direction.Down);
                total_found += scanFrom(coord, Direction.DownLeft);
                continue;
            }

            // From Top Border
            if (y == 0) {
                total_found += scanFrom(coord, Direction.DownLeft);
                total_found += scanFrom(coord, Direction.Down);
                total_found += scanFrom(coord, Direction.DownRight);
            }

            // From Right Border
            if (x + 1 == COLUMNS) {
                total_found += scanFrom(coord, Direction.UpLeft);
                total_found += scanFrom(coord, Direction.Left);
                total_found += scanFrom(coord, Direction.DownLeft);
            }

            // From Bottom Border
            if (y + 1 == ROWS) {
                total_found += scanFrom(coord, Direction.UpLeft);
                total_found += scanFrom(coord, Direction.Up);
                total_found += scanFrom(coord, Direction.UpRight);
            }

            // From Left Border
            if (x == 0) {
                total_found += scanFrom(coord, Direction.UpRight);
                total_found += scanFrom(coord, Direction.Right);
                total_found += scanFrom(coord, Direction.DownRight);
            }
        }
    }

    print("Found: {}\n", .{total_found});

    const end = std.time.microTimestamp();
    const micros = end - start;
    const millis = @as(f32, @floatFromInt(micros)) / 1000;
    print("\nExecution time: {d:.3}ms\n", .{millis});
}

const XMAS = "XMAS";

pub fn scanFrom(coord: Coordinate, direction: Direction) u16 {
    var coordinates = coord.iterator(direction);
    var found: u16 = 0;
    var xmas_idx: usize = 0;
    while (coordinates.next()) |c| {
        const char = c.getChar();

        if (XMAS[xmas_idx] == char) {
            xmas_idx += 1;
            const is_complete = xmas_idx == 4;
            if (is_complete) {
                found += 1;
                xmas_idx = 0;
            }
        } else {
            xmas_idx = 0;
            if (XMAS[xmas_idx] == char) {
                xmas_idx += 1;
            }
        }
    }
    return found;
}

const COLUMNS: usize = 140;
const ROWS: usize = 140;

const Direction = enum { Left, UpLeft, Up, UpRight, Right, DownRight, Down, DownLeft };

const Coordinate = struct {
    x: usize,
    y: usize,

    fn toInputIdx(self: *const Coordinate) usize {
        return self.y * (COLUMNS + 1) + self.x;
    }

    fn getChar(self: *const Coordinate) u8 {
        return input[self.toInputIdx()];
    }

    fn getAdjacant(self: *const Coordinate, direction: Direction) ?Coordinate {
        switch (direction) {
            .Left => {
                if (self.x == 0) return null;
                return Coordinate{ .x = self.x - 1, .y = self.y };
            },
            .UpLeft => {
                if (self.x == 0 or self.y == 0) return null;
                return Coordinate{ .x = self.x - 1, .y = self.y - 1 };
            },
            .Up => {
                if (self.y == 0) return null;
                return Coordinate{ .x = self.x, .y = self.y - 1 };
            },
            .UpRight => {
                if (self.x + 1 == COLUMNS or self.y == 0) return null;
                return Coordinate{ .x = self.x + 1, .y = self.y - 1 };
            },
            .Right => {
                if (self.x + 1 == COLUMNS) return null;
                return Coordinate{ .x = self.x + 1, .y = self.y };
            },
            .DownRight => {
                if (self.x + 1 == COLUMNS or self.y + 1 == ROWS) return null;
                return Coordinate{ .x = self.x + 1, .y = self.y + 1 };
            },
            .Down => {
                if (self.y + 1 == ROWS) return null;
                return Coordinate{ .x = self.x, .y = self.y + 1 };
            },
            .DownLeft => {
                if (self.x == 0 or self.y + 1 == ROWS) return null;
                return Coordinate{ .x = self.x - 1, .y = self.y + 1 };
            },
        }
    }

    fn iterator(self: Coordinate, direction: Direction) InputIterator {
        return InputIterator.init(self, direction);
    }
};

const InputIterator = struct {
    current_coordinate: ?Coordinate,
    direction: Direction,

    fn init(coordinate: Coordinate, direction: Direction) InputIterator {
        return InputIterator{ .current_coordinate = coordinate, .direction = direction };
    }

    fn next(self: *InputIterator) ?Coordinate {
        const coord = self.current_coordinate orelse return null;
        self.current_coordinate = coord.getAdjacant(self.direction);
        return coord;
    }
};

const input =
    \\SSSMMAASASAMXSSMSMMSSSSSSMSSMMMSMSAXMAMASXXXXMXMXSXXXMAMMSSSSSSXXAMXMSSXMAXMMXMMSSSMSAMXMXSXMSMSSSXMMSAMMSAMXMSMMMXSASMMMXMXMMXXAMXXMASXMXMS
    \\AMAASMMSASASAAMMAAXXAAXAAAAXASAAXSAMXSXASMSMAMSMASMSMXAXSAMXAAAMSXXAMXAAMXSAMAAXSAAAMAMAMASMMAASAXSAASAMXAAXAXAMAXXXAXAASMMASMASXMSXSAMAMMMS
    \\MSSMMAAXASAMXMMSSSMMMMMMMMMXAMMMMSAMAMMXMAMSAMAMXSAAASMMMASMMMMMAASXSMSAMXAASXSMMMMMSAMMMASASMSMAMMMMSAXMSMSMSMSMSMMMMSMXAXASXAAAMAMMASAMAAM
    \\XXAMXMMMMMMMMXXAAAXMSAMXSXMASXSXXSAMXSSXMAMXMSMXAMMMXAMXSAMAMAXMMXMXAMXAAMMXMAAMXAAXXXSXMASMMMMMXMMMASAMXXXXXAXAMAMAAAMMSSMASMSSSMASXXMXSMSX
    \\MMMMSMMMXMSASAMMXMXMMMXAMAMXXAMMXXXXSAMXSAMAMAMXMASMSMAXMASMMXSAMAMSSMMMMXXXMMMMMXSSMSMAMASXMASMMSXMASMAMMMSXMSXSASXSMSAAAMSMMAAAMMMXXAAXAMA
    \\AAAAAAAMAMXASMXAASXSAAMSSMMSMAMMAMSMMAXXAMSMSASMSMXXAMSAXXAAAASMMXXAMXASASXMMASASAAXMASAMASASASAMXSMASMSAAAAAXMXMASMMAMMSSMXAMMMMMMASMXMMAMM
    \\SSMSSSMSASMAMXMSMSASMXMAAAAMXMMMAXAASAMXMMAASASAASMSXMAMSMSMMXXASXMASXXMAMXSXAXASMSMAMSXSXXXMASMMMMMXSAXMMSSMMXAMAMAMAXXAAMSMMSXMAMASAAXAAXX
    \\XXAAMAASAXMSMSAMXMMMMSMSSMMSMXSXMXSXMASXXMMXMXMXAMMAMMMMAMAMSSMAMAMAMMSMMMAMMSXMSAMXMXMMMMMXSXSAAXASMMMMSXMAMSSMXSSSSMSMSSMAAAMAXXMASXSXXXXX
    \\XMMMSMMMSMAAAMAMAAXXAXMMMAAAXMSASAMASAMMMXMXSXMMXSXSAMXSMSMSAAAMSSMAXAAMAMAMXAASMMMAAAXAAAXMSASMMMMSAAAMAXXAXMASAXXAAXXAMAMSSMSMMMSAMAMASXMS
    \\SXMAMXAAXMSMMMAMMSMMMXSMMMSSSMSAMASAMXXSXASAMXXMAMMMXMASXMXMMSMXAXSMSSMSXSASMSSMAASXSXSMSXSAMXMAMSMMMMSSMMXSMMAMMSMSMMMMSAMXAXAAAASAMSAAAAAX
    \\AAMSSSMSSXMASMMMXAMAXAAAMAMXXAMAMXMMMSAMXXMAMXXMASAMAXAMMMMSMMMMMXAMAMXAAMASXXMMSMSXMASXAAMXMAXAMAAMMMAMXAMMAMSAAMXXMAMASAMXSMSXMASXMXMASMMM
    \\MXMAAXAMMMMAMAAASMSAMMSMMMSAMMMAMMAMAMASXMSAMSXSASMSXMASXAAMMASMXXMMSSMMSMASMSXAMXMXMAMMMSMMSSSMSSMMAMASMSASAMMAMXASXSMASASXXAMXMAXMSMSAMXAA
    \\XMSMXMMXAXMAMSMMMXMASAAXAXMXMXSASXAMMSXMAMMXSMASAMASXAXXXMMMSAXMMMMAXXAXMMAXAXMXSAMMMAXXMXAMXAAXAXASXSAMXXMSXMXSXMASAAMAXXMAMAMXMASXXAXAXSSS
    \\XAAMMSMSXSMMMXASXXSAMMSMSMSXMASASXXMAMMSMMSMSMAMXMAMMSSMMSSXMMSAAAMSSSSMXMSMMMMAMAMAXMXSASXMMSSMMSXMAMMSMMAXXMAMAMAMMMMSSSMSMAMXMASAMSMMXAAX
    \\SSMSAAXAXMAMAMAMAMMAMAAAXAXMMMSASMSMAAAMXMAAMMAXXMXSMMMAAAXAAAXMMXSAAMMAAMXSXAMASXMSMSAXMMSXMAAAMXMASAAAAMMMMMASXMASMXAAAAAASMSMXSMXMAASMMSX
    \\AAXMMSAMXSXMMSSMSMSAMMSSMSMAAXMAMAXSSSSXMSMSMSXSAMASAXSSMSSMMMSMSXMMSMASXSAMXXMASXAXXMAMSAMXMXSSMXAAXMSMSMAAAXASMSSSMMMMXMMMMXAMXMAMSSSXXMAM
    \\XMMMSMMAXXMSXAAAMASXSAAXAAASXSMMMMMXMAMAAAAXXAXSAMASXMAMMXAMXXXAAAXAMXAMAMASMMSXMXSMSMAMMASXSAAAAXSXSMMXMXSXSAASAMXMXSMSXSXAMSMSMMAMAXMXMASX
    \\XMAMAASMMMAXMXMMMAMAMMSMSAMMAXMXAXMAMAMMSSMXMSMSXMASASAMMSAMXXMXSSMSSMASXXAXMAXAXMMAXMAXMXSAMMMMMMMAMASAXAXAXMSMXSAMXMAMAASMXASAASMMXSMSMAMX
    \\ASXSMXMAAMSXSXSXMASXMAMAMMMMAMSSSMSASMXMAXMMAMAMXMAMAMMSAMXMMXMAMMAXAMAAAMSMMXSASMMAMSSXSAMXMMXSAMMASAMMMMSAMXXMAXAXAMAMXMAMSMSMXMAXXAAAAASX
    \\MAAXMXMMSMMASAMXMAMAMXSAMASMMSAAAXMAMAAXAXMASMMMSSSMXMXMASXAXAMXSXXSMMSMXMMASAAAMXAAXXXAMXSMSXMMAXSXMASXAAXAMXSMSMSMSSMXAMAXSXMXSAMXSMSMSMSA
    \\XMMXAAMXMAMMMMMAMASAMXMAXAMAXAMSMSMSMSXMASXAXAAAXAAAAAMMMAMSSMSAMMMXXAMXSMSAMAMSMXSSXSMSMSMAXAMMSMSASAMMMXSXMAXSAAMXMAAXSSSMSAMXXAXAXMAMXMXM
    \\SAMXSASASAXAAMMXMASAMMSMMXSXMAXAAXAMAMXXXMMMSSMSSMXSSMXAXMAXAMMMSAMMMSSMMXMAMXXMAXXAXSAXMASXSMMMMAMAMAXXAAXXMASMMMMAXMMMXAXASXMSSMMSMMMSMXSM
    \\SAXAXASXSASXSSMSMMMAXMAXXMMMAXMMXMXMAMMSMMAAMAXAXXXMAMSSSSXMMMAAMMSAAMAMSSSSXMASMSSSMMAMSMSXXAAXMAMASXMSMMSASXMASASAMMSSMAMMMMMMAMXMASASMASA
    \\SMMSMAMAMXMXAAAXXMMSMMXXSAAAMSXMXAXMASAAAMSMSAMMXMSMAMXAXMASXSMXSASMMSAMXAAASMMMAMXAXSAMXXXXSXMMSAXXMXMXAMSAMXMMSXMASXAAMXMASASMXMASMMASMAMX
    \\XMAXMAMXMSXMSMMMMSAMASAAXMASXMAASMXSXSMMXMXASXMMMAAXAMMAMXMMAAASMMMSMMMMMMMMMMAMAMSMMMMSXMMXSMXXMXSSMMMMMMMMMMMAMAMAMMSMMMMASXXMASXSXMMMMMSS
    \\XMASMSSSMXXXASAAXMASAMMSMMXMASXMSAMSXMAXAMXXMAMXSSMSMSAAMSMMXMXMAAAMXASXMASMASAXAMAXAAASAXAAMXMMSMAXAAXAAAASAMMAXMMAXXAMXSXXMAMSMMASASMXXAAX
    \\MMMSAMAXXXMXASMMSMXMXMMAXXAMXMXAMAMMASAMMMSMSXMAXAAAMMMMMAAXMMMSSMSSMXSXMAMMAXMSSSMSSSMSAMSSMAAMAAMMXSXSSSMSASXMMAMAMSASASAMXAXSXSXMMAXMSMMS
    \\AAAMAMAMXMSAMMMMAMMSMMMSMSSSMSMMMAMSMMXSAAAAMXMXMMMMSAAXSSXMMAAXXAXXMMSXMASMMSMAMAAAAMAMAMXAXMXSMSXSAXXXAAASAMAMSSMAXSAMAMSAMXMMAAAMAMMMAAXX
    \\XMXSAMXSAAMASAXSAMXAAAAAASAAAXAMSSMMXAASMXMXMAMMSMMXMMMXAXAASMSSMSMMSASAMASAMAMASMMMMSXMAMXMMXAXMAAMASMSSMMMSMXMAAMSMMAMAMXXMAXMAMAMAXAXSSMM
    \\ASASXXXMAXSAMXMSSSXSMMSSMMXMMMXMAXAASMMSXASASASAAMASMASMAMSXMXAXAAAMMXXAMASAMMSAMXAXMSASMSMSAMMSSMAMAMAXAMXMASAMXSMXASXMXXSAMSMMMSASASMMMAAA
    \\MMASAMSXSAMXXXXMASXMAXAMXSAMXAAMXSMMXAAXMASASXSXXXASMAXMXMXXSXSMMMSXMMSMMAMAMXMASMXSASAMAAMMASAAAASMMMMSAMXSMXXSMXXMAMAMSAMMMMASXMXSAMXASMMS
    \\AMAMASAAMXSMSSXSAMXMMMAXASASMSXSAAAASMMSXXMXMASASMMMMXXMAXXXMAXAMAMAXMASMSSSMSMMMAAMMMAMMMXSAMMSMMXASAASAMMSXSAXMASMSMXSAMSSMXAMAMXMMMSAMAMX
    \\XMXSXMMXMXXAAAMMMXMASMXMXSMMAMAMXXMMSXAXMASXMXMAMASMMSAXMAMAMAMAMASXMSASXAAMXMASMSMSXSAMXMMMAXXAMXXXMMXSXMAMMAMMMAXAAXMXAXMAAMSMSMAAAAASXXMM
    \\SXMAMSSMMSMMMSMAMMSAMAASMMAMMMAMMSMSMMAMXXMASAMASXMAASASMSMXXMSMSASXAMAMMMSMAXAMAMXSAAMSMMAMMSSSSSXSMSASMMSSXASAXXMSSMAXMMSMMMMAMASXMXSASMXS
    \\ASAXXAAAXXXAXMXMSASAMXMXAXXXAMXMAAXAMXSXSMSMSASASAMMMMAMAXMMXXAAXAXMXMAMAXMXMSMMXXAMMMMAMXASMXAMAMASAAAXMAXAMAXMAXMAMXSSMAAAAAMAMXAMXMMMMMAX
    \\MXSMMMXSMMSSSXSMMXSSMMXSSMSSMSSMSSSXSAXAMAAASAMMSMSSSMMMXMASMMXSAMMMAMASXXAAXAXXAMSSMXSAXSASXMAMXMAMMMXMMMXMMSXMSXMASAMAMSSSXSSSSSMSAXMXXMMM
    \\XAAMAXXMAAMAAASXSXXMMMAXMAXAAAAMAMXAMXMAMSMXMAMXMXAAASAMXSXMASAMMMAXSSMSMSSMSXSMMXAAMMSAMMSMMSMMMMSSSMXSXMXXXXXSMASAMMXAMMXXMAMXAAXSASMMMMSS
    \\MMXMMSASMSMMMMMAXAMMAMMMMMMXMMSMAMMXMMSMMMXMXAMXSMMSMMSAMXSSSMXSSSSSMAAXXAAXMXMAMMSSMMMXMXMXAAMAAXXAMMAMMMAMXAXASXMXASXSXSASMSSMXMASXXAXXAAX
    \\MSSMXSMMAAMMMSMXMMMSAMAASASASMXMSXMASAAMXMAMMMXXXMAMXMAMSAXMAMAXAAMMMMMMMSSMXAXAMMAAAXSXMASMSMSSSMMSMMAXAASMMMSMMXSMXSAXXMASAAAMSAMXXSMMMMSS
    \\XAAAAXXMXMMAAMXSMMASASMXSASASAXXMASASMMMXSSSXSASMSASMMMMMAMSAMXMMSMSAMXAMMAMSMSMSMSSMMSAMASAMAAAAAAAAXXSSMMAAAAAMSXMAMXMXMAMMMSMMXMAXMXSXAAX
    \\MSSMXXAXXXSMMSAMASASAMXAMAMMMMMXSAMASMMSAAAAAAAMAMXAAASAXXMXAMXMAMAMXSXSMSMXAAAAAAXAXASAMASXMMMSMSSSSMMXMASMMSSSMSMMASASAMMAMXAAXAASXMAMMMSS
    \\XXXAMMMMSMMSSMXMAMXXMMMXMAMAAAMAMXMXMAAMMMMMMMAMXMXMSMSASXSXSMAMXSAMASAMAAAXMMMSMXXAMXXAMAMAMSMMXAXAAAMASXMMAMAMASASASXSASMMSSXSMMXMSMASAMAM
    \\SAMXMASXMAAXXAAMSMSXMXXMSSSSXSMXXSMSMMMSMMAMSAMAMXMXMASAMAMAMMASXXAMASAMSMMMSAMMXMMSMXSSMSSSMSAMMMMXMMMAMMSMAMSMMMXMXSAMAMAAMAMMMSAMXSASXMAS
    \\AXSMSXSASMMMMMMXMAXAMSMXAXAMAMXSXSASMMMAXMAXAAXMAAAXMASAMXMAMSASASMMMMAMXMXAXAMAAMXXAMXXAXAXAMSMAAMSSSMMMAAMAMAAXMMXAXXXAXMMMSAAAXMAMXXMMSMS
    \\MSXAXASAMMSAMASASAMXMAAMXSAMXMAMAMAMMXMASXSMSSMXSXSMMMSAMXMMMMAXAAXXXSAMSSMASXMSMSMSMMXMXMMMXMASMMSAAAASMSSSSSSMMAMMXXSMSMAAAXSMMSMXSMSMXAAX
    \\XAMSMMMXMASASASASAMXAXMMMMXXXMAMSMSMSXMASAXAMMMXMAXAAAXAMSMSSMSMSMXSAAXXAASAMAXAAAAMMMAMAMXAAMMAMSMMSMMMAAAXAAAMSAMASXSAASMMSMMMMAMMSAMXSMSM
    \\AXAAMAMMMMSAMAMXMAMMSMXAAMAMMSAMXAAXSAMAMXMASAMSMMSSMSSMMXXAAXXAAAAMXMMMXXMXSAMMMMXMASMSSMSSXSXSXSAAMXSMMMSSMMMMSAXXXAMMMSXAAAAXXMASMXMMMMXA
    \\MXXXSASAMXMXMXMXSXMXAASMMXAAAAAMMMMMSAMXMAMXSAMXAAXXXMAMAAMSSMMMMMMMAAXMSMMAMAXXMSASXSXAAMAAXSAMASMMSASASXXXAMXXSXMSMXMSXSMSSSMSXXMXXSXSXASM
    \\MAXXAMXXXMASXSAMXASMMXMAASMSMXSMAAXMSAMASMMASXMSMMSMXXAMMMAXXAMAMXSXSMSAAAMXSXMSAMXSASMSSMMSMMAMAMMXMMSAMXAXSMMXMASXAXXAASAAAAAAXSXMMAASMMMA
    \\MAMAAMSXSAMXAAMASAMASXSMMAMAMMAMSMSASMSMASAXSAMXAAXXAMMXMASXMSMSMXMAMXMXMSMAMAAXMMAMXMAAXMAMASXMASAAXAMAMMSAAMAASMAXMMSMMMMMXMMMXSASMMXMASAX
    \\MSSMSXMASAMMXMAAMAMAXXXXSMSAMSAMXXMMXAXMASMXSMMSMMSMXSAAXAMAAAXMXMSMSASMSMMASMMMXMAXAMMMXMSSMMMAAXMSXMSMMAMMMMSXSXMMAAXAXSXSXMASASXMSAMXSMSS
    \\MAAXAAMAMAMAAXMXSMMMXMSXSXMAXMAMMAMXMMMMAXXAMXAMMXAAAMMSMASMMMXMAAXXMAMXAXSMXXAAAMXSXSAXASMMMASMMSAXAXAASXSAXXXXMAXXMSMXMSASASXMASXMMXAMXAXX
    \\MSSMSXMASAMXXXMXSXAXSMSAMXSSMSMMSAMAMSAMMSMMSMXSMSMSMMAXXXMASXAXASXXMAMMSXMXXSMSSMMAXMXMXMAASXMAXXAMAMMMSASMSMMAMSMSMMMXAXAXAMAMAMXSAMSXMSMM
    \\MXMAMXXMSMSXSAAAMMXMAAMXMAMAMXMAMASAMSAMMAMXAMMAXMXAAMASASAMXSMMAXAXSAMMMASAMAMAAASMSSMSASXMSMMSMMSMMMMAMXMAMXMAMMASAAAMSMXMASXMXXAMAMXAMAAX
    \\SAMAMAMXMAAASMMAMSSSMXXSMXSAMAMASMMXXSMMXSSSXSSMASMSSMSXAXXMAAMMSMSMSASXSAMASAMXSMAASASAMXAAXXAASAMAMXMASXMAMMSXSMAMMMMMAAXSAMXXXMMSSMSXMSSM
    \\XAMASAAAMMMXMXSXSAAXXSXAAASAXXSAXXMSAMXAXMAMSXAXMAAAXXXMMMSMMMXAXAMAMAMXMXSMMMXXAXMSMSAMXMMMMMSSMSSXMMSASAMSSMAAXMAMMXSMMMMMAMMSMAAAMMXAAAAA
    \\SMMASXSMSXMASAMXMMSMSMMMMMXAMMMMXSXXXMMMSMAMMSAMXMMSMXAMXAMXMAMSMMMAMAMXSMSXAAXSAMXXMXXXAAXAXAMAAAXASAMXSAMAAAMMMMAMMAMMSMMSMMAAXMMSSMMMMSSM
    \\MSAMXMAXMAMASMSXXMMXAAAXAMMSMMASAXMMXMAXXMAMXAXAAXXAAXSMMMMAMAXXASXXMSXMXAMMMMXXMMSMMAMSMSMSMSSMMMMMMSXMMAMMMMMSXXSXMAMAAAXAMSSSXSAMAXXAXAMX
    \\XAXMSXMAXSMASAMMSMMXSXMSMSAXASAMMAAMXMAXMSMXMMXSMMSMSMMAASMXSXMSAMAAXXAMMSMAXMXMAAXAMAXAAXAXAAXAAXXSAMXSXMXXSAMXAMXASASXSSMAMAAAAMASAMMMMASX
    \\MMAMXAXAAMMMMMMASAAMMAMXMMXSAMXMXAMXAAMSAAMASXMMSMAXXXSSMSAMSAMMAMXMMXAMXMSSSMASMMSSMMXMSMXMMMSXMMAMASAMXMAASAMXSXSAMASAAAXSMMMMXSMMMSAAMMMX
    \\AXSMAMMMXMAMAXMASXMASAMAMXMMAMASXSSMSSMAMXSXSAMAAXSMSXXMMMAMMAMSMMMAAXSAMMXMAMXSAMAAAASXXXXSXMSXMXSMMMAMAMXXSSMAMAAXMXMMSAMXAXSXXXAAASMSMAAX
    \\SXXAASAXASAMXAMXXAMXSASASMSSXMXSAAXAMAXXSMSMSAMSMSAAXMMAASXMSAMXAAXMMMMAMXASMMMSAMSSMMSAAMXMAXMASAXAMSASASMAMAMASMSMSXSMXMASXMXXXSSMXSAMXMSS
    \\MAMSMSASMSASXAMAMAMAXXMXSMASMMMMMMMMMMXXAAXASXMAXSMSMAMSMSAMXMMSXMXSMSMSMSMSAXASAMXMXXXMXMASAMXMMMSAMSMSMSAXMXMMSAAAXAXMMAMAMXMMXMAXAMAMSMAA
    \\MAMXAXAAASAXXAMXSSMMSSMASAMXMAAMASAXAXXXMMMXMASXXXAMXSMMMSAMXAAXAMASXSAXAAXSAMXSXXXXMSMSMSASASXXAMMAMXXXMMXSMAMXXMMMMAMSAMXMAMAAXXSSMMSMAMXM
    \\SAMMAMMMMMAMSMXMAAAAXXMASAXSSSXSASMSMSMMXASASAMXMMXMAXAAASAMMMMSSMASAMSMXMAMAXMSAMMXAAAAAMAMAAMMSMSMMMSMASAMMAMASAMXSAMXSXMXMASMMMAAAAMSMSSM
    \\SAMMMAMXXMXMXXAASXMMSXMASMMAAMXMASMSXAAAXASASAXXMMSMMSSMMSASAAMAAMAMXMXMXXSSSMASXMMASMXMMMAMXMXAMXAAAAAXXMASASXMSASMMAMAMMMXXXMAAMSSMMXAMAMS
    \\SXMSAMXSXSMXMMXMMXAXXXSXXXXMXMAMXSAMSSSMMAMMMMMXAASAMAMXASASXSMMXMAMAXAMXMXAAMMMAXMAMXMSASASXXMMMSSSMSSSXSMMMMAXSAMASMMASASAMXSASAAAAXXAMASX
    \\XXXMASMMASAASMSSSSMSMXMAMXMMMSMSAMAMMMMXAAXAAASXMAMXMXXMMMMMMXMSSSMSSSMSMSMSMMMSSMMMSAMSASASMSXAAMMMMAAAXAXAXSAMXXSMMAMSXMMXMASXMMSSMMSAMXSM
    \\SMXSAMAMAMSMAAXAAXAAAAMAMAMXAAAMXSXMSASMSXSSMMXAMASXMMSAAASAMSAMXAAAAXAAAAAAXXMAAASAMXMSXMAMAMMMXXAAMMXMXMMMMSASMMSXXAMXXSXSMAMMMAXMAXAAAXXA
    \\AXAMAXXMAMAMMMMMMMSMSXXASXSMSSSMMXAXSASXMXAMMMSXMASAAASMMMSAXAMXSSMMSMSMSMSXSXMAXXMAXMASMMAMAMXMASXMSSSXMXASXSAAAAMMMSSMASAMXAMAMMMMSSSMMSSS
    \\SMMMXXAMXMMSMXAAXAXMAXSXMASAAXAMASXMMAMASMMSAMAAMXSMMMSAMMXMMSAMAAXXXMAXMAMXAXMASXSMMSASASMSXMAMMMAAAAAAXSASAMAMMXSAMAAMAMAMSMSXSMAXAXAAAXMM
    \\XAXAXXSMMMAAAXSMSXMMAMXAMXMMMSMMXMAMMAMXMAASASMXMAXXAXMASMXSAMAMSXMXXXMSMMSAMMSAMXAXXXMSAMXXASASXSMMMSSMMSAMXMMXSASAMSMMAXAMAAAASMMMMSXMSSSX
    \\SMMMSAMASMMMSXXAMXXMAMSSMMMAMMMMXSAMMSMMMMMSXMXAMXSMSXSAMMAMASXMAASAMSXSAAXAXMAMSXSMMMMMMMMSXMAAXAXXXXAMXMXMXAXAMMSSMAXSMSSXMMMSMAMMXSAMXAMS
    \\SAAXMAMAMXAXMAMAMSXSMXMAASMMXAXMAXXSXMASXMAXMXSSSXSAMMMAXMASAMXSSXMASAAMMMSMMMMXSAAXMAMAXAAXXMXMSMMMXMAMXSAMMMMXSAMXSXXXMAMMASMMMAMSASAMMAMA
    \\SMMSSXMASXXSMMMAMXAMXAMSMMASMMMMXSXMASAMAMMSXMAAXAMXMMSSMSASAMAMXMXMMMMMXMAMAAXAMSMMSSSSSMMSASMMAMAAASMMASXSAMSAMASASMSMMASXAXASXMSMASAMSMMM
    \\MASAMAXXXXMSAMSXSMAMSXMMAXAMAMSMXAAMMMASMMMMMAMMMSMSXAAMAMASAMMMAMASAMASXSASMSMXXAMAAAAMXXSAMXMSASMSXSAMASASXSMASAMAXAAAMASMSXXMAMAXXMXMASAX
    \\SXMASMMSMMASAMXAXXAMSMMMSMASAMAAXMAMXMXMXMAMXMXXXMASMMSMMSASXMXMAMAXAXASAMMMAAMXSASXMMMMMMSMAAXMAXAXASXMXSAMMXMAMMMSMMMXMASAMSSSSMMMAAXSXSXS
    \\XXSAMMAAAMASMMMMMSSXSAMAAMXMMSSSMMAMXSMSASXXSXMASMMMXXXAAMXXASMSSSMSSMMSXMAMMMSXSMMAXAXASAMXSXSMAMSMMMSMMMAMXSMMXSAXAMXSAMXXMAXAAMXAMSMSAMMM
    \\MMMMSMSSXMASMAAAMXMASXMSXMAXXAXAAXXSAAAMASMASXMAXAXMASMMXSXSAMXAAAAAMAXMASXSAAXMMMSSMMSMMSSXXMAMXXMAMAAXASXMXAAAAMMXAMXXASXXMXMMMMAMAXMMAMMX
    \\AAASAMXAAMXXXXSXSAMXMAXASMSXMMSSMMXMXSSMAMMAMAMASMMMXXXAAMAMAXMMSMMMXSMSXMASMSMASAMAMAXAAXMASMMMSMSAMSMSMMMMSSMMSSSSMMSSSMMXSMSXASMMSMMXSXXS
    \\SSSSXSMMXSMMMMMAMXXAMSMASMMAAAXXSXXMAXXMASMASXMAXAAXSMSSSSXSMMMAAMXSAMMXMMXSAAASMXSAMMSMSSMAMAAXMASXMMXSAMAAAAMAMAMAAAAMXAXAXAASAMXAMAXAMMMM
    \\XMAXASMMAXAMXAXXXMSMSAMXMAMSMMSAMMSMXSAMXMMAMXMXSMMSXAAXXMAXMAMASXAMMASMXSAMXMSMAXXXMXAAXAMXMSMMSMMMAMAXXXMSSSMASMSSMMSASXMMXSMXXXMMSSMMSAAS
    \\XMAMMMAMXSSMXMXAXMAMAMSSMAMXMXMXMAXXAMAMSSMMSAMASMMMMMMSSMMMSMSAMMXXSASAAMXSXXAMXMMSSSMSSMMSAMXXXAAXXMAMMSXMAXMXSMAAXAXMXXAAAMXMXSXXMXMAMXMX
    \\XMAXXXMMMMXAMMASMMASMXXASXSMMAMAMMSMMSAMMAAXSXSASAAMXAXAXAAXXAMASXSMMASMMMMXMSXMASXAAXXMAMAXMAMXSXMSSMXSAAMMMMMXMXSMMXSMSSMMMMAXAMMMMAMASMSM
    \\SSSSXSAAAMMMMMAXASAMXXSAMSAASASASMSXMAMXMSMMMXSMSMMMSSMMSMMXMMMMMMSXMAMAAXMMAAASASMSMSMSAMASMXMASXMAAXAMXSMASAMASAMASAAAAXAAMXAMXMAAXSSXSAAS
    \\MAAAAMSAMXAAAXASMMMSMMMMSMMMSAMASXXAMMSSMMAASAMXSXMXXAAASASAAXAXMAMAMXSMMSAASMMMMSAAXAASXMASMSMAMAMSSMXSAMXAXAXASASAMSMMMSSMSAMSSSSXMMAMXMAS
    \\MMMMMMMMMSXSXSMXASAAMAAXAAAMMXMXMAMMMAAAASXMMASAXAXMSMMMSASASXSSMASAMMMMAAMMAXXAXMXMXMXMXSAMXAMASAMAMXMAMSMSMSMXMAMXMMXAAMAAAMXAAAAXSMXSMMXX
    \\XAAXAMXMASXMASXSSMSSSXXSSSMSAXMMSAMSAMXSMMMXSMMMSMMAAXAAMAMXMXMAXASXSAAMSSSSSMMSSSMSMSAAXMASMMMAMXMASAXAMXAXAXXASXMMAXMXSMMMMXMMSMMMSAASXMMM
    \\SMSXMXAMMSAMMMAXMAMXMAAMAMXMASMAMMXSASAXAAXAMAAMAMMSXSMXSMMXMXXAMMSMMMMXAAMAASAXAMAAASMSMSSMAAMSSMSASMSSSMAMAMSASAMSXXMAMXSAMXXMAXAAMMMSAASX
    \\MAMAMSXSASAMXMSMSXMAMMMMAAAMASMAXMXSAMXSSMMSSSMMAXXMMSMMSAASAMMAXXSAMSMMMXMSMMMSAMSMMMXAAMAXMXMXAMMXMMXAAMAMAMXXSAMAAASXMAXASXMSASMSMMXXMMAA
    \\MAMAMAAMMSMMMAMXXAMSMSASXMSMASXAXSAMAMMMXAAXMAASMXMAAXAAMXMAAMXMSMMSMAASXSXXXMXMAMAMXSMMSSMSMMMSSMMMSSMSMMMSAMXAXAXMSMMAMSSXMAAMASXMAASMMMMM
    \\MMSAMMXMXXAAAXSAMMMXASASAAXMASMXXMAMAMXAMMMSMAAAXAXMMSMSSMXSSMAXAAAAMXMMAAAMXAMXXMMMASAMAAXXAAXAMXSAAAAMXMASASAMSMMMMASMMMXMMMMMXMASMMMAMXXX
    \\SMSXSMMSSMSASMMAMXAMXMAMMMXXXXAXSMMSMSMMMSAMXXMAXSMSAXAMXAXMAMXSMMSSXXXMXMMMSSMMSSXMASAMSMMSSMMMSASMMMMMSSXSXMXXAMSXXAMXAXAXXAAXAMASAMSSMMSS
    \\SASMAXAXMAXAMXMAMXMXSAMXSXXXSMSSMSAAXAAXAMXSMSMSXXAMXMAMMSMSASMSXAXAMSMMSASXMAASASAMXSXMAXAMAXMXMASXXXXAAMXMXMASMSMAMSMSMSMSSSSMXMAXAMMASAAA
    \\MAMMMMSSMSMSMAMXSXAAAAMAMMSXMAXAAASXSSSMXSAMXXAMAMXMXMAMAMXMASAMXMSAMXAAMXXAMSMMASXMAMXXMMMSAMSAMXMAAXMMXSXSAMXSXAMMMAAAAAMMMAXMXXXSSMXMMMSM
    \\MAMMXMXAAXAXXXSAXMMSSSMAAASAMXMMMMMXAAMAAMASXMAMAAXSXSSXSAMMMMAXAMXXMSMSSMSSMAMMAMAMASMMXAXMAMSASAMAMSXSXSMSMXAMMXSMSMSMSMSXMASMMSMAMASXMAMA
    \\MAMMASXMMMXMMXMMMSAAXXASMASAMSMXSASMMMMMMSXMMAAMXMMXAMXAXAXAXXSSMSASMXAXAAAMMAMMASXSMSAMSSSSSMSAMAMAXAASAMASXMAMXXXXAXMAMAMXMAMAAASMXAMAAAXX
    \\SSXSASAXMASXSAAXAMMSSXMMSASXMAXAMAMAXXAAMXMMAXSSSMMXSMMMMASXSMMAAMASAMXSMMSSXMMSXMASMMAMAAXAAAMXMXSSSMMMAMAMMSMSMMMSXXSASASXMMSMXMSXMASXMXAM
    \\SAAMAMAMMSXAASMMSSMMMMMAXMXXXSMSXSSSMSMMXAAXSXAMMAMAXAAXAMXAMASMMMSMXMAAXAXMASAMXMASASXMMMMSMMMSMXMAAXSSXMXSAMXAAAXMAXMASAMXMXAASMMMSXMXSXSM
    \\MMMMSSXMXMMXMASAAAAAAAMMSSSMXXAAAMAMXSXSMMMAXMMASAMMSSMSSSSMXAMAXXAAAMXSMSMSAMAMXMXSMMXSXXAMXASAMAMSMMASAXAAXMSSSMSMMMMMMXMASMMMMAAMSAMASMAS
    \\SSXXAAASASAAXMXMXXMMXMSAAAAMMMMMMMAMASAMXSMXMAXASXMXXXAXXAAMMSXMMAMXMAXXAMAMXXAMMAMXAMASXMASMMSASMMAAXMSXMASAXMAMMAASMXAAASXSAASMMMXSAMAXSAM
    \\XAMMMSXMASXMSMMSSSSMSAMAMSMMAAAXXMAMXMAMAXAASXMMMMXSMMMMMMMMAMAMXXXSXXAMAMXMSXMXXAAXMMASAMAMAMSAMXMSMMXSXAMXMAXMXXSXMXSXSMSASMMSAXMASXMMMMMS
    \\XAXXMAMMAMXMXMAXXAXAAMSAMXXSXSXSXSXMAMAMXMMMSAAAMSMSAAAAAAAMASAMASAMXMSSXMAMXASASXSSXMXSXMMXAMMXMXMAAMMXMMMSMSSSMMMAMAMMAAXXMAMSMMMMSAMXMMSX
    \\SMMMSAXMASXSAMSSMMMMMXSASXMSAAASAAASASMSMSSMSMMMMAAXXMXSSSMSAXAMXXASXSAMAXMMSMMASAAXXXAMMMSSMSXMMASMSMXASAAAAXMASAXAMAMAMMMMSAMXXMAXSAAAXMAS
    \\XXAAXAMXXSAMXXXMXAAAAXXMMAAMMMMMAMAMXMAAMAAAXXSSSMSMSMXMXMMMMSMMMXMAMMASAMSMSAMXMMMMXMXSAAXAAXMASAMAAASASMXMMMMAMSSSSMSXSAXXXXXMXMXXMASXSXMM
    \\MMMSSXSXXMXMMMSSSMSSSSSSSMXXXMXXSSMSSMSMMSMMSMXAAAXAAMAMXMAXAAAAMAAAMSMMMXSAMXSSMXAAXMASMXSMMMMXMAMSMMMXXAMSXSMXSAXMAMAASXSMMMSAMXSMSAXAMMXA
    \\ASAMAMXMMAXXAXXAAAXAAMAAXAXSMMSMMAXAAAMXMXMASAMSMMMSMSSSXXAMSSSSXMXAMAAAMXMMMAMAASASMMASXASAMASXMXMXAXSXMSMXAMAMMXSAMAMXSASMAAMSASMAMASMXAMX
    \\SMMMASAMMSMSSSMSMMMMMMAMMXMAAXXAXMMSSMMASAMASXXXMXXXAAXMMXAXAAAMXXXSSSSSSMAXMAXMMMXMXMASMMSAMSAMXASMMMMMAMAMXMAMMSMMSXXAMAMMSSSMSXMXMXXMASMS
    \\MAXSAMMMAAMAAXAMXAXASXMXAXAXSASMMXAAAAMAMASASAMXSSMMMMSMMMXMMMMMMMMMAXAAAXXMSSSSSSXSXMXSXMMMMAASAMXAASXAAMMMXSXSXSAAXAMXMAMMAXMMXXMAMSASMXAX
    \\SAMMSMMMSSMMMMMMMSSMXASMMMSAMMAAMMSSSMMSSXMMSAMAXMAXAAAAAMAMXMXMXAAMMMMXMMSMMAAMXMXMASAMAMSAXSXMAXMMMMAMXSMAASXSASMMSXMSSSSMMSMASXSXXSAMAMMM
    \\MASXMMSAMAAAXSASXMAXSXMAAAMXMMSMMMMMMMAAAMMXSAMSSMSXMMSXMSASAMAMSSXSAMXSXMAAMMMMAMAXXMAMAMSAMXAMASMSSMSMMSMMXSAMAMAMXXXAAXXAAXMASMMMMMMMAAXA
    \\SXMXAAMXSSMMMXASASXMMSSSMMSAXXAAAXMASMMSSXXASAMAAMXXMMXXASAMMMAXXAASAXAAAXMXMAAXASXSMSSMSXMMMSAMASMASAAMAMASXMAMMSXMXSMMMMSMSSMASAMAAAMMAXAX
    \\XAMSMMSAXAMXSMMMMAMXAMMASXXXMMXSMMSMSXXAMMSXXAMXSMMMMAXMMMSMXSSSMMMSMMMSSMMMMSMSAMASXAXAMXSXAMAMXXMASMMMMSAMAMXSXMASXMAMAASXMAMXSMSSSMSXMAXM
    \\XMMAAAXMSXSAXAXMAXXMASMASXMSSSMXMAXAXMMASAMMSMMXMAMSAXSMSAAMXMXMXAASASMAXAAMMAMMXSAMMSMSMAMMMSMXSXMMSAXXXMAMMMAMAXAMAAAMSXSASMMMMAXAAAAMMSAA
    \\SMSSSMSXSAMMSSMSMMSMMMMAXAXAAAMMSXSAMXSAMXMAASXXSAMAAXSAASMSAMSSSMMSAMMAMSMSAMMAAMXMXXAAMAMAXAAASXMAXAMSXMSSMMXSSMSXSMMMMASAMXMAMXMSMMMSAXAS
    \\AMAMAMMXMXMAXAAMMMSAAXMASMMMSMMXMAAXAXMXXXMSSSSMMMMMSMMAMMXSXSAAAXMMMMMXMMSMAXMMXSAMXMSMSSSSSMMMSAMXMSMSAAAAXSAMXAAAXASAMMMXMASXSMAAMXAMMXAM
    \\MMXSAMAASAMSSMMMAAMMMXMXMAAAXXXAMMMMSSMSMSAMAMXMASXXMAASXMASXMMSMMXAXMXMAXAXMXXAAAMXAMAXXAAXXXAXSAMXXMASXMMSMMASMSMSMASMSAMXXMAAXASMSMSSSMMM
    \\XXAXAXSXSMSMAMASMMSASXSMSSMMSMSMXXAXXMAAAMAMAMASXSASXSXMAXAMMSMMAXSXSMSMSMMMSMMMXSXMXSXSMMMMMMMMMAXSMMAMASXMAXXMAXAAMXMASMMMSMMMMXXAAAAAMAAA
    \\SMSSSMMAMXAXAMMSAMMAMAMXAXXMAAAMXSSSMMMMSMXXAMXMAMASAAXMMMXXXAAMAMAXMASAMAXAAMSSMMXMAMXXMAMXXASASXMXSMASAMASXMSMXMMMXXMASXMAAAAXSAMMMXMMSSMS
    \\XAAAXAXXMXMMSMMMAMMSMSXMASMSMSSSMAAAAAXXMMMSSSMSSMAMMMXAAMXSSXSMXSMMMXMAMSMSXSAAXAMMAMXMASXSSMSASAXMAMAMASAMXXMAMMMSMMSAMAMSSSMSMASXMMXXXAXX
    \\MMMSMXMAXXMAXAXSXMAMAMXSAMXAMAAAMMMMSXMMMAAAMMXAMMXMXXXMASAXMAXMXMAMXMMXMXAXXMMSMMSSMSSXAMXAAAMXMASMMMMSAMXMAASMMSAAAASASMMMXMMAXMMAASXMSMMM
    \\AMXXMASMMSMASAMXAMASAMAMASXMMMSXMXAXXAMSAMMSSMMMSMSMSAMSASMAMSXMAXAMXXMXAMMMMSAMAMAAMAMMXSMSMMMMSMSXMXAAMASASAMXASXMMMSAMXAMAXSASXMSMMAAAMAX
    \\XSAMXMAMAAMMMMAMSMASAMMSAMAAXAXXMMMMMMMSAMXMAMMMAMMMMAXMAXXAXMASAMSMXASMXAAAAMASMMSSMASAMXAXAAAAAXSASMMSMAAMMAXMASMMSAMAMSXSAAMASXMASXMMMSSS
    \\ASAMXSAMSSSMAXMMXXMSXMXMASMXMASASXSAASASAMASAMASASAXMMMMXMXXSSMMSSXAMSXMSSMXMXAMAMMAXXSAMXSSXMMSSSSMMXMAMXSXSAMXSXMAMASMMAMMMMMXMXSAMXXXXAAX
    \\MXMAMMXMAAAMMMSAMMAMXXASMMXSXXSAMASMSMASXMXSMSXSASXSXMSSMSAAXASAMXMSMXAMAAAXSMMSSMMAMMSAMXMAXXAAMAXXXXXASMMASMMXMAMXSMMMMXXASMMMSXMXSMMSMSSX
    \\XAMSASMMMMMMAAMAMSMSMSMMAMMMXMMXMXMXMMXMMMMMMMMMXMAMXAASAMXMSAMMMSAAMSMMSSMMSAAAXMMAXXSXMMMAMMMSSSMMMSXMSAMXMAXAMXMMXMAXXXSASAAASASASAAXAAXX
    \\ASXXXMAMAMXMMMMAMAMAAMXSAMAMMMMXSAMXMMMMAAAXAXAMAMXMMMASMMXMMMMAAXAMMXAAMXMASMMMSSSMSAMXMAMXXXMXXMAMASXMMXMXSSMMSMSMMSXSAAMASMMXSAMASMMMMMSX
    \\AMAMMSAMASAAXSXSSSSMSSMSXSAMXAAMMAAAAAASMSSSMSSSSSXXXMXMAMMMMAMMSSSXMMXMSXMXXXSAMXAXMAMASXSSMSSXMMSMASAMXASXMAXXAMAAMAMMAMMXMXMAMAMXMXAASMXM
    \\MMAXASASAMMSMSAAAXXXXXAXASASMMMXSAMXSSMXAXAAXXAAMAMSXMAMAMAXXMSXMXMAMSAXXMSMAMXMXMSMSXMASAAMAAMAMSMMXSAMSMSXXSMSXSSSMAXMSSSMSAMXSXMXMSMSAMAS
    \\XXMMMMXMASAXAMMMMMMMAMMMXMXMAAAAASAMXMMMSMXMAMMMMMAXAMAXSSSSMMMMMXSAMMXMAAAMAMAMAMAASXSXMMMMMMSMMAXSAXMMMXMAAMAMAXMAMXXXAAAASXSMXXXAAAMXASAS
    \\XASMXXXMXAMXXXAAXMSAXAAXMSMSSMMSSMXSAMAXAAASAMAAAXXXSMMSMAAMAAAAMAMMXAAXMSXMASASMSMSMAMMSXSXAMAMAMSMAXSAMAMXMMAMSMSSMSAMXSMMMAMAMSSMSSMSAMAS
    \\SXAASMSMSSXAMSXSAAAXSSMMSAAXAXXXXAXSXSASMSMSASXSXSXAAMXAMMMSMMSASXSASMSSMAMSMSXXAXMAMAMASASMMSASXXXMMMSAMSASXSAMAAAAAXXMXXXXMMMSMAAXAAAMAMXM
    \\SMMAMAAMAMXMAXAXMAMMAAAXXAXMMXMMMSMMAAAMXMXSXMAMASMXMASXSMXAXAXAMXMASAAXMAXAMMMMMMMAMAXXMMMAXMASXSXXXAXMMMAXASXSMSMMSMSMAMXMSMMMMMSMMSMSAMXM
    \\MASAMXMMSSSSSSSMSMXSSSMMSSMSXAAMAXAMXMSMXMASAMXMAMAAXMMAMMSMSXMXSAMXMMMSSSMXMAAAAASXSMXSAXSXMMXMAMMSMSSSMMSMXMAAMAXXXAAMASMMAAXSAMXMXAASMSAS
    \\SAMAXMXAMAAAAAMAAMMMAAXAAAASMMSXASMMMXXXMMAXAMAMSSSXXXMAMXAAXXMAMXMAXXXMAMASMSSSMXXXAAAXMASMSAMMSMASAAAAMAAMAMXMXAXSMSMSASXSSSMAXMXASMXMAXXS
    \\MASASMMMSMSMMMMSMSAMXMMSSMMMASAMXSMASMSASMMSSMSSMAAASXSASMMSMAMASXSSSXSMSMAMAMAMXSXSSMMSXXXAXAMAAMMSSMSMMSXSASASMMMXAMXSMMMMAMASXMMMXXMMSMMM
    \\SXMAAMAMXAXAXXAXXSXSXSXAXAASXMAMAMXASAMAMXAAAXXAMMMMXAMXXMAMMAMXXAAAAASAAMMMMMAXXSAXAAMMMMMSMXMASMXMAMMXAAXXMSMXAAAMAMXMASAMAMSXAAAXSSMAASAM
    \\XXMSMSASMMMSSMMMMXASXMMSSSMSASXMASMMSXMSMMMSSMSXMSMSMSMAMMSMMSMSMMMMMMMAMMSAASMMAMMMSAMXAAXAXMAMMMMSAMMMSSMMMMMSSMSMSMASAMMSMSMSMMSAMXMASASX
    \\SXAAASXSASAAXAASAMXMAXAMXXAXAXMSASAMXAMMAXAMAAMXSAAAAAXASAAASMAAXAXSAMXAMASMMAAMXMAXXASXSSSXSAXSAMXSSMAAAXAASAAAAMXAASAMXSAAXAAAMSXXAXAMXMXM
    \\SASMMMASMMMSSSMSSXMSAMXSMMXMXMAMSSMMSXMSXMMSMMMSSMSMSMSXSXSSMMSMSSSXMASMMXSXSSXMXSXMSAMXMAMXAMSAMXXSXSMSSSSMSMSSMMMSMSXXSMMSSMSMXSAMXMASMXSX
;
