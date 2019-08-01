const std = @import("std");
const warn = std.debug.warn;

const String = @import("string.zig").String;
const Grammar = @import("grammar.zig").Grammar;
const Production = @import("grammar.zig").Production;

const Node = std.zig.ast.Node;

const default_heap = std.heap.c_allocator;

const SymbolType = struct {
    name: []const u8,
    optional: bool,
};

fn parsePrecedence(proto: *Node.VarDecl) void {
    // warn("precedence\n");
}

fn parseSymbolType(tree: *std.zig.ast.Tree, buffer: []const u8, node: *Node) !SymbolType {
    var optional: bool = false;
    if(node.cast(Node.PrefixOp)) |prefix| {
        const op: *Node.PrefixOp = blk: {
            switch(prefix.op) {
                .OptionalType => {
                    if(prefix.rhs.cast(Node.PrefixOp)) |opt_prefix| {
                        optional = true;
                        break :blk opt_prefix;
                    }
                    break :blk prefix;
                },
                else => break :blk prefix,
            }
        };
        switch(op.op) {
            .PtrType => {
                if(op.rhs.cast(Node.Identifier)) |ident| {
                    const ident_name = tree.tokens.at(ident.token);
                    const ident_str = buffer[ident_name.start..ident_name.end];
                    return SymbolType{ .optional = optional, .name = ident_str };
                }
                else if(op.rhs.cast(Node.InfixOp)) |infix| {
                    const ident_name_s = tree.tokens.at(infix.firstToken());
                    const ident_name_e = tree.tokens.at(infix.lastToken());
                    const ident_str = buffer[ident_name_s.start..ident_name_e.end];
                    return SymbolType{ .optional = optional, .name = ident_str };
                }
                return error.ExpectedIdentifier;
            },
            else => {
                return error.ExpectedPtrOrOptionalPtr;
            }
        }
    }
    return error.InvalidSymbolType;
}

fn parseProduction(tree: *std.zig.ast.Tree, buffer: []const u8, proto: *Node.FnProto) !*Production {
    var prod_name: []const u8 = undefined;
    if (proto.name_token) |name_token| {
        const name = tree.tokens.at(name_token);
        prod_name = buffer[name.start..name.end];
    } else {
        warn("Productions must be associated with a non-terminal name\n");
        return error.MissingNonTerminal;
    }

    // Allocate
    var prod = try default_heap.create(Production);
    errdefer default_heap.destroy(prod);

    // Initialize
    prod.* = Production.init(default_heap, prod_name);
    errdefer prod.deinit();

    // Parse each element in production
    var it = proto.params.iterator(0);
    while (it.next()) |param| {
        if (param.*.cast(Node.ParamDecl)) |decl| {
            if (decl.name_token) |name_token| {
                const param_name = tree.tokens.at(name_token);
                const param_str = buffer[param_name.start..param_name.end];

                // TODO: associated type and action block
                if(decl.type_node.cast(Node.SuffixOp)) |suffix| {
                    if(suffix.lhs.cast(Node.Identifier)) |precedence| {
                        const precedence_name = tree.tokens.at(precedence.token);
                        const precedence_str = buffer[precedence_name.start..precedence_name.end];
                        switch(suffix.op) {
                            .Call => |call| {
                                if(call.params.len == 1) {
                                    _ = try parseSymbolType(tree, buffer, @intToPtr(*Node, @ptrToInt(call.params.at(0).*)));
                                    // Append the parameter name
                                    try prod.append(param_str, precedence_str);
                                }
                            },
                            else => {}
                        }
                    }
                }
                else {
                    _ = try parseSymbolType(tree, buffer, decl.type_node);
                    try prod.append(param_str, null);
                }
            }
        }
    }

    return prod;
}

fn parseGrammar(name: []const u8, tree: *std.zig.ast.Tree, buffer: []const u8, container: *Node.ContainerDecl) !Grammar {
    var grammar = Grammar.init(default_heap, name);
    errdefer grammar.deinit();

    var g = container.fields_and_decls.iterator(0);
    while (g.next()) |fld| {
        if (fld.*.cast(Node.VarDecl)) |precedence| {
            parsePrecedence(precedence);
        }
        if (fld.*.cast(Node.FnProto)) |production| {
            const prod = try parseProduction(tree, buffer, production);
            try grammar.append(prod);
        }
    }

    try grammar.finalize();
    return grammar;
}

