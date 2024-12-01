const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    const input = try file.readToEndAlloc(allocator, 1e9);

    // std.debug.print("{s}", .{input});

    var left_numbers = try std.ArrayList(i32).initCapacity(allocator, 1000);
    var right_numbers = try std.ArrayList(i32).initCapacity(allocator, 1000);
    var lines_iterator = std.mem.split(u8, input, "\n");
    while (lines_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var left_and_right = std.mem.split(u8, line, "   ");
        const left = left_and_right.next().?;
        const left_number = try std.fmt.parseInt(i32, left, 10);
        try left_numbers.append(left_number);

        const right = left_and_right.next().?;
        const right_number = try std.fmt.parseInt(i32, right, 10);
        try right_numbers.append(right_number);
    }

    std.mem.sort(i32, left_numbers.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right_numbers.items, {}, comptime std.sort.asc(i32));

    var sum: u32 = 0;
    for (left_numbers.items, right_numbers.items) |left, right| {
        sum += @abs(left - right);
    }
    std.debug.print("Sum: {}\n", .{sum});
}
