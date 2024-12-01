const std = @import("std");
const Common = @import("common.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const lists = try Common.parseInput(i32, allocator);
    const left_numbers = lists.left_numbers;
    const right_numbers = lists.right_numbers;

    std.mem.sort(i32, left_numbers.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right_numbers.items, {}, comptime std.sort.asc(i32));

    var sum: u32 = 0;
    for (left_numbers.items, right_numbers.items) |left, right| {
        sum += @abs(left - right);
    }
    std.debug.print("Sum: {}\n", .{sum});
}
