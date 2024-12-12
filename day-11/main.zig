const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const start = std.time.microTimestamp();
    const allocator = std.heap.page_allocator;

    const starting_pebbles = try parseInput();

    try part1(allocator, starting_pebbles.constSlice());
    try part2(allocator, starting_pebbles.constSlice());

    const end = std.time.microTimestamp();
    const micros = end - start;
    const millis = @as(f32, @floatFromInt(micros)) / 1000;
    std.debug.print("\nExecution time: {d:.3}ms\n", .{millis});
}

fn part1(allocator: Allocator, starting_pebbles: []const u64) !void {
    var pebble_counter = PebbleCounter(25).init(allocator);
    defer pebble_counter.deinit();
    const total = try pebble_counter.solve(starting_pebbles);
    std.debug.print("Total depth 25 (Part 1): {}\n", .{total});
}

fn part2(allocator: Allocator, starting_pebbles: []const u64) !void {
    var pebble_counter = PebbleCounter(75).init(allocator);
    defer pebble_counter.deinit();
    const total = try pebble_counter.solve(starting_pebbles);
    std.debug.print("Total depth 75 (Part 2): {}\n", .{total});
}

fn PebbleCounter(comptime depth: comptime_int) type {
    const Cache = std.AutoHashMap(u64, [depth]u64);

    return struct {
        cache: Cache,

        const Self = @This();

        fn init(allocator: Allocator) Self {
            return Self{ .cache = Cache.init(allocator) };
        }

        fn deinit(self: *Self) void {
            self.cache.deinit();
            self.cache = undefined;
        }

        fn solve(self: *Self, starting_pebbles: []const u64) !u64 {
            var total_pebbles: u64 = 0;
            for (starting_pebbles) |pebble| {
                total_pebbles += try self.countPebbles(pebble, depth - 1);
            }
            return total_pebbles;
        }

        fn countPebbles(self: *Self, pebble: u64, current_depth: usize) !u64 {
            const cache_result = try self.cache.getOrPut(pebble);
            if (!cache_result.found_existing) {
                cache_result.value_ptr.* = [_]u64{0} ** depth;
            }
            const cached_count = cache_result.value_ptr.*[current_depth];
            if (cached_count > 0) {
                return cached_count;
            }

            var next_pebbles = try std.BoundedArray(u64, 2).init(0);
            if (pebble == 0) {
                try next_pebbles.append(1);
            } else if (countDigits(pebble) % 2 == 0) {
                for (splitEven(pebble)) |next_pebble| {
                    try next_pebbles.append(next_pebble);
                }
            } else {
                try next_pebbles.append(pebble * 2024);
            }

            const count = if (current_depth == 0) next_pebbles.len else count: {
                var count: u64 = 0;
                for (next_pebbles.constSlice()) |next_pebble| {
                    count += try self.countPebbles(next_pebble, current_depth - 1);
                }
                break :count count;
            };

            const count_by_depth = self.cache.getPtr(pebble).?;
            count_by_depth.*[current_depth] = count;

            return count;
        }
    };
}

fn splitEven(n: u64) [2]u64 {
    const digits = countDigits(n);
    var left = n;
    var right: u64 = 0;
    for (0..@divFloor(digits, 2)) |i| {
        right = (left % 10) * std.math.pow(u64, 10, @as(u64, @intCast(i))) + right;
        left = @divFloor(left, 10);
    }
    return .{ left, right };
}

fn countDigits(n: u64) u64 {
    return std.math.log10_int(n) + 1;
}

const StartingPebbles = std.BoundedArray(u64, 8);

fn parseInput() !StartingPebbles {
    var starting_pebbles = try std.BoundedArray(u64, 8).init(0);
    var input_iterator = std.mem.splitSequence(u8, input, " ");
    while (input_iterator.next()) |n| {
        const pebble = try std.fmt.parseInt(u64, n, 10);
        try starting_pebbles.append(pebble);
    }
    return starting_pebbles;
}

const input = "510613 358 84 40702 4373582 2 0 1584";