fn writeGrammar(grammar: Grammar) !void {
    var tokens_name = try String.initWithValue(grammar.grammar_name);
    defer tokens_name.deinit();
    try tokens_name.append(".tokens.zig");

    var transitions_name = try String.initWithValue(grammar.grammar_name);
    defer transitions_name.deinit();
    try transitions_name.append(".tables.zig");

    var actions_name = try String.initWithValue(grammar.grammar_name);
    defer actions_name.deinit();
    try actions_name.append(".actions.zig");

    var dump_name = try String.initWithValue(grammar.grammar_name);
    defer dump_name.deinit();
    try dump_name.append(".txt");

    // Tokens
    {
        var file = try std.fs.File.openWrite(tokens_name.view());
        defer file.close();

        var out = file.outStream();
        try out.stream.write(
            \\// AutoGenerated file
            \\
            \\pub const Token = struct {
            \\    id: Id,
            \\    start: usize,
            \\    end: usize,
            \\};
            \\
            \\pub const Id = enum(u8) {
            \\
        );
        try out.stream.print("    Invalid = 0,\n");
        try out.stream.print("    Eof = 1,\n");
        var git = grammar.names_index_map.lookup.iterator();
        while(git.next()) |kv| {
            if(kv.value > grammar.epsilon_index+1) {
                try out.stream.print("    {} = {},\n", kv.key, kv.value - grammar.epsilon_index);
            }
        }
        const x = grammar.names_index_map.lookup.size - grammar.epsilon_index;
        try out.stream.print("    ShebangLine = {},\n", x);
        try out.stream.print("    LineComment = {},\n", x+1);
        try out.stream.print("    Newline = {},\n", x+2);
        try out.stream.print("    Ignore = {},\n", x+3);
        try out.stream.write("};\n\n");

        try out.stream.write(
            \\pub fn idToString(id: Id) []const u8 {
            \\    switch(id) {
            \\        .Builtin                            => return "@",
            \\        .Ampersand                          => return "&",
            \\        .AmpersandEqual                     => return "&=",
            \\        .Asterisk                           => return "*",
            \\        .AsteriskAsterisk                   => return "**",
            \\        .AsteriskEqual                      => return "*=",
            \\        .AsteriskPercent                    => return "*%",
            \\        .AsteriskPercentEqual               => return "*%=",
            \\        .Caret                              => return "^",
            \\        .CaretEqual                         => return "^=",
            \\        .Colon                              => return ":",
            \\        .Comma                              => return ",",
            \\        .Period                             => return ".",
            \\        .Ellipsis2                          => return "..",
            \\        .Ellipsis3                          => return "...",
            \\        .Equal                              => return "=",
            \\        .EqualEqual                         => return "==",
            \\        .EqualAngleBracketRight             => return "=>",
            \\        .Bang                               => return "!",
            \\        .BangEqual                          => return "!=",
            \\        .AngleBracketLeft                   => return "<",
            \\        .AngleBracketAngleBracketLeft       => return "<<",
            \\        .AngleBracketAngleBracketLeftEqual  => return "<<=",
            \\        .AngleBracketLeftEqual              => return "<=",
            \\        .LBrace                             => return "{",
            \\        .LBracket                           => return "[",
            \\        .LParen                             => return "(",
            \\        .Minus                              => return "-",
            \\        .MinusEqual                         => return "-=",
            \\        .MinusAngleBracketRight             => return "->",
            \\        .MinusPercent                       => return "-%",
            \\        .MinusPercentEqual                  => return "-%=",
            \\        .Percent                            => return "%",
            \\        .PercentEqual                       => return "%=",
            \\        .Pipe                               => return "|",
            \\        .PipePipe                           => return "||",
            \\        .PipeEqual                          => return "|=",
            \\        .Plus                               => return "+",
            \\        .PlusPlus                           => return "++",
            \\        .PlusEqual                          => return "+=",
            \\        .PlusPercent                        => return "+%",
            \\        .PlusPercentEqual                   => return "+%=",
            \\        .BracketStarCBracket                => return "[*c]",
            \\        .BracketStarBracket                 => return "[*]",
            \\        .QuestionMark                       => return "?",
            \\        .AngleBracketRight                  => return ">",
            \\        .AngleBracketAngleBracketRight      => return ">>",
            \\        .AngleBracketAngleBracketRightEqual => return ">>=",
            \\        .AngleBracketRightEqual             => return ">=",
            \\        .RBrace                             => return "}",
            \\        .RBracket                           => return "]",
            \\        .RParen                             => return ")",
            \\        .Semicolon                          => return ";",
            \\        .Slash                              => return "/",
            \\        .SlashEqual                         => return "/=",
            \\        .Tilde                              => return "~",
            \\        .Keyword_align                      => return "align",
            \\        .Keyword_allowzero                  => return "allowzero",
            \\        .Keyword_and                        => return "and",
            \\        .Keyword_asm                        => return "asm",
            \\        .Keyword_async                      => return "async",
            \\        .Keyword_await                      => return "await",
            \\        .Keyword_break                      => return "break",
            \\        .Keyword_catch                      => return "catch",
            \\        .Keyword_cancel                     => return "cancel",
            \\        .Keyword_comptime                   => return "comptime",
            \\        .Keyword_const                      => return "const",
            \\        .Keyword_continue                   => return "continue",
            \\        .Keyword_defer                      => return "defer",
            \\        .Keyword_else                       => return "else",
            \\        .Keyword_enum                       => return "enum",
            \\        .Keyword_errdefer                   => return "errdefer",
            \\        .Keyword_error                      => return "error",
            \\        .Keyword_export                     => return "export",
            \\        .Keyword_extern                     => return "extern",
            \\        .Keyword_false                      => return "false",
            \\        .Keyword_fn                         => return "fn",
            \\        .Keyword_for                        => return "for",
            \\        .Keyword_if                         => return "if",
            \\        .Keyword_inline                     => return "inline",
            \\        .Keyword_nakedcc                    => return "nakedcc",
            \\        .Keyword_noalias                    => return "noalias",
            \\        .Keyword_null                       => return "null",
            \\        .Keyword_or                         => return "or",
            \\        .Keyword_orelse                     => return "orelse",
            \\        .Keyword_packed                     => return "packed",
            \\        .Keyword_promise                    => return "promise",
            \\        .Keyword_pub                        => return "pub",
            \\        .Keyword_resume                     => return "resume",
            \\        .Keyword_return                     => return "return",
            \\        .Keyword_linksection                => return "linksection",
            \\        .Keyword_stdcallcc                  => return "stdcallcc",
            \\        .Keyword_struct                     => return "struct",
            \\        .Keyword_suspend                    => return "suspend",
            \\        .Keyword_switch                     => return "switch",
            \\        .Keyword_test                       => return "test",
            \\        .Keyword_threadlocal                => return "threadlocal",
            \\        .Keyword_true                       => return "true",
            \\        .Keyword_try                        => return "try",
            \\        .Keyword_undefined                  => return "undefined",
            \\        .Keyword_union                      => return "union",
            \\        .Keyword_unreachable                => return "unreachable",
            \\        .Keyword_use                        => return "use",
            \\        .Keyword_usingnamespace             => return "usingnamespace",
            \\        .Keyword_var                        => return "var",
            \\        .Keyword_volatile                   => return "volatile",
            \\        .Keyword_while                      => return "while",
            \\
            \\        .Invalid                            => return "$invalid",
            \\        .Eof                                => return "$eof",
            \\        .Newline                            => return "$newline",
            \\        .Ignore                             => return "$ignore",
            \\        .ShebangLine                        => return "#!",
            \\        .LineComment                        => return "//",
            \\        .DocComment                         => return "///",
            \\        .LineString                         => return "\\",
            \\        .LineCString                        => return "c\\",
            \\
            \\        .Identifier                         => return "Identifier",
            \\        .CharLiteral                        => return "CharLiteral",
            \\        .StringLiteral                      => return "StringLiteral",
            \\        .IntegerLiteral                     => return "IntegerLiteral",
            \\        .FloatLiteral                       => return "FloatLiteral",
            \\        //else => unreachable,
            \\    }
            \\}
        );

        try out.stream.write("pub const TerminalId = enum(u8) {\n");
        try out.stream.print("    Accept = 0,\n");
        git = grammar.names_index_map.lookup.iterator();
        while(git.next()) |kv| {
            if(0 < kv.value and kv.value < grammar.epsilon_index) {
                try out.stream.print("    {} = {},\n", kv.key, kv.value);
            }
        }
        try out.stream.write("};\n\n");

        try out.stream.write("pub fn terminalIdToString(id: TerminalId) []const u8 {\n");
        try out.stream.write("    switch(id) {\n");
        try out.stream.write((" " ** 8) ++ ".Accept => return \"$accept\",");
        git = grammar.names_index_map.lookup.iterator();
        while(git.next()) |kv| {
            if(0 < kv.value and kv.value < grammar.epsilon_index) {
                try out.stream.print((" " ** 8) ++ ".{} => ", kv.key);
                if(kv.key.len > 5 and std.mem.compare(u8, kv.key[0..5], "Maybe") == .Equal) {
                    try out.stream.print("return \"{}?\",\n", kv.key[5..]);
                }
                else {
                    try out.stream.print("return \"{}\",\n", kv.key);
                }
            }
        }
        try out.stream.write("    }\n\n");
        try out.stream.write("}\n\n");
    }

    // Actions
    {
        var file = try std.fs.File.openWrite(actions_name.view());
        defer file.close();

        var out = file.outStream();
        try out.stream.write(
            \\// AutoGenerated file
            \\
            \\const std = @import("std");
            \\const warn = std.debug.warn;
            \\
        );
        try out.stream.print("const Tokens = @import(\"{}\");\n", tokens_name.view());
        try out.stream.print("const Transitions = @import(\"{}\");\n\n", transitions_name.view());
        try out.stream.write(
            \\
            \\usingnamespace Tokens;
            \\usingnamespace Transitions;
            \\
            \\pub const Parser = struct {
            \\    state: usize = 0,
            \\    stack: Stack,
            \\
            \\    pub fn init(allocator: *std.mem.Allocator) Self {
            \\        return Self{ .stack = Stack.init(allocator) };
            \\    }
            \\
            \\    pub fn deinit(self: *Self) void {
            \\        self.stack.deinit();
            \\    }
            \\
            \\    fn printStack(self: *const Self) void {
            \\        var it = self.stack.iterator();
            \\        while(it.next()) |item| {
            \\            switch(item.value) {
            \\                .Token => |id| { warn("{} ", idToString(id)); },
            \\                .Terminal => |id| { if(item.token) |token| { warn("{} ", terminalIdToString(id)); } },
            \\            }
            \\        }
            \\    }
            \\
            \\    pub const Self = @This();
            \\
            \\    pub const Stack = std.ArrayList(StackItem);
            \\
            \\    pub const StackItem = struct {
            \\        token: ?*Token,
            \\        state: i16,
            \\        value: StackValue,
            \\    };
            \\
            \\    pub const StackValue = union(enum) {
            \\        Token: Id,
            \\        Terminal: TerminalId,
            \\    };
            \\
            \\    pub fn action(self: *Self, token: *Token) !void {
            \\        const id = @intCast(i16, @enumToInt(token.id));
            \\
            \\        outer: while (true) {
            \\            var state = self.state;
            \\
            \\            // Shifts
            \\            if (shift_table[state].len > 0) {
            \\                var shift: i16 = 0;
            \\                // Full table
            \\                if (shift_table[state][0] == -1) {
            \\                    shift = shift_table[state][@bitCast(u16, id)];
            \\                }
            \\                // Key-Value pairs
            \\                else {
            \\                    var i: usize = 0;
            \\                    while (i < shift_table[state].len) : (i += 2) {
            \\                        if (shift_table[state][i] == id) {
            \\                            shift = shift_table[state][i + 1];
            \\                            break;
            \\                        }
            \\                    }
            \\                }
            \\                if (shift > 0) {
            \\                    warn("{} ", idToString(token.id));
            \\                    try self.stack.append(StackItem{ .token = token, .state = @bitCast(i16, @truncate(u16, state)), .value = StackValue{ .Token = token.id } });
            \\                    self.state = @bitCast(u16, shift);
            \\                    return;
            \\                }
            \\            }
            \\            // Reduces
            \\            if (reduce_table[state].len > 0) {
            \\                var reduce: i16 = 0;
            \\                // Full table
            \\                if (reduce_table[state][0] == 0 and reduce_table[state].len > 2) {
            \\                    reduce = reduce_table[state][@bitCast(u16, id)];
            \\                }
            \\                // Default
            \\                else if (reduce_table[state][0] == 0) {
            \\                    reduce = reduce_table[state][1];
            \\                }
            \\                if (reduce > 0) {
            \\                    const consumes = consumes_table[@bitCast(u16, reduce)];
            \\                    var pop = consumes;
            \\                    while (pop > 0) : (pop -= 1) {
            \\                        state = @bitCast(u16, self.stack.pop().state);
            \\                    }
            \\                    const produces = produces_table[@bitCast(u16, reduce)];
            \\
            \\                    // Gotos
            \\                    if (goto_table[state].len > 0) {
            \\                        var goto: i16 = 0;
            \\                        // Full table
            \\                        if (goto_table[state][0] == -1) {
            \\                            goto = goto_table[state][produces];
            \\                        }
            \\                        // Key-Value pairs
            \\                        else {
            \\                            var i: usize = 0;
            \\                            while (i < goto_table[state].len) : (i += 2) {
            \\                                if (goto_table[state][i] == @intCast(i16, produces)) {
            \\                                    goto = goto_table[state][i + 1];
            \\                                    break;
            \\                                }
            \\                            }
            \\                        }
            \\                        if (goto > 0) {
            \\                            if(consumes > 0) {
            \\                                try self.stack.append(StackItem{ .token = token, .state = @bitCast(i16, @truncate(u16, state)), .value = StackValue{ .Terminal = @intToEnum(TerminalId, produces) } });
            \\                                warn("\n");
            \\                                self.printStack();
            \\                            }
            \\                            else {
            \\                                try self.stack.append(StackItem{ .token = null, .state = @bitCast(i16, @truncate(u16, state)), .value = StackValue{ .Terminal = @intToEnum(TerminalId, produces) } });
            \\                            }
            \\                            self.state = @bitCast(u16, goto);
            \\                            continue :outer;
            \\                        }
            \\                    }
            \\                }
            \\            }
            \\            break;
            \\        }
            \\        if(self.stack.len == 1 and token.id == .Eof) {
            \\            switch(self.stack.at(0).value) {
            \\                .Terminal => |terminal_id| {
            \\                    if(terminal_id == .Root)
            \\                        return;
            \\                },
            \\                else => {}
            \\            }
            \\        }
            \\
            \\        return error.ParseError;
            \\    }
            \\};
        );
    }

    // Grammar dump
    {
        var file = try std.fs.File.openWrite(dump_name.view());
        defer file.close();

        var out = file.outStream();

        try grammar.debugToFile(&out);
    }

    // Transitions
    {
        var file = try std.fs.File.openWrite(transitions_name.view());
        defer file.close();

        var out = file.outStream();
        try out.stream.print("// AutoGenerated file\n\n");

        // Produces
        {
            try out.stream.print("pub const produces_table = [{}]u8 {}\n", grammar.productions.len, "{");
            var it = grammar.productions.iterator();
            while(it.next()) |production| {
                try out.stream.print("{}, ", production.terminal_id);
            }
            try out.stream.write("\n};\n\n");
        }

        // Consumes
        {
            try out.stream.print("pub const consumes_table = [{}]usize {}\n", grammar.productions.len, "{");
            var it = grammar.productions.iterator();
            while(it.next()) |production| {
                try out.stream.print("{}, ", production.consumes);
            }
            try out.stream.write("\n};\n\n");
        }

        // Goto
        {
            try out.stream.print("pub const goto_table = [{}][]const i16 {}\n", grammar.transitions.len, "{");
            var it = grammar.transitions.iterator();
            while(it.next()) |transition| {
                try out.stream.write("    [_]i16{");
                var i: usize = 0;
                var c: usize = 0;
                {
                    while(i < grammar.epsilon_index) : (i += 1) {
                        if(transition[i] != 0)
                            c += 1;
                    }
                }
                if(c > 0 and c < 10)
                {
                    i = 0;
                    while(i < grammar.epsilon_index) : (i += 1) {
                        if(transition[i] != 0)
                            try out.stream.print("{}, {}, ", i, transition[i]);
                    }
                }
                else if(c > 0)
                {
                    i = 1;
                    try out.stream.write("-1, ");
                    while(i < grammar.epsilon_index) : (i += 1) {
                        if(transition[i] != 0) {
                            try out.stream.print("{}, ", transition[i]);
                        }
                        else {
                            try out.stream.write("0, ");
                        }
                    }
                }
                try out.stream.write("},\n");
            }
            try out.stream.write("};\n\n");
        }

        // Shift
        {
            try out.stream.print("pub const shift_table = [{}][]const i16 {}\n", grammar.transitions.len, "{");
            var it = grammar.transitions.iterator();
            while(it.next()) |transition| {
                try out.stream.write("    [_]i16{");
                var i: usize = grammar.epsilon_index;
                var c: usize = 0;
                {
                    while(i < transition.len) : (i += 1) {
                        if(transition[i] > 0) {
                            c += 1;
                        }
                    }
                }
                if(c > 0 and c < 10)
                {
                    i = grammar.epsilon_index;
                    while(i < transition.len) : (i += 1) {
                        if(transition[i] > 0) {
                            try out.stream.print("{}, {}, ", i - grammar.epsilon_index, transition[i]);
                        }
                    }
                }
                else if(c > 0)
                {
                    try out.stream.write("-1, ");
                    i = grammar.epsilon_index+1;
                    while(i < transition.len) : (i += 1) {
                        if(transition[i] > 0) {
                            try out.stream.print("{}, ", transition[i]);
                        }
                        else {
                            try out.stream.write("0, ");
                        }
                    }
                }
                try out.stream.write("},\n");
            }
            try out.stream.write("};\n\n");
        }

        // Reduce
        {
            try out.stream.print("pub const reduce_table = [{}][]const i16 {}\n", grammar.transitions.len, "{");
            var it = grammar.transitions.iterator();
            while(it.next()) |transition| {
                try out.stream.write("    [_]i16{");
                var i: usize = grammar.epsilon_index;
                var v: i32 = -1;
                while(i < transition.len) : (i += 1) {
                    if(transition[i] < 0) {
                        if(v == -1) v = -transition[i];
                        if(-transition[i] != v) {
                            v = -2;
                            break;
                        }
                    }
                }
                if(v == -1) {
                    try out.stream.write("-1, -1,");
                }
                else if(v == -2) {
                    i = grammar.epsilon_index;
                    while(i < transition.len) : (i += 1) {
                        if(transition[i] < 0) {
                            try out.stream.print("{}, ", -transition[i]);
                        }
                        else {
                            try out.stream.write("0, ");
                        }
                    }
                }
                else {
                    try out.stream.print("0, {}, ", v);
                }
                try out.stream.write("},\n");
            }
            try out.stream.write("};\n\n");
        }
    }
}

pub fn main() !void {
    var file = try std.fs.File.openRead("ziglang.zig");
    defer file.close();

    var stream = file.inStream();
    const buffer = try stream.stream.readAllAlloc(default_heap, 0x1000000);
    defer default_heap.free(buffer);

    var tree = try std.zig.parse(default_heap, buffer);
    defer tree.deinit();

    // warn("Parsed {}\n", tree.root_node.decls.len);

    var it = tree.root_node.decls.iterator(0);
    while (it.next()) |decl| {
        if (decl.*.cast(Node.VarDecl)) |vardecl| {
            if (vardecl.lib_name) |lib| {
                if (lib.*.cast(Node.StringLiteral)) |lib_str| {
                    const name = tree.tokens.at(lib_str.token);
                    if (std.mem.compare(u8, buffer[name.start..name.end], "\"LALR\""[0..]) != .Equal)
                        continue;
                    if (vardecl.init_node) |init| {
                        if (init.*.cast(Node.ContainerDecl)) |container| {
                            const grammar_name = tree.tokens.at(vardecl.name_token);
                            var grammar = try parseGrammar(buffer[grammar_name.start..grammar_name.end], tree, buffer, container);
                            defer grammar.deinit();

                            try writeGrammar(grammar);
                        }
                    }
                }
            }
        }
    }
}
