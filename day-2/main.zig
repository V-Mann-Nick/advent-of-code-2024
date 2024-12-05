const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Reports = ArrayList(ArrayList(u8));

fn parseReports(allocator: Allocator) !Reports {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    const input = try file.readToEndAlloc(allocator, 1e9);
    defer allocator.free(input);

    var reports = try Reports.initCapacity(allocator, 1000);
    var lines_iterator = std.mem.split(u8, input, "\n");
    while (lines_iterator.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var numbers = ArrayList(u8).init(allocator);
        var numbers_iterator = std.mem.split(u8, line, " ");
        while (numbers_iterator.next()) |n| {
            const number = try std.fmt.parseInt(u8, n, 10);
            try numbers.append(number);
        }

        try reports.append(numbers);
    }

    return reports;
}

const testing = std.testing;

test "Part 1" {
    var reports = try parseReports(testing.allocator);
    defer {
        for (reports.items) |report| {
            report.deinit();
        }
        reports.deinit();
    }

    var safe_reports: u16 = 0;
    reports: for (reports.items) |report| {
        var previous_direction: ?Direction = null;
        var previous_number: ?u8 = null;
        for (report.items) |n| {
            const p = previous_number orelse {
                previous_number = n;
                continue;
            };

            if (n == p) {
                continue :reports;
            }

            const new_direction = if (n > p) Direction.asc else Direction.desc;
            if (previous_direction != null and previous_direction != new_direction) {
                continue :reports;
            }

            if (n > p and n - p > 3 or p > n and p - n > 3) {
                continue :reports;
            }

            previous_direction = new_direction;
            previous_number = n;
        }
        safe_reports += 1;
    }

    std.debug.print("Part 1\n", .{});
    std.debug.print("======\n", .{});
    std.debug.print("Safe reports: {}\n\n", .{safe_reports});
}

const Direction = enum { asc, desc };

fn checkReport(report: []const u8, skip_idx: ?u8, recurse: bool) bool {
    var direction: ?Direction = null;
    var i: u8 = 0;
    while (i < report.len - 1) : (i += 1) {
        if (skip_idx == i) continue;
        const next_i = if (i + 1 == skip_idx) i + 2 else i + 1;
        if (next_i + 1 == report.len) continue;
        const c = report[i];
        const n = report[next_i];

        if (c == n) {
            if (recurse) {
                return checkReport(report, i, false) or i + 2 == report.len and checkReport(report, i + 1, false);
            }
            return false;
        }

        const new_direction = if (n > c) Direction.asc else Direction.desc;
        if (direction != null and direction != new_direction) {
            if (recurse) {
                return checkReport(report, i, false) or i + 2 == report.len and checkReport(report, i + 1, false);
            }
            return false;
        }

        if (n > c and n - c > 3 or c > n and c - n > 3) {
            if (recurse) {
                return checkReport(report, i, false) or i + 2 == report.len and checkReport(report, i + 1, false);
            }
            return false;
        }

        direction = new_direction;
    }
    return true;
}

test "checkReport" {
    var reports = try parseReports(testing.allocator);
    defer {
        for (reports.items) |report| {
            report.deinit();
        }
        reports.deinit();
    }

    try testing.expect(checkReport(&[_]u8{ 7, 6, 4, 2, 1 }, null, true));
    try testing.expect(!checkReport(&[_]u8{ 1, 2, 7, 8, 9 }, null, true));
    try testing.expect(!checkReport(&[_]u8{ 9, 7, 6, 2, 1 }, null, true));
    try testing.expect(checkReport(&[_]u8{ 1, 3, 2, 4, 5 }, null, true));
    try testing.expect(checkReport(&[_]u8{ 8, 6, 4, 4, 1 }, null, true));
    try testing.expect(checkReport(&[_]u8{ 1, 3, 6, 7, 9 }, null, true));
    try testing.expect(checkReport(&[_]u8{ 3, 2, 4, 5, 8 }, null, true));

    try testing.expect(checkReport(&[_]u8{ 7, 6, 4, 2, 3 }, null, true));
    try testing.expect(checkReport(&[_]u8{ 7, 6, 4, 2, 5 }, null, true));
}

test "Part 2" {
    var reports = try parseReports(testing.allocator);
    defer {
        for (reports.items) |report| {
            report.deinit();
        }
        reports.deinit();
    }

    var safe_reports: u16 = 0;
    for (reports.items) |report| {
        if (checkReport(report.items, null, true)) safe_reports += 1;
    }

    std.debug.print("Part 2\n", .{});
    std.debug.print("======\n", .{});
    std.debug.print("Safe reports: {}\n\n", .{safe_reports});
}
