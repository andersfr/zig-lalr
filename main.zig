const std = @import("std");
const warn = std.debug.warn;

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
                // Full table
                if (reduce_table[state][0] == 0 and reduce_table[state].len > 2) {
                    reduce = reduce_table[state][@bitCast(u16, id)];
                }
                // Default
                else if (reduce_table[state][0] == 0) {
                    reduce = reduce_table[state][1];
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

pub fn idToString(id: Id) []const u8 {
    switch(id) {
        .Builtin                            => return "@",
        .Ampersand                          => return "&",
        .AmpersandEqual                     => return "&=",
        .Asterisk                           => return "*",
        .AsteriskAsterisk                   => return "**",
        .AsteriskEqual                      => return "*=",
        .AsteriskPercent                    => return "*%",
        .AsteriskPercentEqual               => return "*%=",
        .Caret                              => return "^",
        .CaretEqual                         => return "^=",
        .Colon                              => return ":",
        .Comma                              => return ",",
        .Period                             => return ".",
        .Ellipsis2                          => return "..",
        .Ellipsis3                          => return "...",
        .Equal                              => return "=",
        .EqualEqual                         => return "==",
        .EqualAngleBracketRight             => return "=>",
        .Bang                               => return "!",
        .BangEqual                          => return "!=",
        .AngleBracketLeft                   => return "<",
        .AngleBracketAngleBracketLeft       => return "<<",
        .AngleBracketAngleBracketLeftEqual  => return "<<=",
        .AngleBracketLeftEqual              => return "<=",
        .LBrace                             => return "{",
        .LBracket                           => return "[",
        .LParen                             => return "(",
        .Minus                              => return "-",
        .MinusEqual                         => return "-=",
        .MinusAngleBracketRight             => return "->",
        .MinusPercent                       => return "-%",
        .MinusPercentEqual                  => return "-%=",
        .Percent                            => return "%",
        .PercentEqual                       => return "%=",
        .Pipe                               => return "|",
        .PipePipe                           => return "||",
        .PipeEqual                          => return "|=",
        .Plus                               => return "+",
        .PlusPlus                           => return "++",
        .PlusEqual                          => return "+=",
        .PlusPercent                        => return "+%",
        .PlusPercentEqual                   => return "+%=",
        .BracketStarCBracket                => return "[*c]",
        .BracketStarBracket                 => return "[*]",
        .QuestionMark                       => return "?",
        .AngleBracketRight                  => return ">",
        .AngleBracketAngleBracketRight      => return ">>",
        .AngleBracketAngleBracketRightEqual => return ">>=",
        .AngleBracketRightEqual             => return ">=",
        .RBrace                             => return "}",
        .RBracket                           => return "]",
        .RParen                             => return ")",
        .Semicolon                          => return ";",
        .Slash                              => return "/",
        .SlashEqual                         => return "/=",
        .Tilde                              => return "~",
        .Keyword_align                      => return "align",
        .Keyword_allowzero                  => return "allowzero",
        .Keyword_and                        => return "and",
        .Keyword_asm                        => return "asm",
        .Keyword_async                      => return "async",
        .Keyword_await                      => return "await",
        .Keyword_break                      => return "break",
        .Keyword_catch                      => return "catch",
        .Keyword_cancel                     => return "cancel",
        .Keyword_comptime                   => return "comptime",
        .Keyword_const                      => return "const",
        .Keyword_continue                   => return "continue",
        .Keyword_defer                      => return "defer",
        .Keyword_else                       => return "else",
        .Keyword_enum                       => return "enum",
        .Keyword_errdefer                   => return "errdefer",
        .Keyword_error                      => return "error",
        .Keyword_export                     => return "export",
        .Keyword_extern                     => return "extern",
        .Keyword_false                      => return "false",
        .Keyword_fn                         => return "fn",
        .Keyword_for                        => return "for",
        .Keyword_if                         => return "if",
        .Keyword_inline                     => return "inline",
        .Keyword_nakedcc                    => return "nakedcc",
        .Keyword_noalias                    => return "noalias",
        .Keyword_null                       => return "null",
        .Keyword_or                         => return "or",
        .Keyword_orelse                     => return "orelse",
        .Keyword_packed                     => return "packed",
        .Keyword_promise                    => return "promise",
        .Keyword_pub                        => return "pub",
        .Keyword_resume                     => return "resume",
        .Keyword_return                     => return "return",
        .Keyword_linksection                => return "linksection",
        .Keyword_stdcallcc                  => return "stdcallcc",
        .Keyword_struct                     => return "struct",
        .Keyword_suspend                    => return "suspend",
        .Keyword_switch                     => return "switch",
        .Keyword_test                       => return "test",
        .Keyword_threadlocal                => return "threadlocal",
        .Keyword_true                       => return "true",
        .Keyword_try                        => return "try",
        .Keyword_undefined                  => return "undefined",
        .Keyword_union                      => return "union",
        .Keyword_unreachable                => return "unreachable",
        .Keyword_use                        => return "use",
        .Keyword_usingnamespace             => return "usingnamespace",
        .Keyword_var                        => return "var",
        .Keyword_volatile                   => return "volatile",
        .Keyword_while                      => return "while",

        .Invalid                            => return "$invalid",
        .Eof                                => return "$eof",
        .Newline                            => return "$newline",
        .Ignore                             => return "$ignore",
        .ShebangLine                        => return "#!",
        .LineComment                        => return "//",
        .DocComment                         => return "///",
        .LineString                         => return "\\",
        .LineCString                        => return "c\\",

        .Identifier                         => return "Identifier",
        .CharLiteral                        => return "CharLiteral",
        .StringLiteral                      => return "StringLiteral",
        .IntegerLiteral                     => return "IntegerLiteral",
        .FloatLiteral                       => return "FloatLiteral",
        //else => unreachable,
    }
}
