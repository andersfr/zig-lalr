# zig-lalr
LALR parser generator written in native zig

You need a copy of my flat-hash table implementation to compile.
Running the LALR generator (main.zig) outputs a lot of debug to the screen.
Many conflicts are reported by they should all be correctly resolved.

zig run main.zig
python lexer.py lexer.ll.zig
zig run lexer.zig
