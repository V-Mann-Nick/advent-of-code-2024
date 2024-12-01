const std = @import("std");
const Allocator = std.mem.Allocator;

fn Lists(comptime T: type) type {
    return struct {
        left_numbers: std.ArrayList(T),
        right_numbers: std.ArrayList(T),
    };
}

pub fn parseInput(comptime T: type, allocator: Allocator) !Lists(T) {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    const input = try file.readToEndAlloc(allocator, 1e9);

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
