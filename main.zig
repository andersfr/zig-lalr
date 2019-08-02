const std = @import("std");
const warn = std.debug.warn;

const idToString = @import("zig_debug.zig").idToString;
const Lexer = @import("zig_lexer.zig").Lexer;
const Tokens = @import("zig_grammar.tokens.zig");
const Transitions = @import("zig_grammar.tables.zig");

usingnamespace Tokens;
usingnamespace Transitions;

pub const Parser = struct {
    state: usize = 0,
    stack: Stack,

    pub fn init(allocator: *std.mem.Allocator) Self {
        return Self{ .stack = Stack.init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.stack.deinit();
    }

    fn printStack(self: *const Self) void {
        var it = self.stack.iterator();
        while(it.next()) |item| {
            switch(item.value) {
                .Token => |id| { warn("{} ", idToString(id)); },
                .Terminal => |id| { if(item.token) |token| { warn("{} ", terminalIdToString(id)); } },
            }
        }
    }

    pub const Self = @This();

    pub const Stack = std.ArrayList(StackItem);

    pub const StackItem = struct {
        token: ?*Token,
        state: i16,
        value: StackValue,
    };

    pub const StackValue = union(enum) {
        Token: Id,
        Terminal: TerminalId,
    };

    pub fn action(self: *Self, token: *Token) !void {
        const id = @intCast(i16, @enumToInt(token.id));

        outer: while (true) {
            var state = self.state;

            // Shifts
            if (shift_table[state].len > 0) {
                var shift: i16 = 0;
                // Full table
                if (shift_table[state][0] == -1) {
                    shift = shift_table[state][@bitCast(u16, id)];
                }
                // Key-Value pairs
                else {
                    var i: usize = 0;
                    while (i < shift_table[state].len) : (i += 2) {
                        if (shift_table[state][i] == id) {
                            shift = shift_table[state][i + 1];
                            break;
                        }
                    }
                }
                if (shift > 0) {
                    warn("{} ", idToString(token.id));
                    try self.stack.append(StackItem{ .token = token, .state = @bitCast(i16, @truncate(u16, state)), .value = StackValue{ .Token = token.id } });
                    self.state = @bitCast(u16, shift);
                    return;
                }
            }
            // Reduces
            if (reduce_table[state].len > 0) {
                var reduce: i16 = 0;
                // Key-Value pairs and default reduce
                {
                    var i: usize = 0;
                    while (i < reduce_table[state].len) : (i += 2) {
                        if (reduce_table[state][i] == id or reduce_table[state][i] == -1) {
                            reduce = reduce_table[state][i + 1];
                            break;
                        }
                    }
                }
                if (reduce > 0) {
                    const consumes = consumes_table[@bitCast(u16, reduce)];
                    var pop = consumes;
                    while (pop > 0) : (pop -= 1) {
                        state = @bitCast(u16, self.stack.pop().state);
                    }
                    const produces = produces_table[@bitCast(u16, reduce)];

                    // Gotos
                    if (goto_table[state].len > 0) {
                        var goto: i16 = 0;
                        // Full table
                        if (goto_table[state][0] == -1) {
                            goto = goto_table[state][produces];
                        }
                        // Key-Value pairs
                        else {
                            var i: usize = 0;
                            while (i < goto_table[state].len) : (i += 2) {
                                if (goto_table[state][i] == @intCast(i16, produces)) {
                                    goto = goto_table[state][i + 1];
                                    break;
                                }
                            }
                        }
                        if (goto > 0) {
                            if(consumes > 0) {
                                try self.stack.append(StackItem{ .token = token, .state = @bitCast(i16, @truncate(u16, state)), .value = StackValue{ .Terminal = @intToEnum(TerminalId, produces) } });
                                warn("\n");
                                self.printStack();
                            }
                            else {
                                try self.stack.append(StackItem{ .token = null, .state = @bitCast(i16, @truncate(u16, state)), .value = StackValue{ .Terminal = @intToEnum(TerminalId, produces) } });
                            }
                            self.state = @bitCast(u16, goto);
                            continue :outer;
                        }
                    }
                }
            }
            break;
        }
        if(self.stack.len == 1 and token.id == .Eof) {
            switch(self.stack.at(0).value) {
                .Terminal => |terminal_id| {
                    if(terminal_id == .Root)
                        return;
                },
                else => {}
            }
        }

        return error.ParseError;
    }
};

pub fn main() !void {
    var allocator = std.heap.c_allocator;

    var args = std.process.args();
    if(!args.skip()) return;

    const filename = if(args.next(allocator)) |arg1| try arg1 else "example.zig"[0..];

    var file = try std.fs.File.openRead(filename);
    defer file.close();

    var stream = file.inStream();
    const buffer = try stream.stream.readAllAlloc(allocator, 0x1000000);

    var lexer = Lexer.init(buffer);
    var parser = Parser.init(allocator);
    var line: usize = 1;
    defer parser.deinit();
    while (true) {
        var token = lexer.next();
        if(token.id == .Newline) {
            line += 1;
            continue;
        }
        if(token.id == .LineComment) continue;

        parser.action(&token) catch { std.debug.warn("\nline: {} => {}\n", line, token.id); return error.ParserError; };
        if(token.id == .Eof)
            break;
    }
}

