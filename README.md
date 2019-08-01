# zig-lalr
LALR parser generator written in native zig

You need a copy of my flat-hash table implementation to compile.
Running the LALR generator (lalr.zig) outputs a lot of debug to the screen.
Many conflicts are reported but they should all be correctly resolved.

1. git clone https://github.com/andersfr/zig-flat-hash.git
2. ln -s zig-flat-hash flat\_hash
3. zig run lalr.zig
4. python lexer.py lexer.ll.zig
5. zig run main.zig
