const std = @import("std");
const warn = std.debug.warn;

const idToString = @import("json_grammar.debug.zig").idToString;
const Lexer = @import("json_lexer.zig").Lexer;
const Types = @import("json_grammar.types.zig");
const Tokens = @import("json_grammar.tokens.zig");
const Actions = @import("json_grammar.actions.zig");
const Transitions = @import("json_grammar.tables.zig");

usingnamespace Types;
usingnamespace Tokens;
usingnamespace Actions;
usingnamespace Transitions;

pub const Parser = struct {
    state: i16 = 0,
    stack: Stack,
    source: []const u8,
    arena_allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator, arena: *std.mem.Allocator, source: []const u8) Self {
        return Self{ .stack = Stack.init(allocator), .source = source, .arena_allocator = arena };
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

    pub fn createVariant(self: *Self, comptime T: type) !*T {
        const variant = try self.arena_allocator.create(T);
        variant.base.id = Variant.typeToId(T);
        return variant;
    }

    pub fn createVariantList(self: *Self, comptime T: type) !*T {
        const list = try self.arena_allocator.create(T);
        list.* = T.init(self.arena_allocator);
        return list;
    }

    pub fn tokenString(self: *const Self, token: *Token) []const u8 {
        return self.source[token.start..token.end];
    }

    pub fn unescapeTokenString(self: *const Self, token: *Token) ![]u8 {
        const slice = self.source[token.start..token.end];
        var size = slice.len;
        var i: usize = 0;
        while(i < size) : (i += 1) {
            if(slice[i] == '\\') {
                size -= 1;
                i += 1;
            }
        }
        const result = try self.arena_allocator.alloc(u8, size);
        i = 0;
        var j: usize = 0;
        while(j < slice.len) : (j += 1) {
            if(slice[j] == '\\' or slice[j] == '\"') {
                j += 1;
            }
            result[i] = slice[j];
            i += 1;
        }

        return result;
    }

    pub fn action(self: *Self, token_id: Id, token: *Token) !bool {
        const id = @intCast(i16, @enumToInt(token_id));

        action_loop: while (true) {
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
                    // warn("{} ", idToString(token.id));
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
                    const produces = @enumToInt(try reduce_actions(Self, self, reduce, self.state));
                    state = @bitCast(u16, self.state);

                    // Gotos
                    const goto: i16 = goto_table[goto_index[state]][produces];
                    if (goto > 0) {
                        // if(consumes > 0) {
                        //     warn("\n");
                        //     self.printStack();
                        // }
                        self.state = goto;
                        continue :action_loop;
                    }
                }
            }
            break :action_loop;
        }
        if(self.stack.len == 1 and token_id == .Eof) {
            switch(self.stack.at(0).value) {
                .Terminal => |terminal_id| {
                    if(terminal_id == .Object)
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

    const filename = if(args.next(allocator)) |arg1| try arg1 else "lsp.json"[0..];

    var file = try std.fs.File.openRead(filename);
    defer file.close();

    var stream = file.inStream();
    const buffer = try stream.stream.readAllAlloc(allocator, 0x1000000);

    var arena = try allocator.create(std.heap.ArenaAllocator);
    arena.* = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    defer allocator.destroy(arena);

    var lexer = Lexer.init(buffer);
    var parser = Parser.init(allocator, &arena.allocator, buffer);
    defer parser.deinit();

    var tokens = std.ArrayList(Token).init(allocator);
    defer tokens.deinit();
    while (true) {
        var token = lexer.next();
        try tokens.append(token);
        if(token.id == .Eof)
            break;
    }
    var i: usize = 0;
    while(i < tokens.len) : (i += 1) {
        const token = &tokens.items[i];

        if(!try parser.action(token.id, token)) {
            std.debug.warn("\nerror => {}\n", token.id);
            break;
        }
    }
    // warn("\n");
    const Root = @intToPtr(?*Variant, parser.stack.at(0).item) orelse return;
    Root.dump(0);
    warn("\n");
}

