const std = @import("std");
const Allocator = std.mem.Allocator;

fn Lists(comptime T: type) type {
    return struct {
        left_numbers: std.ArrayList(T),
        right_numbers: std.ArrayList(T),

        const Self = @This();

        fn deinit(self: Self) void {
            self.left_numbers.deinit();
            self.right_numbers.deinit();
        }
    };
}

fn parseInput(comptime T: type, allocator: Allocator) !Lists(T) {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    const input = try file.readToEndAlloc(allocator, 1e9);
    defer allocator.free(input);

    var left_numbers = try std.ArrayList(T).initCapacity(allocator, 1000);
    var right_numbers = try std.ArrayList(T).initCapacity(allocator, 1000);
    var lines_iterator = std.mem.split(u8, input, "\n");
    while (lines_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var left_and_right = std.mem.split(u8, line, "   ");
        const left = left_and_right.next().?;
        const left_number = try std.fmt.parseInt(T, left, 10);
        try left_numbers.append(left_number);

        const right = left_and_right.next().?;
        const right_number = try std.fmt.parseInt(T, right, 10);
        try right_numbers.append(right_number);
    }

    return Lists(T){
        .left_numbers = left_numbers,
        .right_numbers = right_numbers,
    };
}

const testing = std.testing;

test "Part 1" {
    const lists = try parseInput(i32, testing.allocator);
    defer lists.deinit();

    const left_numbers = lists.left_numbers;
    const right_numbers = lists.right_numbers;

    std.mem.sort(i32, left_numbers.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right_numbers.items, {}, comptime std.sort.asc(i32));

    var sum: u32 = 0;
    for (left_numbers.items, right_numbers.items) |left, right| {
        sum += @abs(left - right);
    }

    std.debug.print("Part 1\n", .{});
    std.debug.print("======\n", .{});
    std.debug.print("Sum: {}\n\n", .{sum});
}

test "Part 2" {
    const lists = try parseInput(u32, testing.allocator);
    defer lists.deinit();
    const left_numbers = lists.left_numbers;
    const right_numbers = lists.right_numbers;

    const Frequencies = std.AutoHashMap(u32, u32);
    var frequencies = Frequencies.init(testing.allocator);
    defer frequencies.deinit();
    for (right_numbers.items) |n| {
        const result = try frequencies.getOrPut(n);
        if (!result.found_existing) {
            result.value_ptr.* = 0;
        }
        result.value_ptr.* += 1;
    }

    var similarity_score: u32 = 0;
    for (left_numbers.items) |n| {
        const occurences = frequencies.get(n) orelse 0;
        similarity_score += n * occurences;
    }

    std.debug.print("Part 2\n", .{});
    std.debug.print("======\n", .{});
    std.debug.print("Similarity Score: {}\n\n", .{similarity_score});
}
