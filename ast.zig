const std = @import("std");
const ArrayList = std.ArrayList;

pub const Token = struct {
    id: Id,

    pub const Id = enum(u8) { Invalid = 0 };
};

pub const Node = struct {
    id: Id,

    const Self = @This();

    pub const Id = enum {
        If,
        For,
        While,
        Block,
        BlockLabel,
        BreakLabel,
        Unreachable,
        Suspend,
        Resume,
        Cancel,
        Break,
        Continue,
        Usingnamespace,
        Comptime,
        Try,
        Await,
        Defer,
        VarDecl,
        Assignment,
        Identifier,
        Chain,
        Ref,
        Deref,
        Unwrap,
        Slice,
        Call,
        BuiltinCall,
        Payload,
        Align,

        // Literals
        IntegerLiteral,
        FloatLiteral,
        EnumLiteral,
        StringLiteral,
        MultilineStringLiteral,
        CharLiteral,
        BoolLiteral,
        NullLiteral,
        UndefinedLiteral,
    };

    pub fn cast(base: *Node, comptime T: type) ?*T {
        if (base.id == comptime typeToId(T)) {
            return @fieldParentPtr(T, "base", base);
        }
        return null;
    }

    pub fn typeToId(comptime T: type) Id {
        comptime var i = 0;
        inline while (i < @memberCount(Id)) : (i += 1) {
            if (T == @field(Node, @memberName(Id, i))) {
                return @field(Id, @memberName(Id, i));
            }
        }
        unreachable;
    }

    pub const NodeList = ArrayList(*Self, 4);
    pub const TokenList = ArrayList(*Token, 4);
    pub const Statements = NodeList;
    pub const Arguments = NodeList;

    pub const Block = struct {
        base: Node = Node{ .id = .Block },
        statements: ?*Statements,
        label: ?*Node,
        lbrace: *Token,
        rbrace: *Token,
    };

    pub const BlockLabel = struct {
        base: Node = Node{ .id = .BlockLabel },
        identifier: *Token,
        colon: *Token,
    };

    pub const BreakLabel = struct {
        base: Node = Node{ .id = .BreakLabel },
        identifier: *Token,
        colon: *Token,
    };

    pub const Unreachable = struct {
        base: Node = Node{ .id = .Unreachable },
        token: *Token,
    };

    pub const Suspend = struct {
        base: Node = Node{ .id = .Suspend },
        block: ?*Block = null,
        token: *Token,
    };

    pub const Resume = struct {
        base: Node = Node{ .id = .Resume },
        handle: *Node,
        token: *Token,
    };

    pub const Cancel = struct {
        base: Node = Node{ .id = .Cancel },
        handle: *Node,
        token: *Token,
    };

    pub const Break = struct {
        base: Node = Node{ .id = .Break },
        label: ?*Node = null,
        value: ?*Node = null,
        token: *Token,
    };

    pub const Continue = struct {
        base: Node = Node{ .id = .Continue },
        label: ?*Node,
        token: *Token,
    };

    pub const Usingnamespace = struct {
        base: Node = Node{ .id = .Usingnamespace },
        value: *Node,
        token: *Token,
    };

    pub const Comptime = struct {
        base: Node = Node{ .id = .Comptime },
        statement: *Node,
        token: *Token,
    };

    pub const Try = struct {
        base: Node = Node{ .id = .Try },
        token: *Token,
        rhs: *Node,
    };

    pub const Await = struct {
        base: Node = Node{ .id = .Await },
        token: *Token,
        rhs: *Node,
    };

    pub const Defer = struct {
        base: Node = Node{ .id = .Defer },
        statement: *Node,
        token: *Token,
        is_errdefer: bool,
    };

    pub const VarDecl = struct {
        base: Node = Node{ .id = .VarDecl },
        token: *Token,
        identifier: *Token,
        decltype: ?*Node = null,
        bytealign: ?*Node = null,
        section: ?*Node = null,
        initializer: ?*Node = null,
        is_const: bool,
    };

    pub const Assignment = struct {
        base: Node = Node{ .id = .Assignment },
        lhs: *Node,
        token: *Token,
        rhs: *Node,
    };

    pub const Identifier = struct {
        base: Node = Node{ .id = .Identifier },
        token: *Token,
    };

    pub const Chain = struct {
        base: Node = Node{ .id = .Chain },
        parts: NodeList,
    };

    pub const Ref = struct {
        base: Node = Node{ .id = .Ref },
        token: *Token,
        rhs: *Node,
    };

    pub const Deref = struct {
        base: Node = Node{ .id = .Deref },
        token: *Token,
    };

    pub const Unwrap = struct {
        base: Node = Node{ .id = .Unwrap },
        token: *Token,
    };

    pub const Slice = struct {
        base: Node = Node{ .id = .Slice },
        lhs: ?*Node = null,
        lbracket: *Token,
        begin: *Node,
        ellipsis: ?*Token = null,
        end: ?*Node = null,
        rbracket: *Token,
    };

    pub const Call = struct {
        base: Node = Node{ .id = .Call },
        lparen: *Token,
        arguments: ?*Arguments = null,
        rparen: *Token,
    };

    pub const BuiltinCall = struct {
        base: Node = Node{ .id = .BuiltinCall },
        token: *Token,
        identifier: *Token,
        arguments: ?*Arguments = null,
    };

    pub const Payload = struct {
        base: Node = Node{ .id = .Payload },
        lpipe: *Token,
        identifier: *Token,
        index: ?*Token = null,
        rpipe: *Token,
        bool is_ptr = false,
    };

    pub const Align = struct {
        base: Node = Node{ .id = .Align },
        token: *Token,
        lparen: *Token,
        value: *Node,
        bit_start: ?*Node = null,
        bit_end: ?*Node = null,
        rparen: *Token,
    };

    pub const IntegerLiteral = struct {
        base: Node = Node{ .id = .IntegerLiteral },
        token: *Token,
    };

    pub const FloatLiteral = struct {
        base: Node = Node{ .id = .FloatLiteral },
        token: *Token,
    };

    pub const EnumLiteral = struct {
        base: Node = Node{ .id = .EnumLiteral },
        token: *Token,
    };

    pub const StringLiteral = struct {
        base: Node = Node{ .id = .StringLiteral },
        token: *Token,
    };

    pub const MultilineStringLiteral = struct {
        base: Node = Node{ .id = .MultilineStringLiteral },
        tokens: TokenList,
    };

    pub const CharLiteral = struct {
        base: Node = Node{ .id = .CharLiteral },
        token: *Token,
    };

    pub const BoolLiteral = struct {
        base: Node = Node{ .id = .BoolLiteral },
        token: *Token,
        is_true: bool,
    };

    pub const NullLiteral = struct {
        base: Node = Node{ .id = .NullLiteral },
        token: *Token,
    };

    pub const UndefinedLiteral = struct {
        base: Node = Node{ .id = .UndefinedLiteral },
        token: *Token,
    };
};

