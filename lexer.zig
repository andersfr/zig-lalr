const std = @import("std");
const assert = std.debug.assert;
const lexer_tables = @import("lexer.tab.zig");
const Allocator = std.mem.Allocator;

const init_state = lexer_tables.init_state;
const rle_states = lexer_tables.rle_states;
const rle_indices = lexer_tables.rle_indices;
const accept_states = lexer_tables.accept_states;
const accept_tokens = lexer_tables.accept_tokens;
const lexer_switch = lexer_tables.lexer_switch;

const Parser = @import("zig_grammar.actions.zig").Parser;
const Token = @import("zig_grammar.tokens.zig").Token;
const Id = @import("zig_grammar.tokens.zig").Id;
// pub const Token = struct {
//     pub const Id = lexer_tables.Id;

//     id: Id,
//     start: usize,
//     end: usize,
// };

pub const Lexer = struct {
    state: [128]u16,
    first: usize,
    index: usize,
    steps: usize,
    source: []const u8,
    char: i32,
    peek: i32,
    exit: u16,
    valid: u8,

    pub fn init(source: []const u8) Lexer {
        var peek: u8 = 255;
        if (source.len > 0) {
            peek = source[0];
        }
        return Lexer{
            .state = [1]u16{0} ** 128,
            .first = 0,
            .index = 0,
            .source = source,
            .char = 0,
            .peek = peek,
            .exit = 0,
            .valid = 0,
            .steps = 0,
        };
    }

    // Deal with lookahead and EOF
    fn getc(self: *@This()) i32 {
        self.char = self.peek;
        self.index += 1;
        if (self.index < self.source.len) {
            self.peek = self.source[self.index];
        } else {
            self.peek = -1;
        }
        return self.char;
    }

    // Rewind to a valid tokenizer state
    fn rewind(self: *@This()) void {
        self.index -= self.steps + 1;
        _ = self.getc();
        self.peek = self.getc();
    }

    // Process and accept a token
    fn process(self: *@This()) Id {
        // Check what is to be accepted
        var accept = accept_states[self.exit];

        // Reset variable state
        for (self.state) |*v| {
            v.* = 0;
        }

        // 0 always maps to Token.Id.Invalid
        if (accept == 0) {
            // Check if a partial parse was valid
            if (self.valid != 0) {
                // Rewind back to the partial parse
                accept = self.valid;
                self.rewind();
            }
            // Check if it is the EOF boundary condition
            else if (self.peek == -1) {
                return .Eof;
            }
            // Otherwise it is just invalid
            else {
                return .Invalid;
            }
        }

        // Reset some more state
        self.valid = 0;
        self.exit = 0;

        // Check if it accepts into a simple Id without further processing
        if (accept < accept_tokens.len) {
            return accept_tokens[accept];
        }

        // Use the custom acceptor functions
        return lexer_switch(self, accept - @intCast(u8, accept_tokens.len));
    }

    // Get the next token in parse; always ends with Token.Id.Eof
    pub fn next(self: *@This()) Token {
        var state: u16 = 0;

        self.first = self.index;
        self.exit = 0;
        self.steps = 0;

        // Keep parsing until EOF
        while (self.char != -1) {
            // The bitmasking and casting is just to avoid UB and make Zig happy
            var peek = @intCast(usize, self.peek & 0x7f);
            // Check if lookahead is EOF; map to \x00 which is always invalid for parsing
            if (self.peek == -1) {
                peek = 0;
            }
            // Check if illegal character, ie. >= 0x80
            else if (self.peek & 0x80 != 0) {
                // Discard and return Token.Id.Invalid; no attempt to parse potential unicode
                _ = self.getc();
                return Token{ .id = .Invalid, .start = self.first, .end = self.index };
            }

            // Check acceptance state
            const accept = accept_states[self.exit];
            // If valid we have the option of rewinding to this parse location
            if (accept != 0) {
                self.valid = accept;
                self.steps = 0;
            }
            // Keep track of rewinding steps
            self.steps += 1;
            // Remember the state about to be exited upon transition
            self.exit = state;

            // Variable state is updated as we go
            if (state != 0) {
                state = self.state[peek];
            }
            // Initial state is hardcoded into parser
            else {
                state = init_state[peek];
            }

            // Current parse state is invalid which means a token must exist upstream
            if (state == 0) {
                // Find the token
                const r = self.process();
                // Spaces are ignored
                if (r != .Ignore) {
                    // Invalid parses may be of variable length. Most sane option is to remove one character at a time
                    if (r == .Invalid) {
                        self.index = self.first;
                        _ = self.getc();
                    }
                    return Token{ .id = r, .start = self.first, .end = self.index };
                }
                // Resume parse after ignored input
                self.first = self.index;
                self.steps = 0;
                continue;
            }

            // Consume a character to make progress
            _ = self.getc();

            // Update variable state using the special run-length encoded state table
            var rle_iter = rle_indices[state];
            while (rle_states[rle_iter] != 65535) : (rle_iter += 3) {
                var i = rle_states[rle_iter];
                const e = rle_states[rle_iter + 1];
                const v = rle_states[rle_iter + 2];
                while (i <= e) : (i += 1) {
                    self.state[i] = v;
                }
            }
        }
        // No more input; return Eof
        return Token{ .id = .Eof, .start = self.first, .end = self.index };
    }
};

pub fn main() !void {
    // var file = try std.fs.File.openRead("lexer.zig");
    var file = try std.fs.File.openRead("../zig/std/zig/parse.zig");
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

test "lexer.zig" {
    _ = @import("lexer_test.zig");
}
