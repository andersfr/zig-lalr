MODE=--release-fast

.PHONY: clean

all: main
	./main

run: main
	zig run main.zig

main: lalr zig_grammar.actions.zig zig_grammar.types.zig main.zig zig_lexer.zig lexer.tab.zig
	time zig build-exe --single-threaded ${MODE} main.zig

lalr: lalr.zig grammar.zig
	time zig build-exe --single-threaded ${MODE} lalr.zig

zig_grammar.actions.zig: lalr ziglang.zig
	time ./lalr ziglang.zig 2>isocores.txt && tail -n 3 isocores.txt
	zig fmt zig_grammar.tokens.zig
	zig fmt zig_grammar.actions.zig

lexer.tab.zig: lexer.ll.zig lexer.py
	./lexer.py lexer.ll.zig
	zig fmt lexer.tab.zig

clean:
	rm -rf zig-cache main lalr isocores.txt zig_grammar.tokens.zig zig_grammar.actions.zig zig_grammar.tables.zig
