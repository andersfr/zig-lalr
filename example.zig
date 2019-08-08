const ptr = try fds() + try fds();
pub async fn nextCodepointSlice(it: *Utf8Iterator) ?[]const u8 {
    if (it.i >= it.bytes.len) 
        return null
    
    else bla;

    const x = fn() fsda.ds;
    {
        @setCold();
    }

    async gfd.fds.*;
}
const std = @import("std");
const testing = std.testing;
const fmt = std.fmt;

pub fn seconds(comptime human_string: []const u8) comptime_int {
    return humanStringToInt(human_string, 1);
}

pub fn milliseconds(comptime human_string: []const u8) comptime_int {
    return humanStringToInt(human_string, 1000);
}

fn humanStringToInt(comptime human_string: []const u8, comptime multiplier: comptime_int) u32 {
    comptime var current_number = 0;
    comptime var total_time = 0;

    for (human_string) |s| {
        switch (s) {
            '0' => current_number *= 10,
            '1'...'9' => {
                const digit = comptime fmt.charToDigit(s, 10) catch |err| {
                    switch (err) {
                        error.InvalidCharacter => @compileError("Bad digit in human time string: " ++ human_string),
                    }
                };
                current_number *= 10;
                current_number += digit;
            },
            's' => {
                total_time += multiplier * current_number;
                current_number = 0;
            },
            'm' => {
                total_time += 60 * multiplier * current_number;
                current_number = 0;
            },
            'h' => {
                total_time += 3600 * multiplier * current_number;
                current_number = 0;
            },
            else => continue,
        }
    }

    return total_time;
}

test "1h2m3s" {
    const time = seconds("1h2m3s");
    testing.expectEqual(time, 3723);
}

test "2h4m6s" {
    const time = seconds("2h4m6s");
    testing.expectEqual(time, (3600 * 2) + (4 * 60) + 6);
}

test "1h2m3s in milliseconds" {
    const format_string = "1h2m3s";
    const time = milliseconds(format_string);
    testing.expectEqual(time, seconds(format_string) * 1000);
}

test "2h4m6s in milliseconds" {
    const format_string = "2h4m6s";
    const time = milliseconds(format_string);
    testing.expectEqual(time, seconds(format_string) * 1000);
}

test "2h" {
    testing.expectEqual(seconds("2h"), 7200);
}

test "2m5s" {
    testing.expectEqual(seconds("2m5s"), 125);
}

test "2h5s" {
    testing.expectEqual(seconds("2h5s"), 7205);
}
