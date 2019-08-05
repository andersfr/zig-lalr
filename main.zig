const std = @import("std");
const warn = std.debug.warn;

const idToString = @import("zig_grammar.debug.zig").idToString;
const Lexer = @import("zig_lexer.zig").Lexer;
const Types = @import("zig_grammar.types.zig");
const Tokens = @import("zig_grammar.tokens.zig");
const Actions = @import("zig_grammar.actions.zig");
const Transitions = @import("zig_grammar.tables.zig");

usingnamespace Types;
usingnamespace Tokens;
usingnamespace Actions;
usingnamespace Transitions;

pub const Parser = struct {
    state: i16 = 0,
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
                .Terminal => |id| { if(item.item != 0) { warn("{} ", terminalIdToString(id)); } },
            }
        }
    }

    pub const Self = @This();

    pub const Stack = std.ArrayList(StackItem);

    pub fn action(self: *Self, token_id: Id, token: *Token) !bool {
        const id = @intCast(i16, @enumToInt(token_id));

        outer: while (true) {
            var state: usize = @bitCast(u16, self.state);

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
                    try self.stack.append(StackItem{ .item = @ptrToInt(token), .state = self.state, .value = StackValue{ .Token = token_id } });
                    self.state = shift;
                    return true;
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
                    // const produces = produces_table[@bitCast(u16, reduce)];
                    // var pop = consumes;
                    // while (pop > 0) : (pop -= 1) {
                    //     self.state = self.stack.pop().state;
                    // }
                    const produces = @enumToInt(try reduce_actions(Self, self, reduce, self.state));
                    state = @bitCast(u16, self.state);

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
                                // try self.stack.append(StackItem{ .item = @ptrToInt(token), .state = self.state, .value = StackValue{ .Terminal = @intToEnum(TerminalId, produces) } });
                                warn("\n");
                                self.printStack();
                            }
                            // else {
                            //     try self.stack.append(StackItem{ .item = 0, .state = self.state, .value = StackValue{ .Terminal = @intToEnum(TerminalId, produces) } });
                            // }
                            self.state = goto;
                            continue :outer;
                        }
                    }
                }
            }
            break;
        }
        if(self.stack.len == 1 and token_id == .Eof) {
            switch(self.stack.at(0).value) {
                .Terminal => |terminal_id| {
                    if(terminal_id == .Root)
                        return true;
                },
                else => {}
            }
        }

        return false;
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

        if(!try parser.action(token.id, &token)) {
            std.debug.warn("\nline: {} => {}\n", line, token.id);
            break;
        }
        if(token.id == .Eof) {
            warn("\n");
            break;
        }
    }
}

