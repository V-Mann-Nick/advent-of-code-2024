const std = @import("std");
const Common = @import("common.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const lists = try Common.parseInput(u32, allocator);
    const left_numbers = lists.left_numbers;
    const right_numbers = lists.right_numbers;

    const Frequencies = std.AutoHashMap(u32, u32);
    var frequencies = Frequencies.init(allocator);
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

    std.debug.print("Similarity Score: {}\n", .{similarity_score});
}
