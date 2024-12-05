const std = @import("std");

pub fn main() !void {
    const start = std.time.nanoTimestamp();

    var buffer: [30000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    const input = try file.readToEndAlloc(allocator, 1e9);
    defer allocator.free(input);

    var solver = Solver.init(input);
    const total = solver.solve();
    std.debug.print("Total: {}\n", .{total});

    const end = std.time.nanoTimestamp();
    const duration = end - start;
    std.debug.print("Execution time: {} ns\n", .{duration});
}

const Solver = struct {
    input: []const u8,
    idx: usize,
    total: u32,

    fn init(input: []const u8) Solver {
        return .{ .input = input, .idx = 0, .total = 0 };
    }

    const MUL = "mul(";

    fn solve(self: *Solver) u32 {
        while (self.idx < self.input.len - MUL.len) {
            const slice = self.input[self.idx .. self.idx + MUL.len];
            if (std.mem.eql(u8, slice, MUL)) {
                self.idx = self.idx + MUL.len;
                self.parseMul();
            } else {
                self.idx += 1;
            }
        }
        return self.total;
    }

    fn parseMul(self: *Solver) void {
        const left = self.parseNumber();
        if (self.readChar() != ',') {
            return;
        }
        const right = self.parseNumber();
        if (self.readChar() != ')') {
            return;
        }
        self.total += left * right;
    }

    fn readChar(self: *Solver) u8 {
        const c = self.input[self.idx];
        self.idx += 1;
        return c;
    }

    fn parseNumber(self: *Solver) u32 {
        var n: u32 = 0;
        while (true) {
            const digit_char = self.input[self.idx];
            if (digit_char < '0' or digit_char > '9') {
                break;
            }
            n *= 10;
            const digit = std.fmt.parseInt(u32, &[_]u8{digit_char}, 10) catch unreachable;
            n += digit;
            self.idx += 1;
        }
        return n;
    }
};
