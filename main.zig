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
    var name = try String.initWithValue(grammar.grammar_name);
    defer name.deinit();
    try name.append(".tokens.zig");

    // Tokens
    {
        var file = try std.fs.File.openWrite(name.view());
        defer file.close();

        var out = file.outStream();
        try out.stream.print("// AutoGenerated file\n\n");
        try out.stream.write("pub const Id = enum(u8) {\n");
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
    }

    // Grammar dump
    {
        try name.set(grammar.grammar_name);
        try name.append(".txt");

        var file = try std.fs.File.openWrite(name.view());
        defer file.close();

        var out = file.outStream();

        try grammar.debugToFile(&out);
    }
}

pub fn main() !void {
    var file = try std.fs.File.openRead("zigweb.zig");
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
