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
    fn Statement(BuiltinCall: *Node, Semicolon: *Token) *Node { result = arg1; }
    fn Statement(CallChain: *Node, Semicolon: *Token) *Node { result = arg1; }
    fn Statement(Keyword_try: *Token, CallChain: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Try);
        node.* = Node.Try{ .token = arg1, .rhs = arg2, };
        result = &node.base;
    }
    fn Statement(Keyword_await: *Token, CallChain: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Await);
        node.* = Node.Await{ .token = arg1, .rhs = arg2, };
        result = &node.base;
    }

    // Assignment
    fn AssignStatement(LValue: *Node, AssignOp: *Token, Expr: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Assignment);
        node.* = Node.Assignment{ .lhs = arg1, .token = arg2, .rhs = arg3, };
        result = &node.base;
    }
    fn AssignStatement(BuiltinCall: *Node, AssignOp: *Token, Expr: *Node, Semicolon: *Token) *Node {
        const node = try allocator.create(Node.Assignment);
        node.* = Node.Assignment{ .lhs = arg1, .token = arg2, .rhs = arg3, };
        result = &node.base;
    }

    // LValue (something allowed on left side of assignment)
    fn LValue(Identifier: *Token) *Node {
        const node = try allocator.create(Node.Identifier);
        node.* = Node.Identifier{ .token = arg1, };
        result = &node.base;
    }
    fn LValue(LParen: *Token, LValue: *Node, RParen: *Token) *Node { result = arg2; }
    fn LValue(LValue: *Node, LBracket: *Token, Expr: *Node, RBracket: *Token) *Node {
        const node = try allocator.create(Node.Slice);
        node.* = Node.Slice{ .lhs = arg1, .lbracket = arg2, .begin = arg3, .rbracket = arg4, };
        result = &node.base;
    }
    fn LValue(LValue: *Node, LBracket: *Token, Expr: *Node, Ellipsis2: *Token, RBracket: *Token) *Node {
        const node = try allocator.create(Node.Slice);
        node.* = Node.Slice{ .lhs = arg1, .lbracket = arg2, .begin = arg3, .ellipsis = arg4, .rbracket = arg5, };
        result = &node.base;
    }
    fn LValue(LValue: *Node, LBracket: *Token, Expr: *Node, Ellipsis2: *Token, Expr: *Node, RBracket: *Token) *Node {
        const node = try allocator.create(Node.Slice);
        node.* = Node.Slice{ .lhs = arg1, .lbracket = arg2, .begin = arg3, .ellipsis = arg4, .end = arg5, .rbracket = arg6, };
        result = &node.base;
    }
    fn LValue(LValue: *Node, Period: *Token, Identifier: *Token) *Node {
        const node = try allocator.create(Node.Identifier);
        node.* = Node.Identifier{ .token = arg2, };
        if(arg1.cast(Node.Chain)) |chain| {
            try chain.append(node);
            result = arg1;
        }
        else {
            const chain = try allocator.create(Node.Chain);
            chain.* = Node.Chain{ .parts = Node.NodeList.init(allocator), };
            try chain.identifiers.append(arg1);
            try chain.identifiers.append(node);
            result = chain;
        }
    }
    fn LValue(LValue: *Node, Period: *Token, QuestionMark: *Token) *Node {
        const node = try allocator.create(Node.Unwrap);
        node.* = Node.Unwrap{ .value = arg1, .token = arg3, };
        result = &node.base;
    }
    fn LValue(LValue: *Node, Period: *Token, Asterisk: *Token) *Node {
        const node = try allocator.create(Node.Deref);
        node.* = Node.Deref{ .value = arg1, .token = arg3, };
        result = &node.base;
    }

    // Builtin calls
    fn BuiltinCall(Builtin: *Token, Identifier: *Token, FnCallArgs: *Node) *Node {
        const node = try allocator.create(Node.BuiltinCall);
        node.* = Node.BuiltinCall{ .token = arg1, .identifier = arg2, .arguments = arg3, };
        result = &node.base;
    }

    // Call chain
    fn CallChain(LValue: *Node, FnCallArgs: *Node) *Node {
        const node = try allocator.create(Node.Call);
        node.* = Node.Call{ .name = arg1, .arguments = arg2 };
        result = &node.base;
    }
    fn CallChain(LParen: *Token, CallChain: *Node, RParen: *Node) *Node { return arg2; }
    fn CallChain(LParen: *Token, Keyword_try: *Token, CallChain: *Node, RParen: *Node) *Node {
        const node = try allocator.create(Node.Try);
        node.* = Node.Try{ .token = arg2, .rhs = arg3, };
        result = &node.base;
    }
    fn CallChain(CallChain: *Node, LValue: *Node, FnCallArgs: *Node) *Node {
        const node = try allocator.create(Node.Call);
        node.* = Node.Call{ .name = arg2, .arguments = arg3 };
        if(arg1.cast(Node.Chain)) |chain| {
            try chain.append(node);
            result = arg1;
        }
        else {
            const chain = try allocator.create(Node.Chain);
            chain.* = Node.Chain{ .parts = Node.NodeList.init(allocator), };
            try chain.identifiers.append(arg1);
            try chain.identifiers.append(node);
            result = chain;
        }
    }

    // Call arguments
    fn FnCallArgs(LParen: *Token, RParen: *Token) *Node {}

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
};
