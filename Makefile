MODE=--release-fast

.PHONY: clean

all: main
	./main

run: main
	zig run main.zig

main: lalr zig_grammar.actions.zig main.zig zig_lexer.zig lexer.tab.zig
	time zig build-exe --single-threaded ${MODE} main.zig

lalr: ziglang.zig lalr.zig grammar.zig
	time zig build-exe --single-threaded ${MODE} lalr.zig

zig_grammar.actions.zig: lalr ziglang.zig
	./lalr 2>isocores.txt && tail -n 2 isocores.txt

lexer.tab.zig: lexer.ll.zig lexer.py
	./lexer.py lexer.ll.zig

clean:
	rm -rf zig-cache main lalr isocores.txt zig_grammar.*
