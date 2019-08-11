const std = @import("std");
const warn = std.debug.warn;

const stack_trace_enabled = false;

fn stack_trace_none(fmt: []const u8, va_args: ...) void {}
const stack_trace = comptime if(stack_trace_enabled) std.debug.warn else stack_trace_none;

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
        if(stack_trace_enabled) {
            var it = self.stack.iterator();
            while(it.next()) |item| {
                switch(item.value) {
                    .Token => |id| { stack_trace("{} ", idToString(id)); },
                    .Terminal => |id| { if(item.item != 0) { stack_trace("{} ", terminalIdToString(id)); } },
                }
            }
        }
    }

    const ActionResult = enum { Ok, Fail, IncompleteLine };

    pub const Self = @This();

    pub const Stack = std.ArrayList(StackItem);

    pub fn createNode(self: *Self, comptime T: type) !*T {
        const node = try self.allocator.create(T);
        // Allocator memsets to 0xaa but we rely on structs being zero-initialized
        @memset(@ptrCast([*]align(@alignOf(T)) u8, node), 0, @sizeOf(T));
        node.base.id = Node.typeToId(T);
        return node;
    }

    pub fn createRecoveryNode(self: *Self, token: *Token) !*Node {
        const node = try self.allocator.create(Node.Recovery);
        // Allocator memsets to 0xaa but we rely on structs being zero-initialized
        @memset(@ptrCast([*]align(@alignOf(Node.Recovery)) u8, node), 0, @sizeOf(Node.Recovery));
        node.base.id = Node.typeToId(Node.Recovery);
        node.token = token;
        return &node.base;
    }

    pub fn createRecoveryToken(self: *Self, token: *Token) !*Token {
        const recovery_token = try self.allocator.create(Token);
        recovery_token.* = token.*;
        recovery_token.id = .Recovery;
        return recovery_token;
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

    fn earlyDetectUnmatched(self: *Self, open_token_id: Id, close_token_id: Id, token: *Token) bool {
        var ptr = @ptrCast([*]Token, token)+1;
        var cnt: usize = 1;
        // Check if it gets matched on same line
        while(ptr[0].id != .Eof and ptr[0].id != .Newline and cnt > 0) : (ptr += 1) {
            if(ptr[0].id == open_token_id) cnt += 1;
            if(ptr[0].id == close_token_id) cnt -= 1;
        }
        // Still unmatched
        if(cnt > 0) {
            // Check that more tokens are available
            if(ptr[0].id == .Newline) {
                // Look at indentation and make a guess
                const next_line_offset = if(ptr[1].id == .Newline) @intCast(usize, 0) else ptr[1].start - ptr[0].end;
                const own_line = @ptrCast([*]Token, token.line);
                const own_line_offset =  own_line[1].start - own_line[0].end;
                if(own_line_offset > next_line_offset) {
                    return true;
                }
                else if(ptr[1].id != close_token_id and own_line_offset == next_line_offset) {
                    // TODO: This is workaround for zig fmt bug; expensive and should be removed
                    var i = self.stack.items.len-1;
                    while(i > 0) : (i -= 1) {
                        switch(self.stack.items[i].value) {
                            .Terminal => |id| {
                                if(id == .Statements or id == .ContainerMembers) {
                                    const list = @intToPtr(*NodeList, self.stack.items[i].item);
                                    const last_token = list.items[list.len-1].firstToken();
                                    const line_offset = last_token.start - last_token.line.?.end;
                                    if(line_offset < own_line_offset)
                                        return false;
                                    return true;
                                }
                            },
                            else => {}
                        }
                    }
                    return true;
                }
            }
        }
        return false;
    }

    pub fn action(self: *Self, token_id: Id, token: *Token) !ActionResult {
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
                    // Unmatched {, [, ( must be detected early
                    switch(token.id) {
                        .LBrace, .LCurly => {
                            if(self.earlyDetectUnmatched(Id.LBrace, Id.RBrace, token))
                                return ActionResult.IncompleteLine;
                        },
                        .LParen => {
                            if(self.earlyDetectUnmatched(Id.LParen, Id.RParen, token))
                                return ActionResult.IncompleteLine;
                        },
                        .LBracket => {
                            if(self.earlyDetectUnmatched(Id.LBracket, Id.RBracket, token))
                                return ActionResult.IncompleteLine;
                        },
                        else => {}
                    }
                    stack_trace("{} ", idToString(token.id));
                    try self.stack.append(StackItem{ .item = @ptrToInt(token), .state = self.state, .value = StackValue{ .Token = token_id } });
                    self.state = shift;
                    return ActionResult.Ok;
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
                            stack_trace("\n");
                            self.printStack();
                        }
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
                    if(terminal_id == .Root)
                        return ActionResult.Ok;
                },
                else => {}
            }
        }

        return ActionResult.Fail;
    }

    fn recovery(self: *Self, token_id: Id, token: *Token, index: *usize) !ActionResult {
        const top = self.stack.len-1;
        const items = self.stack.items;

        switch(items[top].value) {
            .Terminal => |id| {
                // Missing function return type (body block is in return type)
                if(id == .FnProto) {
                    if(@intToPtr(*Node, items[top].item).cast(Node.FnProto)) |proto| {
                        switch(proto.return_type) {
                            .Explicit => |return_type| {
                                if(return_type.id == .Block) {
                                    proto.body_node = return_type;
                                    proto.return_type.Explicit = try self.createRecoveryNode(return_type.unsafe_cast(Node.Block).lbrace);
                                    index.* -= 1;
                                    return try self.action(Id.Semicolon, token);
                                }
                            },
                            else => {}
                        }
                    }
                }
                // Missing function return type (no body block)
                else if(id == .MaybeLinkSection and token_id == .Semicolon) {
                    const recovery_token = try self.createRecoveryToken(token);
                    index.* -= 1;
                    return try self.action(Id.Recovery, recovery_token);
                }
                // Missing semicolon after var decl or a comma
                else if(id == .MaybeEqualExpr) {
                    if(token_id != .Comma)
                        index.* -= 1;
                    return try self.action(Id.Semicolon, token);
                }
                // Semicolon after statement
                else if(id == .Statements and token_id == .Semicolon) {
                    return ActionResult.Ok;
                }
                // Missing semicolon after AssignExpr
                else if(id == .AssignExpr and token_id != .Semicolon) {
                    index.* -= 1;
                    return try self.action(Id.Semicolon, token);
                }
                // Missing comma after ContainerField
                else if(id == .ContainerField and token_id == .RBrace) {
                    index.* -= 1;
                    return try self.action(Id.Comma, token);
                }
            },
            .Token => |id| {
                if(id == .RParen and self.stack.len >= 4) {
                    switch(items[top-3].value) {
                        .Terminal => |terminal_id| {},
                        .Token => |loop_id| {
                            // Missing PtrIndexPayload in for loop
                            if(loop_id == .Keyword_for) {
                                const recovery_node = try self.createRecoveryNode(token);
                                try self.stack.append(StackItem{ .item = @ptrToInt(recovery_node), .state = self.state, .value = StackValue{ .Terminal = .PtrIndexPayload } });
                                self.state = goto_table[goto_index[@bitCast(u16, self.state)]][@enumToInt(TerminalId.PtrIndexPayload)];
                                index.* -= 1;
                                return ActionResult.Ok;
                            }
                        }
                    }
                }
            }
        }
        if(token_id == .Semicolon) {
            switch(items[top].value) {
                .Terminal => |id| {
                    // Recovers a{expr; ...} and error{expr; ...}
                    if(id == .MaybeComma) {
                        const state = @bitCast(u16, items[top-1].state);
                        const produces = @enumToInt(items[top-1].value.Terminal);
                        self.state = goto_table[goto_index[state]][produces];
                        self.stack.len -= 1;
                        return try self.action(Id.Comma, token);
                    }
                    // Recovers after ContainerField;
                    else if(id == .ContainerField) {
                        return try self.action(Id.Comma, token);
                    }
                },
                else => {}
            }
        }
        else if(token_id == .Comma) {
            return try self.action(Id.Semicolon, token);
        }

        return ActionResult.Fail;
    }

    pub fn resync(self: *Self) bool {
        while(self.stack.popOrNull()) |top| {
            switch(top.value) {
                .Token => |id| {
                    if(id == .LBrace) {
                        self.stack.items[self.stack.len] = top;
                        self.stack.len += 1;
                        return true;
                    }
                },
                .Terminal => |id| {
                    if(id == .Statements or id == .ContainerMembers) {
                        self.stack.items[self.stack.len] = top;
                        self.stack.len += 1;
                        return true;
                    }
                }
            }
            self.state = top.state;
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
    const shebang = if(tokens.items[1].id == .ShebangLine) @intCast(usize, 1) else @intCast(usize, 0);
    var i: usize = shebang + 1;
    // If file starts with a DocComment this is considered a RootComment
    while(i < tokens.len) : (i += 1) {
        tokens.items[i].id = if(tokens.items[i].id == .DocComment) .RootDocComment else break;
    }
    i = shebang;
    var line: usize = 0;
    var last_newline = &tokens.items[0];
    parser_loop: while(i < tokens.len) : (i += 1) {
        const token = &tokens.items[i];

        token.line = last_newline;
        if(token.id == .Newline) {
            line += 1;
            token.start = line;
            last_newline = token;
            continue;
        }
        if(token.id == .LineComment) continue;

        const result = try parser.action(token.id, token);
        if(result == .Ok)
            continue;

        if(result == .Fail) {
            if((try parser.recovery(token.id, token, &i)) == .Ok)
                continue;
        }

        // Incomplete line
        stack_trace("\n");
        if(parser.resync()) {
            parser.printStack();
            const current_line = token.line;
            if(result == .IncompleteLine) {
                while(i < tokens.len and tokens.items[i].id != .Newline) : (i += 1) {}
            }
            i -= 1;
            continue :parser_loop;
        }

        // Give up
        warn("\nFailed on line: {} => {}\n", line, token.id);
        break :parser_loop;
    }
    stack_trace("\n");
    if(parser.stack.len > 0) {
        const Root = @intToPtr(?*Node.Root, parser.stack.at(0).item) orelse return;
        Root.eof_token = &tokens.items[tokens.len-1];
        // stack_trace("\n");
        // Root.base.dump(0);
        warn("Success\n");
    }
}

