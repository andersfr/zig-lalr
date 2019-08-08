const std = @import("std");
const warn = std.debug.warn;

const String = @import("string.zig").String;
const Grammar = @import("grammar.zig").Grammar;
const Production = @import("grammar.zig").Production;
const SymbolType = @import("grammar.zig").SymbolType;
const PrecedenceType = @import("grammar.zig").PrecedenceType;
const PrecedenceMap = @import("grammar.zig").PrecedenceMap;

const Node = std.zig.ast.Node;

const default_heap = std.heap.c_allocator;

fn parsePrecedence(tree: *std.zig.ast.Tree, buffer: []const u8, proto: *Node.VarDecl) !PrecedenceMap {
    var dict = PrecedenceMap.init(default_heap);
    errdefer dict.deinitAndFreeKeys();

    const name = tree.tokens.at(proto.name_token);
    if(std.mem.compare(u8, buffer[name.start..name.end], "Precedence") != .Equal) return error.NotPrecedence;

    const init = proto.init_node orelse return error.NotPrecedence;
    const cont = init.cast(Node.ContainerDecl) orelse return error.NotPrecedence;

    var precedence: usize = 0;

    var fit = cont.fields_and_decls.iterator(0);
    while(fit.next()) |fld| {
        const field = fld.*.cast(Node.ContainerField) orelse return error.NotPrecedence;
        const field_name = tree.tokens.at(field.name_token);
        const assoc = buffer[field_name.start..field_name.end];

        const left = std.mem.compare(u8, assoc, "left") == .Equal;
        if(!left and std.mem.compare(u8, assoc, "right") != .Equal)
            return error.WrongAssociativity;

        const type_expr = field.type_expr orelse return error.NoPrecedenceEnum;
        const enum_decl = type_expr.cast(Node.ContainerDecl) orelse return error.NoPrecedenceEnum;

        precedence += 1;

        var eit = enum_decl.fields_and_decls.iterator(0);
        while(eit.next()) |val| {
            const value = val.*.cast(Node.ContainerField) orelse return error.NotPrecedence;
            const value_name = tree.tokens.at(value.name_token);
            const symbol = buffer[value_name.start..value_name.end];
            const result = try dict.insert(symbol);
            if(result.is_new) {
                result.kv.value = PrecedenceType{ .value = precedence, .left = left };
            }
            else {
                return error.DuplicatePrecedence;
            }
        }
    }
    return dict;
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

fn parseProduction(tree: *std.zig.ast.Tree, buffer: []const u8, proto: *Node.FnProto, precedence_map: ?PrecedenceMap) !*Production {
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
    switch(proto.return_type) {
        .Explicit => |explicit| {
            const symbol_type = try parseSymbolType(tree, buffer, explicit);
            prod.* = Production.init(default_heap, prod_name, symbol_type);
        },
        .InferErrorSet => |infer| {
            const symbol_type = try parseSymbolType(tree, buffer, infer);
            prod.* = Production.init(default_heap, prod_name, symbol_type);
        }
    }
    errdefer prod.deinit();

    if(proto.body_node) |body| {
        const s = tree.tokens.at(body.firstToken());
        const e = tree.tokens.at(body.lastToken());
        prod.body = buffer[s.start..e.end];
        if(std.mem.compare(u8, prod.body, "{}") == .Equal)
            prod.body = "";
    }

    // Parse each element in production
    var it = proto.params.iterator(0);
    while (it.next()) |param| {
        if (param.*.cast(Node.ParamDecl)) |decl| {
            if (decl.name_token) |name_token| {
                const param_name = tree.tokens.at(name_token);
                const param_str = buffer[param_name.start..param_name.end];

                if(decl.type_node.cast(Node.SuffixOp)) |suffix| {
                    if(suffix.lhs.cast(Node.Identifier)) |precedence| {
                        const precedence_name = tree.tokens.at(precedence.token);
                        const precedence_str = buffer[precedence_name.start..precedence_name.end];
                        switch(suffix.op) {
                            .Call => |call| {
                                if(call.params.len == 1) {
                                    const symbol_type = try parseSymbolType(tree, buffer, @intToPtr(*Node, @ptrToInt(call.params.at(0).*)));
                                    // Append the parameter name
                                    if(precedence_map) |map| {
                                        const result = map.find(precedence_str);
                                        if(result) |kv| {
                                            try prod.append(param_str, precedence_str, kv.value.value, kv.value.left, symbol_type);
                                            continue;
                                        }
                                    }
                                    try prod.append(param_str, precedence_str, 0, true, symbol_type);
                                }
                            },
                            else => {}
                        }
                    }
                }
                else {
                    const symbol_type = try parseSymbolType(tree, buffer, decl.type_node);
                    if(precedence_map) |map| {
                        const result = map.find(param_str);
                        if(result) |kv| {
                            try prod.append(param_str, kv.key, kv.value.value, kv.value.left, symbol_type);
                            continue;
                        }
                    }
                    try prod.append(param_str, null, 0, true, symbol_type);
                }
            }
        }
    }

    return prod;
}

fn parseGrammar(name: []const u8, tree: *std.zig.ast.Tree, buffer: []const u8, container: *Node.ContainerDecl) !Grammar {
    var grammar = Grammar.init(default_heap, name);
    errdefer grammar.deinit();

    var precedence_map: ?PrecedenceMap = null;
    defer if(precedence_map) |*p| p.deinitAndFreeKeys();

    var g = container.fields_and_decls.iterator(0);
    while (g.next()) |fld| {
        if (fld.*.cast(Node.VarDecl)) |precedence| {
            precedence_map = try parsePrecedence(tree, buffer, precedence);
        }
        else if (fld.*.cast(Node.FnProto)) |production| {
            const prod = try parseProduction(tree, buffer, production, precedence_map);
            try grammar.append(prod);
        }
    }
    try grammar.finalize(precedence_map);
    return grammar;
}

fn best_default_reduce(transition: []const i32) i32 {
    var i: usize = 1;
    var c: usize = 1;
    var v: i32 = transition[0];
    while(i < transition.len) : (i += 1) {
        if(transition[i] >= 0) continue;
        if(transition[i] == v) {
            c += 1;
            if(c > 8) return v;
            continue;
        }
        var j = i+1;
        while(j < transition.len) : (j += 1) {
            if(transition[j] >= 0) continue;
            if(transition[j] == v) {
                c += 1;
                if(c > 8) return v;
            }
        }
        v = transition[i];
    }
    return 0;
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

    var types_name = try String.initWithValue(grammar.grammar_name);
    defer types_name.deinit();
    try types_name.append(".types.zig");

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
            \\    line: ?*@This() = null,
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
        try out.stream.write("// AutoGenerated file\n\n");
        try out.stream.print("const Types = @import(\"{}\");\n", types_name.view());
        try out.stream.print("const Tokens = @import(\"{}\");\n\n", tokens_name.view());

        try out.stream.write(
            \\usingnamespace Types;
            \\usingnamespace Tokens;
            \\
            \\pub const StackItem = struct {
            \\    item: usize,
            \\    state: i16,
            \\    value: StackValue,
            \\};
            \\
            \\pub const StackValue = union(enum) {
            \\    Token: Id,
            \\    Terminal: TerminalId,
            \\};
            \\
            \\pub fn reduce_actions(comptime Parser: type, parser: *Parser, rule: isize, state: i16) !TerminalId {
            \\    switch(rule) {
            \\
        );
        var i: usize = 1;
        while(i < grammar.productions.len) : (i += 1) {
            const production = grammar.productions.items[i];

            try out.stream.print(" " ** 8 ++ "{} => ", i);
            try out.stream.write("{\n");
            try out.stream.print(" " ** 12 ++ "// Symbol: {}\n", grammar.names_index_map.keyOf(production.terminal_id));
            if(production.terminal_type.optional) {
                try out.stream.print(" " ** 12 ++ "var result: ?*{} = null;\n", production.terminal_type.name);
            }
            else {
                try out.stream.print(" " ** 12 ++ "var result: *{} = undefined;\n", production.terminal_type.name);
            }
            // try out.stream.print(" " ** 12 ++ "// {} <-", grammar.names_index_map.keyOf(production.terminal_id));
            // for(production.symbol_ids) |id| {
            //     try out.stream.print(" {}", grammar.names_index_map.keyOf(id));
            // }
            // try out.stream.write("\n");
            var ti: usize = 0;
            while(ti < production.symbol_types.len) : (ti += 1) {
                const symbol_type = production.symbol_types.items[ti];
                if(symbol_type.name[0] == '$') continue;
                try out.stream.print(" " ** 12 ++ "// Symbol: {}\n", grammar.names_index_map.keyOf(production.symbol_ids[ti]));
                try out.stream.print(" " ** 12 ++ "const arg{} = @intToPtr(?*{}, parser.stack.items[parser.stack.len - {}].item){};\n", ti+1, symbol_type.name, production.symbol_types.len - ti, if(symbol_type.optional) "" else ".?");
                // try out.stream.print(" " ** 12 ++ "const val{} = parser.stack.items[parser.stack.len - {}].value;\n", ti+1, production.symbol_types.len - ti);
            }
            try out.stream.write("\n");
            if(production.consumes == 1) {
                try out.stream.write(" " ** 12 ++ "parser.state = parser.stack.items[parser.stack.len-1].state;\n");
            }
            else if(production.consumes > 1) {
                try out.stream.print(" " ** 12 ++ "// Adjust the parse stack and current state\n");
                try out.stream.print(" " ** 12 ++ "parser.stack.len -= {};\n", production.consumes-1);
                try out.stream.write(" " ** 12 ++ "parser.state = parser.stack.items[parser.stack.len-1].state;\n");
            }
            if(production.body.len > 0) {
                try out.stream.write(" " ** 12);
                try out.stream.write(production.body);
                try out.stream.write("\n");
            }
            else {
            }
            if(production.consumes == 0) {
                try out.stream.print(" " ** 12 ++ "// Push the result of the reduce action\n");
                try out.stream.write(" " ** 12 ++ "try parser.stack.append(StackItem{ .item = @ptrToInt(result), .state = state, .value = StackValue{ .Terminal = ");
                try out.stream.print(".{} ", production.terminal);
                try out.stream.write("} });\n");
            }
            else {
                try out.stream.write(" " ** 12 ++ "parser.stack.items[parser.stack.len-1].state = parser.state;\n");
                try out.stream.write(" " ** 12 ++ "parser.stack.items[parser.stack.len-1].value = StackValue{ .Terminal = ");
                try out.stream.print(".{} ", production.terminal);
                try out.stream.write("};\n");
                if(production.body.len > 0 or production.consumes > 1 or std.mem.compare(u8, production.terminal_type.name, production.symbol_types.items[0].name) != .Equal) {
                    try out.stream.write(" " ** 12 ++ "parser.stack.items[parser.stack.len-1].item = @ptrToInt(result);\n");
                    // try out.stream.write(" " ** 12 ++ "parser.stack.items[parser.stack.len-1].item = 0x42424242;\n");
                }
            }
            try out.stream.print(" " ** 12 ++ "return TerminalId.{};\n", production.terminal);
            try out.stream.write(" " ** 8 ++ "},\n");
        }
        try out.stream.write(" " ** 8 ++ "else => unreachable,\n");
        try out.stream.write("    }\n");
        try out.stream.write("    return error.ReduceError;\n");
        try out.stream.write("}\n");
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
            try out.stream.write("    ");
            var it = grammar.productions.iterator();
            while(it.next()) |production| {
                try out.stream.print("{}, ", production.terminal_id);
            }
            try out.stream.write("\n};\n\n");
        }

        // Consumes
        {
            try out.stream.print("pub const consumes_table = [{}]u8 {}\n", grammar.productions.len, "{");
            try out.stream.write("    ");
            var it = grammar.productions.iterator();
            while(it.next()) |production| {
                try out.stream.print("{}, ", production.consumes);
            }
            try out.stream.write("\n};\n\n");
        }

        // Goto
        {
            try out.stream.print("pub const goto_table = [_][{}]i16 {}\n", grammar.epsilon_index, "{");
            { 
                try out.stream.write("    [_]i16{");
                var i: usize = 0; while(i < grammar.epsilon_index) : (i += 1) { try out.stream.write("0, "); }
                try out.stream.write("},\n");
            }
            var it = grammar.transitions.iterator();
            outer: while(it.next()) |transition| {
                var i: usize = 0;
                blk: {
                    while(i < grammar.epsilon_index) : (i += 1) {
                        if(transition[i] != 0)
                            break :blk;
                    }
                    continue :outer;
                }
                try out.stream.write("    [_]i16{");
                i = 0;
                while(i < grammar.epsilon_index) : (i += 1) {
                    if(transition[i] != 0) {
                        try out.stream.print("{}, ", transition[i]);
                    }
                    else {
                        try out.stream.write("0, ");
                    }
                }
                try out.stream.write("},\n");
            }
            try out.stream.write("};\n\n");

            try out.stream.print("pub const goto_index = [{}]u16 {}\n", grammar.transitions.len, "{");
            it = grammar.transitions.iterator();
            var c: usize = 1;
            try out.stream.write("    ");
            while(it.next()) |transition| {
                var i: usize = 0;
                var empty: bool = true;
                {
                    while(empty and i < grammar.epsilon_index) : (i += 1) {
                        if(transition[i] != 0)
                            empty = false;
                    }
                }
                if(empty) {
                    try out.stream.write("0, ");
                }
                else {
                    try out.stream.print("{}, ", c);
                    c += 1;
                }
            }
            try out.stream.write("\n};\n\n");
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
                if(c > 0 and c < 16)
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
                        }
                    }
                }
                if(v == -2) {
                    const c = @truncate(i16, best_default_reduce(transition));
                    i = grammar.epsilon_index;
                    while(i < transition.len) : (i += 1) {
                        if(transition[i] < 0 and transition[i] != c) {
                            try out.stream.print("{}, {}, ", i - grammar.epsilon_index, -transition[i]);
                        }
                    }
                    if(c < 0) {
                        try out.stream.print("-1, {}, ", -c);
                    }
                }
                else if(v >= 0) {
                    try out.stream.print("-1, {}, ", v);
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
