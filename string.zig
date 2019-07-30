const std = @import("std");
const builtin = @import("builtin");
const warn = std.debug.warn;
const assert = std.debug.assert;


pub const String = struct {
    internal_data: usize = 1,
    internal_len: u32 = 0,
    internal_capacity: u32 = 0,

    const Self = @This();

    pub fn init() Self {
        return Self{};
    }

    pub fn initWithValue(str: []const u8) !Self {
        var s = Self.init();
        errdefer s = Self{};

        try s.set(str);

        return s;
    }

    pub fn initWithTombstone(tombstone: u2) Self {
        return Self{ .internal_data = (@intCast(usize, tombstone) << 1) | 1 };
    }

    pub fn deinit(self: *Self) void {
        if(self.internal_data & 7 == 0) {
            std.c.free(@intToPtr(*c_void, self.internal_data));
        }
    }

    pub fn clone(self: Self) !Self {
        if(self.empty())
            return Self{ .internal_data = self.internal_data };
        return Self.initWithValue(self.view());
    }

    pub fn reset(self: *Self) void {
        self.deinit();
        self.* = Self{};
    }

    pub fn view(self: Self) []const u8 {
        if(self.internal_data & 7 == 0) {
            return (@intToPtr([*]const u8, self.internal_data))[0..self.internal_len];
        }
        const len = ((self.internal_data >> 4) & 0x1f);
        return (@ptrCast([*]const u8, &self.internal_data))[1..1+len];
    }

    pub fn hash(self: Self) u32 {
        return @noInlineCall(murmur.Murmur3_32.hash, self.view());
    }

    pub fn toSlice(self: Self) []const u8 {
        return self.view();
    }

    pub fn set(self: *Self, str: []const u8) !void {
        if(self.internal_data & 7 == 0) {
            if(str.len < self.internal_capacity) {
                const dest = @intToPtr([*]align(8) u8, self.internal_data);

                @memcpy(dest, str.ptr, str.len);
                self.internal_len = @intCast(u32, str.len);
                return;
            }
            std.c.free(@intToPtr(*c_void, self.internal_data));
        }
        if(str.len < @sizeOf(Self)) {
            const dest = @ptrCast([*]u8, &self.internal_data);

            var i: u32 = 0;
            while(i < @intCast(u32, str.len)) : (i += 1) {
                dest[i+1] = str[i];
            }
            dest[0] = (@intCast(u8, str.len) << 4) | 1;
        }
        else {
            self.internal_capacity = @intCast(u32, std.math.ceilPowerOfTwo(usize, str.len) catch unreachable);
            if(std.c.malloc(self.internal_capacity)) |c_ptr| {
                self.internal_data = @ptrToInt(c_ptr);
                self.internal_len = @intCast(u32, str.len);
                @memcpy(@ptrCast([*]u8, c_ptr), str.ptr, str.len);
                assert(self.internal_data & 7 == 0);
            }
            else {
                self.* = Self{};
                return error.OutOfMemory;
            }
        }
    }

    pub fn append(self: *Self, str: []const u8) !void {
        if(self.internal_data & 7 == 0) {
            const new_len = str.len + self.internal_len;
            if(new_len < self.internal_capacity) {
                const dest = @intToPtr([*]align(8) u8, self.internal_data);

                @memcpy(dest + self.internal_len, str.ptr, str.len);
                self.internal_len += @intCast(u32, str.len);
            }
            else {
                self.internal_capacity = @intCast(u32, std.math.ceilPowerOfTwo(usize, new_len) catch unreachable);
                if(std.c.realloc(@intToPtr(*c_void, self.internal_data), self.internal_capacity)) |c_ptr| {
                    self.internal_data = @ptrToInt(c_ptr);
                    @memcpy(@ptrCast([*]u8, c_ptr)+self.internal_len, str.ptr, str.len);
                    self.internal_len += @intCast(u32, str.len);
                    assert(self.internal_data & 7 == 0);
                }
                else {
                    std.c.free(@intToPtr(*c_void, self.internal_data));
                    self.* = Self{};
                    return error.OutOfMemory;
                }
            }
        }
        else {
            const old_len = @intCast(u32, (self.internal_data >> 4) & 0x1f);
            const new_len = @intCast(u32, old_len + str.len);
            if(new_len < @sizeOf(Self)) {
                const dest = @ptrCast([*]u8, &self.internal_data);

                var i: u32 = 0;
                while(i < @intCast(u32, str.len)) : (i += 1) {
                    dest[i+old_len+1] = str[i];
                }
                dest[0] = (@intCast(u8, new_len) << 4) | 1;
            }
            else {
                const new_capacity = @intCast(u32, std.math.ceilPowerOfTwo(usize, new_len) catch unreachable);
                if(std.c.malloc(new_capacity)) |c_ptr| {
                    @memcpy(@ptrCast([*]u8, c_ptr), @ptrCast([*]u8, &self.internal_data)+1, old_len);
                    @memcpy(@ptrCast([*]u8, c_ptr)+old_len, str.ptr, str.len);
                    self.internal_data = @ptrToInt(c_ptr);
                    self.internal_len = new_len;
                    assert(self.internal_data & 7 == 0);
                }
                else {
                    self.* = Self{};
                    return error.OutOfMemory;
                }
            }
        }
    }

    pub fn bytes(self: Self) u32 {
        if(self.internal_data & 7 == 0)
            return self.internal_len;
        return @intCast(u32, (self.internal_data >> 4) & 0x1f);
    }

    pub fn setTombstone(self: *Self, tombstone: u2) void {
        self.reset();
        self.internal_data = (@intCast(usize, tombstone) << 1) | 1;
    }

    pub fn getTombstone(self: Self) ?u2 {
        if(self.internal_data & 7 == 0)
            return null;
        return @intCast(u2, (self.internal_data >> 1) & 0x3);
    }

    pub fn empty() bool {
        return self.internal_data < 8;
    }
};
