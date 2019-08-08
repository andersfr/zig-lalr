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
    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator) Self {
        return Self{ .stack = Stack.init(allocator), .allocator = allocator };
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

    pub fn createNode(self: *Self, comptime T: type) !*T {
        const node = try self.allocator.create(T);
        // Allocator memsets to 0xaa but we rely on structs being zero-initialized
        @memset(@ptrCast([*]align(@alignOf(T)) u8, node), 0, @sizeOf(T));
        node.base.id = Node.typeToId(T);
        return node;
    }

    pub fn createTemporary(self: *Self, comptime T: type) !*T {
        const node = try self.allocator.create(T);
        // Allocator memsets to 0xaa but we rely on structs being zero-initialized
        @memset(@ptrCast([*]align(@alignOf(T)) u8, node), 0, @sizeOf(T));
        return node;
    }

    pub fn createListWithNode(self: *Self, comptime T: type, node: *Node) !*T {
        const list = try self.allocator.create(T);
        list.* = T.init(self.allocator);
        try list.append(node);
        return list;
    }

    pub fn createListWithToken(self: *Self, comptime T: type, token: *Token) !*T {
        const list = try self.allocator.create(T);
        list.* = T.init(self.allocator);
        try list.append(token);
        return list;
    }

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
                    const produces = @enumToInt(try reduce_actions(Self, self, reduce, self.state));
                    state = @bitCast(u16, self.state);

                    // Gotos
                    const goto: i16 = goto_table[goto_index[state]][produces];
                    if (goto > 0) {
                        if(consumes > 0) {
                            warn("\n");
                            self.printStack();
                        }
                        self.state = goto;
                        continue :outer;
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
    defer parser.deinit();

    var tokens = std.ArrayList(Token).init(allocator);
    defer tokens.deinit();
    try tokens.append(Token{ .start = 0, .end = 0, .id = .Newline });
    while (true) {
        var token = lexer.next();
        try tokens.append(token);
        if(token.id == .Eof)
            break;
    }
    var i: usize = 1;
    // If file starts with a DocComment this is considered a RootComment
    while(i < tokens.len) : (i += 1) {
        tokens.items[i].id = if(tokens.items[i].id == .DocComment) .RootDocComment else break;
    }
    i = 0;
    var line: usize = 0;
    var last_newline = &tokens.items[0];
    while(i < tokens.len) : (i += 1) {
        const token = &tokens.items[i];

        token.line = last_newline;
        if(token.id == .Newline) {
            line += 1;
            token.start = line;
            last_newline = token;
            continue;
        }
        if(token.id == .LineComment) continue;

        if(!try parser.action(token.id, token)) {
            std.debug.warn("\nline: {} => {}\n", line, token.id);
            break;
        }
    }
    warn("\n");
    const Root = @intToPtr(?*Node.Root, parser.stack.at(0).item) orelse return;
    Root.eof_token = &tokens.items[tokens.len-1];
    warn("\n");
    Root.base.dump(0);
}

