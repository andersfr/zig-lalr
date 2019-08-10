const std = @import("std");
const assert = std.debug.assert;

const Token = @import("json_grammar.tokens.zig").Token;
pub const TokenIndex = *Token;

const FlatHash = @import("flat_hash/flat_hash.zig");

usingnamespace FlatHash;

pub const VariantList = std.ArrayList(*Variant);
pub const VariantMap = Dictionary(*Variant);

pub const Variant = struct {
    id: Id,

    pub const Id = enum {
        Object,
        Array,
        IntegerLiteral,
        StringLiteral,
        BoolLiteral,
    };

    pub fn cast(base: *Variant, comptime T: type) ?*T {
        if (base.id == comptime typeToId(T)) {
            return @fieldParentPtr(T, "base", base);
        }
        return null;
    }

    pub fn unsafe_cast(base: *Variant, comptime T: type) *T {
        return @fieldParentPtr(T, "base", base);
    }

    pub fn iterate(base: *Variant, index: usize) ?*Variant {
        comptime var i = 0;
        inline while (i < @memberCount(Id)) : (i += 1) {
            if (base.id == @field(Id, @memberName(Id, i))) {
                const T = @field(Variant, @memberName(Id, i));
                return @fieldParentPtr(T, "base", base).iterate(index);
            }
        }
        unreachable;
    }

    pub fn firstToken(base: *const Variant) TokenIndex {
        comptime var i = 0;
        inline while (i < @memberCount(Id)) : (i += 1) {
            if (base.id == @field(Id, @memberName(Id, i))) {
                const T = @field(Variant, @memberName(Id, i));
                return @fieldParentPtr(T, "base", base).firstToken();
            }
        }
        unreachable;
    }

    pub fn lastToken(base: *const Variant) TokenIndex {
        comptime var i = 0;
        inline while (i < @memberCount(Id)) : (i += 1) {
            if (base.id == @field(Id, @memberName(Id, i))) {
                const T = @field(Variant, @memberName(Id, i));
                return @fieldParentPtr(T, "base", base).lastToken();
            }
        }
        unreachable;
    }

    pub fn typeToId(comptime T: type) Id {
        comptime var i = 0;
        inline while (i < @memberCount(Id)) : (i += 1) {
            if (T == @field(Variant, @memberName(Id, i))) {
                return @field(Id, @memberName(Id, i));
            }
        }
        unreachable;
    }

    pub fn dump(self: *Variant, indent: usize) void {
        {
            var i: usize = 0;
            while (i < indent) : (i += 1) {
                std.debug.warn(" ");
            }
        }
        const first = self.firstToken();
        const last = self.lastToken();
        const first_nl = first.line.?;
        const last_nl = last.line.?;
        const first_col = first.start - first_nl.end + 1;
        const last_col = last.end - last_nl.end;
        const first_line = first_nl.start;
        const last_line = last_nl.start;

        std.debug.warn("{} ({}:{}-{}:{})\n", @tagName(self.id), first_line, first_col, last_line, last_col);

        var child_i: usize = 0;
        while (self.iterate(child_i)) |child| : (child_i += 1) {
            child.dump(indent + 2);
        }
    }

    pub const Object = struct {
        base: Variant,
        lbrace: TokenIndex,
        fields: VariantMap,
        rbrace: TokenIndex,

        pub fn iterate(self: *Object, index: usize) ?*Variant {
            if(index >= self.fields.size)
                return null;

            var it = self.fields.iterator();
            var i: usize = 0;
            while(it.next()) |v| : (i += 1) {
                if(i == index)
                    return v.value;
            }

            return null;
        }

        pub fn firstToken(self: *const Object) TokenIndex {
            return self.lbrace;
        }

        pub fn lastToken(self: *const Object) TokenIndex {
            return self.rbrace;
        }
    };

    pub const Array = struct {
        base: Variant,
        lbracket: TokenIndex,
        elements: VariantList,
        rbracket: TokenIndex,

        pub fn iterate(self: *Array, index: usize) ?*Variant {
            if (index < self.elements.len) {
                return self.elements.at(index);
            }
            return null;
        }

        pub fn firstToken(self: *const Array) TokenIndex {
            return self.lbracket;
        }

        pub fn lastToken(self: *const Array) TokenIndex {
            return self.rbracket;
        }
    };

    pub const StringLiteral = struct {
        base: Variant,
        token: TokenIndex,

        pub fn iterate(self: *StringLiteral, index: usize) ?*Variant {
            return null;
        }

        pub fn firstToken(self: *const StringLiteral) TokenIndex {
            return self.token;
        }

        pub fn lastToken(self: *const StringLiteral) TokenIndex {
            return self.token;
        }
    };

    pub const IntegerLiteral = struct {
        base: Variant,
        token: TokenIndex,

        pub fn iterate(self: *IntegerLiteral, index: usize) ?*Variant {
            return null;
        }

        pub fn firstToken(self: *const IntegerLiteral) TokenIndex {
            return self.token;
        }

        pub fn lastToken(self: *const IntegerLiteral) TokenIndex {
            return self.token;
        }
    };

    pub const BoolLiteral = struct {
        base: Variant,
        token: TokenIndex,

        pub fn iterate(self: *BoolLiteral, index: usize) ?*Variant {
            return null;
        }

        pub fn firstToken(self: *const BoolLiteral) TokenIndex {
            return self.token;
        }

        pub fn lastToken(self: *const BoolLiteral) TokenIndex {
            return self.token;
        }
    };
};

