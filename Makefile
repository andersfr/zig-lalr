MODE=--release-fast

.PHONY: clean

all: main jsonrpc
	# ./main

run_main: main
	zig run main.zig

run_json: jsonrpc
	zig run jsonrpc.zig

main: lalr zig_grammar.actions.zig zig_grammar.types.zig main.zig zig_lexer.zig lexer.tab.zig zig_parser.zig
	time zig build-exe --single-threaded ${MODE} main.zig

jsonrpc: lalr json_grammar.actions.zig json_grammar.types.zig json.zig jsonrpc.zig json_lexer.zig zig_parser.zig
	time zig build-exe --single-threaded ${MODE} jsonrpc.zig

lalr: lalr.zig grammar.zig
	time zig build-exe --single-threaded ${MODE} lalr.zig

zig_grammar.actions.zig: lalr ziglang.zig
	time ./lalr ziglang.zig 2>zig_isocores.txt && tail -n 3 zig_isocores.txt
	zig fmt zig_grammar.tokens.zig
	zig fmt zig_grammar.actions.zig

json_grammar.actions.zig: lalr jsonlang.zig
	time ./lalr jsonlang.zig 2>json_isocores.txt
	zig fmt json_grammar.tokens.zig
	zig fmt json_grammar.actions.zig

lexer.tab.zig: lexer.ll.zig lexer.py
	./lexer.py lexer.ll.zig
	zig fmt lexer.tab.zig

clean:
	rm -rf zig-cache main lalr zig_isocores.txt zig_grammar.txt zig_grammar.tokens.zig zig_grammar.actions.zig zig_grammar.tables.zig json_isocores.txt json_grammar.txt json_grammar.tokens.zig json_grammar.actions.zig json_grammar.tables.zig
