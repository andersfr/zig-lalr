usingnamespace @import("ast.zig");

pub extern "LALR" const ZigGrammar = struct {
    // Blocks
    fn Block(LBrace: *Token, RBrace: *Token) *Node {
        const node = try allocator.create(Node.Block);
        node.* = Node.Block{ .lbrace = arg1, .rbrace = arg2, };
        result = node;
    }
    fn Block(LBrace: *Token, Statements: *Node.Statements, RBrace: *Token) *Node {
        const node = try allocator.create(Node.Block);
        node.* = Node.Block{ .lbrace = arg1, .statements = arg2, .rbrace = arg3, };
        result = &node.base;
    }

    fn BlockExpr(MaybeBlockLabel: ?*Node, Block: *Node) *Node {
        arg2.label = arg1;
        result = arg2;
    }

    // Statements
    fn Statements(Statement: *Node) *Node.Statements {
        const statements = (try allocator.create(Node.Statements)).init(allocator);
        try statements.append(arg1);
        result = statements;
    }
    fn Statements(Statements: *Node.Statements, Statement: *Node) *Node.Statements {
        try arg1.append(arg2);
        result = arg1;
    }

    // Statement
    fn Statement(Block: *Node) *Node {
        result = arg1;
    }
    fn Statement(Keyword_unreachable: *Token, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Unreachable);
        node.* = Node.Unreachable{ .token = arg1 };
        result = &node.base;
    }
    fn Statement(Keyword_suspend: *Token, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Suspend);
        node.* = Node.Suspend{ .token = arg1 };
        result = &node.base;
    }
    fn Statement(Keyword_suspend: *Token, Block: *Node) *Node {
        const node = try allocator.create(Node.Suspend);
        node.* = Node.Suspend{ .token = arg1, .block = arg2 };
        result = &node.base;
    }
    fn Statement(Keyword_resume: *Token, Expr: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Resume);
        node.* = Node.Resume{ .token = arg1, .value = arg2 };
        result = &node.base;
    }
    fn Statement(Keyword_cancel: *Token, Expr: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Cancel);
        node.* = Node.Cancel{ .token = arg1, .value = arg2 };
        result = &node.base;
    }
    fn Statement(Keyword_break: *Token, MaybeBreakLabel: ?*Node, MaybeExpr: ?*Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Break);
        node.* = Node.Break{ .token = arg1, .label = arg2, .value = arg3 };
        result = &node.base;
    }
    fn Statement(Keyword_continue: *Token, MaybeBreakLabel: ?*Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Break);
        node.* = Node.Continue{ .token = arg1, .label = arg2 };
        result = &node.base;
    }
    fn Statement(Keyword_usingnamespace: *Token, Expr: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Usingnamespace);
        node.* = Node.Usingnamespace{ .token = arg1, .value = arg2 };
        result = &node.base;
    }
    fn Statement(Keyword_defer: *Token, BlockExpr: *Node) *Node {
        const node = try allocator.create(Node.Defer);
        node.* = Node.Defer{ .token = arg1, .statement = arg2, .is_errdefer = false, };
        result = &node.base;
    }
    fn Statement(Keyword_errdefer: *Token, BlockExpr: *Node) *Node {
        const node = try allocator.create(Node.Defer);
        node.* = Node.Defer{ .token = arg1, .statement = arg2, .is_errdefer = true, };
        result = &node.base;
    }
    fn Statement(Keyword_comptime: *Token, BlockExpr: *Node) *Node {
        const node = try allocator.create(Node.Comptime);
        node.* = Node.Comptime{ .token = arg1, .statement = arg2, };
        result = &node.base;
    }
    fn Statement(AssignStatement: *Node) *Node { result = arg1; }
    fn Statement(OpChain: *Node, Semicolon: *Token) *Node { result = arg1; }
    fn Statement(Keyword_try: *Token, OpChain: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Try);
        node.* = Node.Try{ .token = arg1, .rhs = arg2, };
        result = &node.base;
    }
    fn Statement(Keyword_await: *Token, OpChain: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Await);
        node.* = Node.Await{ .token = arg1, .rhs = arg2, };
        result = &node.base;
    }

    // Assignment
    fn AssignStatement(OpChain: *Node.Chain, AssignOp: *Token, Expr: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Assignment);
        node.* = Node.Assignment{ .lhs = &arg1.base, .token = arg2, .rhs = arg3, };
        result = &node.base;
    }

    // OpChain
    fn OpChain(Identifier: *Token) *Node.Chain {
        const node = try allocator.create(Node.Identifier);
        node.* = Node.Identifier{ .token = arg1, };

        const chain = try allocator.create(Node.Chain);
        chain.* = Node.Chain{ .parts = Node.NodeList.init(allocator), };
        try chain.parts.append(node);
        
        result = chain;
    }
    fn OpChain(BuiltinCall: *Node) *Node.Chain {
        const chain = try allocator.create(Node.Chain);
        chain.* = Node.Chain{ .parts = Node.NodeList.init(allocator), };
        try chain.parts.append(arg1);
        
        result = chain;
    }
    fn OpChain(LParen: *Token, OpChain: *Node.Chain, RParen: *Token) *Node.Chain {
        if(arg2.parts.len > 1) {
            const chain = try allocator.create(Node.Chain);
            chain.* = Node.Chain{ .parts = Node.NodeList.init(allocator), };
            try chain.parts.append(&arg2.base);
            result = chain;
        }
        else {
            return arg2;
        }
    }
    fn OpChain(OpChain: *Node.Chain, LBracket: *Token, Expr: *Node, RBracket: *Token) *Node.Chain {
        const node = try allocator.create(Node.Slice);
        node.* = Node.Slice{ .lbracket = arg2, .begin = arg3, .rbracket = arg4, };
        try arg1.parts.append(&node.base);
        result = arg1;
    }
    fn OpChain(OpChain: *Node.Chain, LBracket: *Token, Expr: *Node, Ellipsis2: *Token, RBracket: *Token) *Node.Chain {
        const node = try allocator.create(Node.Slice);
        node.* = Node.Slice{ .lbracket = arg2, .begin = arg3, .ellipsis = arg4, .rbracket = arg5, };
        try arg1.parts.append(&node.base);
        result = arg1;
    }
    fn OpChain(OpChain: *Node.Chain, LBracket: *Token, Expr: *Node, Ellipsis2: *Token, Expr: *Node, RBracket: *Token) *Node.Chain {
        const node = try allocator.create(Node.Slice);
        node.* = Node.Slice{ .lbracket = arg2, .begin = arg3, .ellipsis = arg4, .end = arg5, .rbracket = arg6, };
        try arg1.parts.append(&node.base);
        result = arg1;
    }
    fn OpChain(OpChain: *Node.Chain, FnCallArgs: *Node) *Node.Chain {
        try arg1.parts.append(arg2);
        result = arg1;
    }
    fn OpChain(OpChain: *Node.Chain, Period: *Token, Identifier: *Token) *Node.Chain {
        const node = try allocator.create(Node.Identifier);
        node.* = Node.Identifier{ .token = arg2, };
        try arg1.parts.append(&node.base);
        result = arg1;
    }
    fn OpChain(OpChain: *Node.Chain, Period: *Token, QuestionMark: *Token) *Node.Chain {
        const node = try allocator.create(Node.Unwrap);
        node.* = Node.Unwrap{ .token = arg3, };
        try arg1.parts.append(&node.base);
        result = arg1;
    }
    fn OpChain(OpChain: *Node.Chain, Period: *Token, Asterisk: *Token) *Node.Chain {
        const node = try allocator.create(Node.Deref);
        node.* = Node.Deref{ .token = arg3, };
        try arg1.parts.append(&node.base);
        result = arg1;
    }

    // Builtin calls
    fn BuiltinCall(Builtin: *Token, Identifier: *Token, FnCallArgs: *Node) *Node {
        const node = try allocator.create(Node.BuiltinCall);
        node.* = Node.BuiltinCall{ .token = arg1, .identifier = arg2, .arguments = arg3, };
        result = &node.base;
    }

    // Call arguments
    fn FnCallArgs(LParen: *Token, RParen: *Token) *Node {
        const node = try allocator.create(Node.Call);
        node.* = Node.BuiltinCall{ .lparen = arg1, .rparen = arg2 };
        result = &node.base;
    }
    fn FnCallArgs(LParen: *Token, Arguments: *NodeList, RParen: *Token) *Node {
        const node = try allocator.create(Node.Call);
        node.* = Node.BuiltinCall{ .lparen = arg1, .arguments = arg2, .rparen = arg3 };
        result = &node.base;
    }

    fn Arguments(Expr: *Node) *NodeList {
        const node = (try allocator.create(Node.Arguments)).init(allocator);
        try node.append(arg1);
        result = node;
    }
    fn Arguments(TypeExpr: *Node) *NodeList {
        const node = (try allocator.create(Node.Arguments)).init(allocator);
        try node.append(arg1);
        result = node;
    }
    fn Arguments(Arguments: *NodeList, Comma: *Token, Expr: *Node) *NodeList {
        try arg1.append(arg3);
        result = arg1;
    }
    fn Arguments(Arguments: *NodeList, Comma: *Token, TypeExpr: *Node) *NodeList {
        try arg1.append(arg3);
        result = arg1;
    }

    // Labels
    fn MaybeBlockLabel() ?*Node {
        result = null;
    }
    fn MaybeBlockLabel(Identifier: *Token, Colon: *Token) ?*Node {
        const node = try allocator.create(Node.BlockLabel);
        node.* = Node.BlockLabel{ .identifier = arg1, .colon = arg2, };
        result = &node.base;
    }

    fn MaybeBreakLabel() ?*Node {
        result = null;
    }
    fn MaybeBreakLabel(Colon: *Token, Identifier: *Token) ?*Node {
        const node = try allocator.create(Node.BreakLabel);
        node.* = Node.BreakLabel{ .colon = arg1, .identifier = arg2, };
        result = &node.base;
    }

    // Expressions
    fn MaybeExpr() ?*Node {
        result = null;
    }
    fn MaybeExpr(Expr: *Node) ?*Node {
        result = arg1;
    }

    fn Expr(BlockExpr: *Node) *Node { result = arg1; }
    fn Expr(Literal: *Node) *Node { result = arg1; }
    fn Expr(OpChain: *Node.Chain) *Node { result = &arg1.base; }
    fn Expr(LParen: *Token, Expr: *Node, RParen: *Token) *Node { result = arg2; }
    fn Expr(Keyword_unreachable: *Token) *Node {
        const node = try allocator.create(Node.Unreachable);
        node.* = Node.Unreachable{ .token = arg1 };
        result = &node.base;
    }

    // Type expressions
    fn TypeExpr(QuestionMark: *Token, TypeExpr: *Node) *Node {}
    fn TypeExpr(Keyword_promise: *Token, MinusAngleBracketRight: *Token, TypeExpr: *Node) *Node {}
    fn TypeExpr(Asterisk: *Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token, TypeExpr: *Node) *Node {}
    fn TypeExpr(AsteriskAsterisk: *Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token, TypeExpr: *Node) *Node {}
    fn TypeExpr(BracketStarBracket: *Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token, TypeExpr: *Node) *Node {}
    fn TypeExpr(BracketStarCBracket: *Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token, TypeExpr: *Node) *Node {}

    fn MaybeAlign() ?*Node { result = null; }
    fn MaybeAlign(Keyword_align: *Token, LParen: *Token, AlignExpr: *Node.Align, RParen: *Token) *Node {
        // AlignExpr is little weird due to a parsing conflict on `:` between BlockExpr and Align
        arg3.token = arg1;
        arg3.lparen = arg2;
        arg3.rparen = arg4;
        result = &arg3.base;
    }

    fn AlignExpr(Expr: *Node) *Node.Align {
        const node = try allocator.create(Node.Align);
        const fake = @ptrCast(*Token, arg1);
        node.* = Node.Align{ .token = fake, .lparen = fake, .value = arg1, .rparen = fake };
        result = node;
    }
    fn AlignExpr(LParen: *Token, Expr: *Node, RParen: *Token, Colon: *Token, IntegerLiteral: *Token, Colon: *Token, IntegerLiteral: *Token) *Node {
        const sub1 = try allocator.create(Node.IntegerLiteral);
        sub1.* = Node.IntegerLiteral{ .token = arg5 };
        const sub2 = try allocator.create(Node.IntegerLiteral);
        sub1.* = Node.IntegerLiteral{ .token = arg7 };
        const node = try allocator.create(Node.Align);
        const fake = arg1;
        node.* = Node.Align{ .token = fake, .lparen = fake, .value = arg2, .bit_start = sub1, .bit_end = sub2, .rparen = fake };
        result = node;
    }
    fn AlignExpr(Identifier: *Token, Colon: *Token, IntegerLiteral: *Token, Colon: *Token, IntegerLiteral: *Token) *Node {
        const value = try allocator.create(Node.Identifier);
        value.* = Node.Identifier{ .token = arg1 };
        const sub1 = try allocator.create(Node.IntegerLiteral);
        sub1.* = Node.IntegerLiteral{ .token = arg3 };
        const sub2 = try allocator.create(Node.IntegerLiteral);
        sub1.* = Node.IntegerLiteral{ .token = arg5 };
        const node = try allocator.create(Node.Align);
        const fake = arg1;
        node.* = Node.Align{ .token = fake, .lparen = fake, .value = value, .bit_start = sub1, .bit_end = sub2, .rparen = fake };
        result = node;
    }
    fn AlignExpr(IntegerLiteral: *Token, Colon: *Token, IntegerLiteral: *Token, Colon: *Token, IntegerLiteral: *Token) *Node {
        const value = try allocator.create(Node.IntegerLiteral);
        value.* = Node.IntegerLiteral{ .token = arg1 };
        const sub1 = try allocator.create(Node.IntegerLiteral);
        sub1.* = Node.IntegerLiteral{ .token = arg3 };
        const sub2 = try allocator.create(Node.IntegerLiteral);
        sub1.* = Node.IntegerLiteral{ .token = arg5 };
        const node = try allocator.create(Node.Align);
        const fake = arg1;
        node.* = Node.Align{ .token = fake, .lparen = fake, .value = value, .bit_start = sub1, .bit_end = sub2, .rparen = fake };
        result = node;
    }

    fn MaybeConst() ?*Token { result = null; }
    fn MaybeConst(Keyword_const: *Token) ?*Token { result = arg1; }

    fn MaybeVolatile() ?*Token { result = null; }
    fn MaybeVolatile(Keyword_volatile: *Token) ?*Token { result = arg1; }

    fn MaybeAllowzero() ?*Token { result = null; }
    fn MaybeAllowzero(Keyword_allowzero: *Token) ?*Token { result = arg1; }

    // Literals
    fn Literal(IntegerLiteral: *Token) *Node {
        const node = try allocator.create(Node.IntegerLiteral);
        node.* = Node.IntegerLiteral{ .token = arg1 };
        result = &node.base;
    }

    fn Literal(FloatLiteral: *Token) *Node {
        const node = try allocator.create(Node.FloatLiteral);
        node.* = Node.FloatLiteral{ .token = arg1 };
        result = &node.base;
    }

    fn Literal(EnumLiteral: *Token) *Node {
        const node = try allocator.create(Node.EnumLiteral);
        node.* = Node.EnumLiteral{ .token = arg1 };
        result = &node.base;
    }

    fn Literal(StringLiteral: *Token) *Node {
        const node = try allocator.create(Node.StringLiteral);
        node.* = Node.StringLiteral{ .token = arg1 };
        result = &node.base;
    }

    fn Literal(MultilineStringLiterals: *Node) *Node {
        result = arg1;
    }

    fn Literal(CharLiteral: *Token) *Node {
        const node = try allocator.create(Node.CharLiteral);
        node.* = Node.CharLiteral{ .token = arg1 };
        result = &node.base;
    }

    fn Literal(Keyword_true: *Token) *Node {
        const node = try allocator.create(Node.BoolLiteral);
        node.* = Node.BoolLiteral{ .token = arg1, .is_true = true };
        result = &node.base;
    }

    fn Literal(Keyword_false: *Token) *Node {
        const node = try allocator.create(Node.BoolLiteral);
        node.* = Node.BoolLiteral{ .token = arg1, .is_true = false };
        result = &node.base;
    }

    fn Literal(Keyword_null: *Token) *Node {
        const node = try allocator.create(Node.NullLiteral);
        node.* = Node.NullLiteral{ .token = arg1 };
        result = &node.base;
    }

    fn Literal(Keyword_undefined: *Token) *Node {
        const node = try allocator.create(Node.UndefinedLiteral);
        node.* = Node.UndefinedLiteral{ .token = arg1 };
        result = &node.base;
    }

    fn MultilineStringLiterals(MultilineStringLiteral: *Token) *Node {
        const node = try allocator.create(Node.MultilineStringLiteral);
        node.* = Node.MultilineStringLiteral{ .tokens = Node.TokenList.init(allocator) };
        try node.tokens.append(arg1);
        result = &node.base;
    }
    fn MultilineStringLiterals(MultilineStringLiteral: *Node, MultilineStringLiteral: *Token) *Node {
        try arg1.tokens.append(arg2);
        result = &arg1.base;
    }

    // Operators
    fn AssignOp(AsteriskEqual: *Token) *Token { result = arg1; }
    fn AssignOp(SlashEqual: *Token) *Token { result = arg1; }
    fn AssignOp(PercentEqual: *Token) *Token { result = arg1; }
    fn AssignOp(MinusEqual: *Token) *Token { result = arg1; }
    fn AssignOp(AngleBracketAngleBracketLeftEqual: *Token) *Token { result = arg1; }
    fn AssignOp(AngleBracketAngleBracketRightEqual: *Token) *Token { result = arg1; }
    fn AssignOp(AmpersandEqual: *Token) *Token { result = arg1; }
    fn AssignOp(CaretEqual: *Token) *Token { result = arg1; }
    fn AssignOp(PipeEqual: *Token) *Token { result = arg1; }
    fn AssignOp(AsteriskPercentEqual: *Token) *Token { result = arg1; }
    fn AssignOp(PlusPercentEqual: *Token) *Token { result = arg1; }
    fn AssignOp(MinusPercentEqual: *Token) *Token { result = arg1; }
    fn AssignOp(Equal: *Token) *Token { result = arg1; }

    fn CompareOp(EqualEqual: *Token) *Token { result = arg1; }
    fn CompareOp(BangEqual: *Token) *Token { result = arg1; }
    fn CompareOp(AngleBracketLeft: *Token) *Token { result = arg1; }
    fn CompareOp(AngleBracketRight: *Token) *Token { result = arg1; }
    fn CompareOp(AngleBracketLeftEqual: *Token) *Token { result = arg1; }
    fn CompareOp(AngleBracketRightEqual: *Token) *Token { result = arg1; }

    fn BitwiseOp(Ampersand: *Token) *Token { result = arg1; }
    fn BitwiseOp(Caret: *Token) *Token { result = arg1; }
    fn BitwiseOp(Keyword_orelse: *Token) *Token { result = arg1; }
    fn BitwiseOp(Keyword_catch: *Token) *Token { result = arg1; }

    fn BitShiftOp(AngleBracketAngleBracketLeft: *Token) *Token { result = arg1; }
    fn BitShiftOp(AngleBracketAngleBracketRight: *Token) *Token { result = arg1; }

    fn AdditionOp(Plus: *Token) *Token { result = arg1; }
    fn AdditionOp(Minus: *Token) *Token { result = arg1; }
    fn AdditionOp(PlusPlus: *Token) *Token { result = arg1; }
    fn AdditionOp(PlusPercent: *Token) *Token { result = arg1; }
    fn AdditionOp(MinusPercent: *Token) *Token { result = arg1; }

    fn MultiplyOp(PipePipe: *Token) *Token { result = arg1; }
    fn MultiplyOp(Asterisk: *Token) *Token { result = arg1; }
    fn MultiplyOp(Slash: *Token) *Token { result = arg1; }
    fn MultiplyOp(Percent: *Token) *Token { result = arg1; }
    fn MultiplyOp(AsteriskAsterisk: *Token) *Token { result = arg1; }
    fn MultiplyOp(AsteriskPercent: *Token) *Token { result = arg1; }
};
