const std = @import("std");

const Lexer = @import("zig_lexer.zig").Lexer;
const Parser = @import("zig_grammar.actions.zig").Parser;
const Token = @import("zig_grammar.tokens.zig").Token;
const Id = @import("zig_grammar.tokens.zig").Id;

pub fn main() !void {
    var file = try std.fs.File.openRead("main.zig");
    // var file = try std.fs.File.openRead("../zig/std/zig/parse.zig");
    defer file.close();

    var allocator = std.heap.c_allocator;

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

        parser.action(&token) catch { std.debug.warn("\nline: {}\n", line); return error.ParserError; };
        if(token.id == .Eof)
            break;
    }
}

