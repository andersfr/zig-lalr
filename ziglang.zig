pub extern "LALR" const zig_grammar = struct {
    const Precedence = struct {
        right: enum {
            Precedence_enumlit,
        },
        left: enum {
            // AssignOp
            Equal,
            AsteriskEqual,
            SlashEqual,
            PercentEqual,
            PlusEqual,
            MinusEqual,
            AngleBracketAngleBracketLeftEqual,
            AngleBracketAngleBracketRightEqual,
            AmpersandEqual,
            CaretEqual,
            PipeEqual,
            AsteriskPercentEqual,
            PlusPercentEqual,
            MinusPercentEqual,
        },
        right: enum {
            Keyword_break,
            Keyword_return,
            Keyword_continue,
            Keyword_resume,
            Keyword_cancel,
            Keyword_comptime,
            Keyword_promise,
        },
        left: enum {
            Keyword_or,
        },
        left: enum {
            Keyword_and,
        },
        left: enum {
            // CompareOp
            EqualEqual,
            BangEqual,
            AngleBracketLeft,
            AngleBracketRight,
            AngleBracketLeftEqual,
            AngleBracketRightEqual,
        },
        left: enum {
            Keyword_orelse,
            Keyword_catch,
        },
        left: enum {
            // Bitwise OR
            Pipe,
        },
        left: enum {
            // Bitwise XOR
            Caret,
        },
        left: enum {
            // Bitwise AND
            Ampersand,
        },
        left: enum {
            AngleBracketAngleBracketLeft,
            AngleBracketAngleBracketRight,
        },
        left: enum {
            Plus,
            Minus,
            PlusPlus,
            PlusPercent,
            MinusPercent,
        },
        left: enum {
            Asterisk,
            Slash,
            Percent,
            AsteriskAsterisk,
            AsteriskPercent,
            PipePipe,
        },
        right: enum {
            Keyword_try,
            Keyword_await,

            Precedence_not,
            Precedence_neg,
            Tilde,
            Precedence_ref,
            QuestionMark,
        },
        right: enum {
            // x{} initializer
            LBrace,
            // x.* x.?
            PeriodAsterisk,
            PeriodQuestionMark,
        },
        left: enum {
            // a!b
            Bang,
        },
        right: enum {
            LParen,
            LBracket,
            Period,
        },
    };

    fn Root(MaybeRootDocComment: ?*Node.DocComment, MaybeContainerMembers: ?*NodeList) *Node {
        const node = try parser.createNode(Node.Root);
        node.doc_comments = arg1;
        node.decls = if (arg2) |p| p.* else NodeList.init(parser.allocator);
        result = &node.base;
    }

    // DocComments
    fn MaybeDocComment() ?*Node.DocComment;
    fn MaybeDocComment(DocCommentLines: *TokenList) ?*Node.DocComment {
        const node = try parser.createNode(Node.DocComment);
        node.lines = arg1.*;
        result = node;
    }
    fn DocCommentLines(DocCommentLines: *TokenList, DocComment: *Token) *TokenList {
        result = arg1;
        try arg1.append(arg2);
    }
    fn DocCommentLines(DocComment: *Token) *TokenList {
        result = try parser.createListWithToken(TokenList, arg1);
    }
    fn MaybeRootDocComment() ?*Node.DocComment;
    fn MaybeRootDocComment(RootDocCommentLines: *TokenList) ?*Node.DocComment {
        const node = try parser.createNode(Node.DocComment);
        node.lines = arg1.*;
        result = node;
    }
    fn RootDocCommentLines(RootDocCommentLines: *TokenList, RootDocComment: *Token) *TokenList {
        result = arg1;
        try arg1.append(arg2);
    }
    fn RootDocCommentLines(RootDocComment: *Token) *TokenList {
        result = try parser.createListWithToken(TokenList, arg1);
    }

    // Containers
    fn MaybeContainerMembers() ?*NodeList;
    fn MaybeContainerMembers(ContainerMembers: *NodeList) ?*NodeList;

    // Note: these exist to allow a trailing container field without comma
    fn MaybeContainerMembers(ContainerField: *Node) ?*NodeList {
        result = try parser.createListWithNode(NodeList, arg1);
    }
    fn MaybeContainerMembers(ContainerMembers: *NodeList, ContainerField: *Node) *NodeList {
        result = arg1;
        try arg1.append(arg2);
    }

    fn ContainerMembers(ContainerMembers: *NodeList, ContainerMember: *Node) *NodeList {
        result = arg1;
        try arg1.append(arg2);
    }
    fn ContainerMembers(ContainerMember: *Node) *NodeList {
        result = try parser.createListWithNode(NodeList, arg1);
    }

    fn ContainerMember(MaybeDocComment: ?*Node.DocComment, TestDecl: *Node.TestDecl) *Node {
        result = &arg2.base;
        arg2.doc_comments = arg1;
    }
    fn ContainerMember(MaybeDocComment: ?*Node.DocComment, TopLevelComptime: *Node.Comptime) *Node {
        result = &arg2.base;
        arg2.doc_comments = arg1;
    }
    fn ContainerMember(MaybeDocComment: ?*Node.DocComment, MaybePub: ?*Token, TopLevelDecl: *Node) *Node {
        result = arg3;
        if (arg3.cast(Node.VarDecl)) |node| {
            node.doc_comments = arg1;
            node.visib_token = arg2;
        } else {
            const node = arg3.unsafe_cast(Node.FnProto);
            node.doc_comments = arg1;
            node.visib_token = arg2;
        }
    }
    fn ContainerMember(MaybeDocComment: ?*Node.DocComment, MaybePub: ?*Token, ContainerField: *Node, Comma: *Token) *Node {
        result = arg3;
        const node = arg3.unsafe_cast(Node.ContainerField);
        node.doc_comments = arg1;
        node.visib_token = arg2;
    }

    // Test
    fn TestDecl(Keyword_test: *Token, StringLiteral: *Token, Block: *Node) *Node.TestDecl {
        const name = try parser.createNode(Node.StringLiteral);
        name.token = arg2;
        const node = try parser.createNode(Node.TestDecl);
        node.test_token = arg1;
        node.name = &name.base;
        node.body_node = arg3;
        result = node;
    }

    // Comptime
    fn TopLevelComptime(Keyword_comptime: *Token, BlockExpr: *Node) *Node.Comptime {
        const node = try parser.createNode(Node.Comptime);
        node.comptime_token = arg1;
        node.expr = arg2;
        result = node;
    }

    // TopLevel declarations
    fn TopLevelDecl(FnProto: *Node.FnProto, Semicolon: *Token) *Node { result = &arg1.base; }
    fn TopLevelDecl(FnProto: *Node.FnProto, Block: *Node) *Node { arg1.body_node = arg2; result = &arg1.base; }
    fn TopLevelDecl(Keyword_extern: *Token, StringLiteral: *Token, FnProto: *Node.FnProto, Semicolon: *Token) *Node {
        result = &arg3.base;
        const lib_name = try parser.createNode(Node.StringLiteral);
        lib_name.token = arg2;
        arg3.extern_export_inline_token = arg1;
        arg3.lib_name = &lib_name.base;
    }
    fn TopLevelDecl(Keyword_extern: *Token, StringLiteral: *Token, FnProto: *Node.FnProto, Block: *Node) *Node {
        result = &arg3.base;
        const lib_name = try parser.createNode(Node.StringLiteral);
        lib_name.token = arg2;
        arg3.extern_export_inline_token = arg1;
        arg3.lib_name = &lib_name.base;
        arg3.body_node = arg4;
    }
    fn TopLevelDecl(Keyword_export: *Token, FnProto: *Node.FnProto, Semicolon: *Token) *Node {
        result = &arg2.base;
        arg2.extern_export_inline_token = arg1;
    }
    fn TopLevelDecl(Keyword_inline: *Token, FnProto: *Node.FnProto, Semicolon: *Token) *Node {
        result = &arg2.base;
        arg2.extern_export_inline_token = arg1;
    }
    fn TopLevelDecl(Keyword_export: *Token, FnProto: *Node.FnProto, Block: *Node) *Node {
        result = &arg2.base;
        arg2.extern_export_inline_token = arg1;
        arg2.body_node = arg3;
    }
    fn TopLevelDecl(Keyword_inline: *Token, FnProto: *Node.FnProto, Block: *Node) *Node {
        result = &arg2.base;
        arg2.extern_export_inline_token = arg1;
        arg2.body_node = arg3;
    }
    fn TopLevelDecl(MaybeThreadlocal: ?*Token, VarDecl: *Node) *Node {
        result = arg2;
        const node = arg2.unsafe_cast(Node.VarDecl);
        node.thread_local_token = arg1;
    }
    fn TopLevelDecl(Keyword_extern: *Token, StringLiteral: *Token, MaybeThreadlocal: ?*Token, VarDecl: *Node) *Node {
        result = arg4;
        const lib_name = try parser.createNode(Node.StringLiteral);
        lib_name.token = arg2;
        const node = arg4.unsafe_cast(Node.VarDecl);
        node.extern_export_token = arg1;
        node.lib_name = &lib_name.base;
        node.thread_local_token = arg3;
    }
    fn TopLevelDecl(Keyword_export: *Token, MaybeThreadlocal: ?*Token, VarDecl: *Node) *Node {
        result = arg3;
        const node = arg3.unsafe_cast(Node.VarDecl);
        node.extern_export_token = arg1;
        node.thread_local_token = arg2;
    }
    fn TopLevelDecl(Keyword_extern: *Token, MaybeThreadlocal: ?*Token, VarDecl: *Node) *Node {
        result = arg3;
        const node = arg3.unsafe_cast(Node.VarDecl);
        node.extern_export_token = arg1;
        node.thread_local_token = arg2;
    }
    fn TopLevelDecl(Keyword_usingnamespace: *Token, Expr: *Node, Semicolon: *Token) *Node {
        const node = try parser.createNode(Node.Use);
        node.use_token = arg1;
        node.expr = arg2;
        node.semicolon_token = arg3;
        result = &node.base;
    }
    fn TopLevelDecl(Keyword_use: *Token, Expr: *Node, Semicolon: *Token) *Node {
        const node = try parser.createNode(Node.Use);
        node.use_token = arg1;
        node.expr = arg2;
        node.semicolon_token = arg3;
        result = &node.base;
    }

    fn MaybeThreadlocal() ?*Token;
    fn MaybeThreadlocal(Keyword_threadlocal: *Token) ?*Token;

    // Functions
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, LParen: Precedence_none(*Token), MaybeParamDeclList: ?*NodeList, RParen: *Token, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, FnProtoType: *Node) *Node.FnProto {
        const node = try parser.createNode(Node.FnProto);
        node.cc_token = arg1;
        node.fn_token = arg2;
        node.name_token = arg3;
        node.params = if(arg5) |p| p.* else NodeList.init(parser.allocator);
        node.align_expr = arg7;
        node.section_expr = arg8;
        node.return_type = Node.FnProto.ReturnType{ .Explicit = arg9 };
        result = node;
    }
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, LParen: Precedence_none(*Token), MaybeParamDeclList: ?*NodeList, RParen: *Token, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, Bang: Precedence_none(*Token), FnProtoType: *Node) *Node.FnProto {
        const node = try parser.createNode(Node.FnProto);
        node.cc_token = arg1;
        node.fn_token = arg2;
        node.name_token = arg3;
        node.params = if(arg5) |p| p.* else NodeList.init(parser.allocator);
        node.align_expr = arg7;
        node.section_expr = arg8;
        node.return_type = Node.FnProto.ReturnType{ .InferErrorSet = arg10 };
        result = node;
    }

    // Variables
    fn VarDecl(Keyword_const: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {
        const node = try parser.createNode(Node.VarDecl);
        node.mut_token = arg1;
        node.name_token = arg2;
        node.type_node = arg3;
        node.align_node = arg4;
        node.section_node = arg5;
        node.init_node = arg6;
        node.semicolon_token = arg7;
        result = &node.base;
    }
    fn VarDecl(Keyword_var: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {
        const node = try parser.createNode(Node.VarDecl);
        node.mut_token = arg1;
        node.name_token = arg2;
        node.type_node = arg3;
        node.align_node = arg4;
        node.section_node = arg5;
        node.init_node = arg6;
        node.semicolon_token = arg7;
        result = &node.base;
    }

    // Container field
    fn ContainerField(Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeEqualExpr: ?*Node) *Node {
        const node = try parser.createNode(Node.ContainerField);
        node.name_token = arg1;
        node.type_expr = arg2;
        node.value_expr = arg3;
        result = &node.base;
    }

    // Statements
    fn MaybeStatements() ?*NodeList;
    fn MaybeStatements(Statements: *NodeList) ?*NodeList;

    fn Statements(Statement: *Node) *NodeList {
        result = try parser.createListWithNode(NodeList, arg1);
    }
    fn Statements(Statements: *NodeList, Statement: *Node) *NodeList {
        result = arg1;
        try arg1.append(arg2);
    }

    fn Statement(Keyword_comptime: *Token, VarDecl: *Node) *Node {
        const node = try parser.createNode(Node.Comptime);
        node.comptime_token = arg1;
        node.expr = arg2;
        result = &node.base;
    }
    fn Statement(VarDecl: *Node) *Node;
    fn Statement(Keyword_comptime: *Token, BlockExpr: *Node) *Node {
        const node = try parser.createNode(Node.Comptime);
        node.comptime_token = arg1;
        node.expr = arg2;
        result = &node.base;
    }
    fn Statement(Keyword_suspend: *Token, Semicolon: *Token) *Node {
        const node = try parser.createNode(Node.Suspend);
        node.suspend_token = arg1;
        result = &node.base;
    }
    fn Statement(Keyword_suspend: *Token, BlockExprStatement: *Node) *Node {
        const node = try parser.createNode(Node.Suspend);
        node.suspend_token = arg1;
        node.body = arg2;
        result = &node.base;
    }
    fn Statement(Keyword_defer: *Token, BlockExprStatement: *Node) *Node {
        const node = try parser.createNode(Node.Defer);
        node.defer_token = arg1;
        node.expr = arg2;
        result = &node.base;
    }
    fn Statement(Keyword_errdefer: *Token, BlockExprStatement: *Node) *Node {
        const node = try parser.createNode(Node.Defer);
        node.defer_token = arg1;
        node.expr = arg2;
        result = &node.base;
    }
    fn Statement(IfStatement: *Node) *Node;
    fn Statement(LabeledStatement: *Node) *Node;
    fn Statement(SwitchExpr: *Node) *Node;
    fn Statement(AssignExpr: *Node, Semicolon: *Token) *Node {
        result = arg1;
    }

    fn IfStatement(IfPrefix: *Node.If, BlockExpr: *Node) *Node {
        result = &arg1.base;
        arg1.body = arg2;
    }
    fn IfStatement(IfPrefix: *Node.If, BlockExpr: *Node, ElseStatement: *Node.Else) *Node {
        result = &arg1.base;
        arg1.body = arg2;
        arg1.@"else" = arg3;
    }
    fn IfStatement(IfPrefix: *Node.If, AssignExpr: *Node, Semicolon: *Token) *Node {
        result = &arg1.base;
        arg1.body = arg2;
    }
    fn IfStatement(IfPrefix: *Node.If, AssignExpr: *Node, ElseStatement: *Node.Else) *Node {
        result = &arg1.base;
        arg1.body = arg2;
        arg1.@"else" = arg3;
    }
    fn ElseStatement(Keyword_else: *Token, MaybePayload: ?*Node, Statement: *Node) *Node.Else {
        const node = try parser.createNode(Node.Else);
        node.else_token = arg1;
        node.payload = arg2;
        node.body = arg3;
        result = node;
    }

    fn LabeledStatement(LoopStatement: *Node) *Node;
    fn LabeledStatement(BlockLabel: *Token, LoopStatement: *Node) *Node {}
    fn LabeledStatement(BlockExpr: *Node) *Node;

    fn LoopStatement(MaybeInline: ?*Token, ForStatement: *Node) *Node {}
    fn LoopStatement(MaybeInline: ?*Token, WhileStatement: *Node) *Node {}

    fn ForStatement(ForPrefix: *Node, BlockExpr: *Node) *Node {}
    fn ForStatement(ForPrefix: *Node, BlockExpr: *Node, ElseNoPayloadStatement: *Node) *Node {}
    fn ForStatement(ForPrefix: *Node, AssignExpr: *Node, Semicolon: *Token) *Node {}
    fn ForStatement(ForPrefix: *Node, AssignExpr: *Node, ElseNoPayloadStatement: *Node) *Node {}
    fn ElseNoPayloadStatement(Keyword_else: *Token, Statement: *Node) *Node {}

    fn WhileStatement(WhilePrefix: *Node, BlockExpr: *Node) *Node {}
    fn WhileStatement(WhilePrefix: *Node, BlockExpr: *Node, ElseStatement: *Node) *Node {}
    fn WhileStatement(WhilePrefix: *Node, AssignExpr: *Node, Semicolon: *Token) *Node {}
    fn WhileStatement(WhilePrefix: *Node, AssignExpr: *Node, ElseStatement: *Node) *Node {}

    fn BlockExprStatement(BlockExpr: *Node) *Node;
    fn BlockExprStatement(AssignExpr: *Node, Semicolon: *Token) *Node {
        result = arg1;
    }

    // Expression level
    fn AssignExpr(Expr: *Node, AsteriskEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignTimes;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, SlashEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignDiv;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, PercentEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignMod;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, PlusEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignPlus;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, MinusEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignMinus;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, AngleBracketAngleBracketLeftEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignBitShiftLeft;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, AngleBracketAngleBracketRightEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignBitShiftRight;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, AmpersandEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignBitAnd;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, CaretEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignBitXor;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, PipeEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignBitOr;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, AsteriskPercentEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignTimesWrap;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, PlusPercentEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignPlusWrap;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, MinusPercentEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AssignMinusWrap;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node, Equal: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .Assign;
        node.rhs = arg3;
        result = &node.base;
    }
    fn AssignExpr(Expr: *Node) *Node;

    fn MaybeEqualExpr() ?*Node;
    fn MaybeEqualExpr(Equal: *Token, Expr: *Node) ?*Node {
        result = arg2;
    }

    // Grouped
    fn Expr(LParen: *Token, Expr: *Node, RParen: *Token) *Node {
        const node = try parser.createNode(Node.GroupedExpression);
        node.lparen = arg1;
        node.expr = arg2;
        node.rparen = arg3;
        result = &node.base;
    }

    // Infix
    fn Expr(Expr: *Node, Keyword_orelse: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .UnwrapOptional;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Keyword_catch: *Token, MaybePayload: ?*Node, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = Node.InfixOp.Op{ .Catch = arg3 };
        node.rhs = arg4;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Keyword_or: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .BoolOr;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Keyword_and: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .BoolAnd;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, EqualEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .EqualEqual;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, BangEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .BangEqual;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, AngleBracketLeft: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .LessThan;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, AngleBracketRight: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .GreaterThan;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, AngleBracketLeftEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .LessOrEqual;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, AngleBracketRightEqual: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .GreaterOrEqual;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Pipe: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .BitOr;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Caret: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .BitXor;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Ampersand: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .BitAnd;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, AngleBracketAngleBracketLeft: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .BitShiftLeft;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, AngleBracketAngleBracketRight: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .BitShiftRight;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Plus: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .Add;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Minus: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .Sub;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, PlusPlus: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .ArrayCat;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, PlusPercent: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .AddWrap;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, MinusPercent: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .SubWrap;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Asterisk: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .Div;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Slash: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .Div;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, Percent: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .Mod;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, AsteriskAsterisk: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .ArrayMult;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, AsteriskPercent: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .MultWrap;
        node.rhs = arg3;
        result = &node.base;
    }
    fn Expr(Expr: *Node, PipePipe: *Token, Expr: *Node) *Node {
        const node = try parser.createNode(Node.InfixOp);
        node.lhs = arg1;
        node.op_token = arg2;
        node.op = .ErrorUnion;
        node.rhs = arg3;
        result = &node.base;
    }

    // Prefix
    fn Expr(Bang: Precedence_not(*Token), Expr: *Node) *Node;
    fn Expr(Minus: Precedence_neg(*Token), Expr: *Node) *Node;
    fn Expr(MinusPercent: Precedence_neg(*Token), Expr: *Node) *Node;
    fn Expr(Tilde: *Token, Expr: *Node) *Node;
    fn Expr(Ampersand: Precedence_ref(*Token), Expr: *Node) *Node;
    fn Expr(Keyword_try: *Token, Expr: *Node) *Node;
    fn Expr(Keyword_await: *Token, Expr: *Node) *Node;
    fn Expr(Keyword_comptime: *Token, Expr: *Node) *Node {}

    // Primary
    fn Expr(AsmExpr: *Node) *Node;
    fn Expr(Keyword_resume: *Token, Expr: *Node) *Node {}
    fn Expr(Keyword_cancel: *Token, Expr: *Node) *Node {}
    fn Expr(Keyword_break: *Token) *Node {}
    fn Expr(Keyword_break: *Token, BreakLabel: *Token) *Node {}
    fn Expr(Keyword_break: *Token, Expr: *Node) *Node {}
    fn Expr(Keyword_break: *Token, BreakLabel: *Token, Expr: *Node) *Node {}
    fn Expr(Keyword_continue: *Token) *Node {}
    fn Expr(Keyword_continue: *Token, BreakLabel: *Token) *Node {}
    fn Expr(Keyword_return: *Token) *Node {}
    fn Expr(Keyword_return: *Token, Expr: *Node) *Node {}

    // Initializer list
    fn Expr(Identifier: *Token, LBrace: *Token, MaybeInitList: ?*NodeList, RBrace: *Token) *Node {}

    // Prefix
    fn Expr(QuestionMark: *Token, Expr: *Node) *Node;
    fn Expr(Keyword_promise: *Token, MinusAngleBracketRight: *Token, Expr: *Node) *Node {}
    // ArrayType
    fn Expr(LBracket: *Token, Expr: *Node, RBracket: *Token, Expr: *Node) *Node {}
    // SliceType
    fn Expr(LBracket: *Token, RBracket: *Token, MaybeAllowzero: ?*Token, MaybeByteAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, Expr: *Node) *Node {}
    // PtrType
    fn Expr(Asterisk: Precedence_none(*Token), MaybeAllowzero: ?*Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, Expr: *Node) *Node {}
    fn Expr(AsteriskAsterisk: Precedence_none(*Token), MaybeAllowzero: ?*Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, Expr: *Node) *Node {}
    fn Expr(BracketStarBracket: *Token, MaybeAllowzero: ?*Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, Expr: *Node) *Node {}
    fn Expr(BracketStarCBracket: *Token, MaybeAllowzero: ?*Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, Expr: *Node) *Node {}

    // Block
    fn Expr(BlockExpr: Shadow(*Node)) *Node;
    fn BlockExpr(Block: *Node) *Node;
    fn BlockExpr(BlockLabel: *Token, Block: *Node) *Node {}
    fn Block(LBrace: *Token, MaybeStatements: ?*Node, RBrace: *Token) *Node {}
    fn BlockLabel(Identifier: *Token, Colon: *Token) *Token {}

    // ErrorType
    fn Expr(Expr: *Node, Bang: *Token, Expr: *Node) *Node {}

    // Literals
    fn Expr(Identifier: *Token) *Node {
        const node = try parser.createNode(Node.Identifier);
        node.token = arg1;
        result = &node.base;
    }
    fn Expr(CharLiteral: *Token) *Node {
        const node = try parser.createNode(Node.CharLiteral);
        node.token = arg1;
        result = &node.base;
    }
    fn Expr(FloatLiteral: *Token) *Node {
        const node = try parser.createNode(Node.FloatLiteral);
        node.token = arg1;
        result = &node.base;
    }
    fn Expr(IntegerLiteral: *Token) *Node {
        const node = try parser.createNode(Node.IntegerLiteral);
        node.token = arg1;
        result = &node.base;
    }
    fn Expr(StringLiteral: *Token) *Node {
        const node = try parser.createNode(Node.StringLiteral);
        node.token = arg1;
        result = &node.base;
    }
    fn Expr(MultilineStringLiteral: *NodeList) *Node {}
    fn Expr(MultilineCStringLiteral: *NodeList) *Node {}
    fn Expr(Period: Precedence_enumlit(*Token), Identifier: *Token) *Node {
        const node = try parser.createNode(Node.EnumLiteral);
        node.dot = arg1;
        node.name = arg2;
        result = &node.base;
    }

    // Simple types
    fn Expr(Keyword_error: *Token, Period: *Token, Identifier: *Token) *Node {
        const err = try parser.createNode(Node.ErrorType);
        err.token = arg1;
        const name = try parser.createNode(Node.Identifier);
        name.token = arg3;
        const infix = try parser.createNode(Node.InfixOp);
        infix.lhs = &err.base;
        infix.op_token = arg2;
        infix.op = .Period;
        infix.rhs = &name.base;
        result = &infix.base;
    }
    fn Expr(Keyword_error: *Token, LBrace: Precedence_none(*Token), RBrace: *Token) *Node {
        const error_set = try parser.createNode(Node.ErrorSetDecl);
        error_set.error_token = arg1;
        error_set.decls = NodeList.init(parser.allocator);
        error_set.rbrace_token = arg3;
        result = &error_set.base;
    }
    fn Expr(Keyword_error: *Token, LBrace: Precedence_none(*Token), IdentifierList: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {
        const error_set = try parser.createNode(Node.ErrorSetDecl);
        error_set.error_token = arg1;
        error_set.decls = arg3.*;
        error_set.rbrace_token = arg5;
        result = &error_set.base;
    }
    fn Expr(Keyword_false: *Token) *Node {
        const node = try parser.createNode(Node.BoolLiteral);
        node.token = arg1;
        result = &node.base;
    }
    fn Expr(Keyword_true: *Token) *Node {
        const node = try parser.createNode(Node.BoolLiteral);
        node.token = arg1;
        result = &node.base;
    }
    fn Expr(Keyword_null: *Token) *Node {
        const node = try parser.createNode(Node.NullLiteral);
        node.token = arg1;
        result = &node.base;
    }
    fn Expr(Keyword_undefined: *Token) *Node {
        const node = try parser.createNode(Node.UndefinedLiteral);
        node.token = arg1;
        result = &node.base;
    }
    fn Expr(Keyword_unreachable: *Token) *Node {
        const node = try parser.createNode(Node.Unreachable);
        node.token = arg1;
        result = &node.base;
    }

    // Flow types
    fn Expr(SwitchExpr: Shadow(*Node)) *Node;

    // IfExpr
    fn Expr(IfPrefix: *Node.If, Expr: *Node) *Node {
        result = &arg1.base;
        arg1.body = arg2;
    }
    fn Expr(IfPrefix: *Node.If, Expr: *Node, Keyword_else: *Token, MaybePayload: *Node, Expr: *Node) *Node {
        result = &arg1.base;
        const node = try parser.createNode(Node.Else);
        node.else_token = arg3;
        node.payload = arg4;
        node.body = arg5;
        arg1.@"else" = node;
    }

    // Builtin calls
    fn Expr(Builtin: *Token, LParen: *Token, MaybeExprList: ?*NodeList, RParen: *Token) *Node {
        const node = try parser.createNode(Node.BuiltinCall);
        node.builtin_token = arg1;
        node.params = if (arg3) |p| p.* else NodeList.init(parser.allocator);
        node.rparen_token = arg4;
        result = &node.base;
    }

    // FunctionType
    fn Expr(FnProto: *Node.FnProto) *Node { result = &arg1.base; }

    // Suffix expressions
    fn Expr(Expr: *Node, SuffixExpr: *Node) *Node {
        if (arg2.cast(Node.SuffixOp)) |op| {
            op.lhs = arg1;
        } else {
            arg2.unsafe_cast(Node.InfixOp).lhs = arg1;
        }
        result = arg2;
    }
    fn SuffixExpr(SuffixExpr: *Node, SuffixExpr: *Node) *Node {
        if (arg2.cast(Node.SuffixOp)) |op| {
            op.lhs = arg1;
        } else {
            arg2.unsafe_cast(Node.InfixOp).lhs = arg1;
        }
        result = arg2;
    }

    // a[]
    fn SuffixExpr(LBracket: *Token, Expr: *Node, RBracket: *Token) *Node {
        const node = try parser.createNode(Node.SuffixOp);
        node.op = Node.SuffixOp.Op{ .ArrayAccess = arg2 };
        node.rtoken = arg3;
        result = &node.base;
    }
    fn SuffixExpr(LBracket: *Token, Expr: *Node, Ellipsis2: *Token, RBracket: *Token) *Node {
        const node = try parser.createNode(Node.SuffixOp);
        node.op = Node.SuffixOp.Op{ .Slice = Node.SuffixOp.Op.Slice{ .start = arg2, .end = null } };
        node.rtoken = arg4;
        result = &node.base;
    }
    fn SuffixExpr(LBracket: *Token, Expr: *Node, Ellipsis2: *Token, Expr: *Node, RBracket: *Token) *Node {
        const node = try parser.createNode(Node.SuffixOp);
        node.op = Node.SuffixOp.Op{ .Slice = Node.SuffixOp.Op.Slice{ .start = arg2, .end = arg4 } };
        node.rtoken = arg5;
        result = &node.base;
    }
    // a.b
    fn SuffixExpr(Period: *Token, Identifier: *Token) *Node {
        const name = try parser.createNode(Node.Identifier);
        name.token = arg2;
        const infix = try parser.createNode(Node.InfixOp);
        infix.op_token = arg1;
        infix.op = .Period;
        infix.rhs = &name.base;
        result = &infix.base;
    }
    // a.*
    fn SuffixExpr(PeriodAsterisk: *Token) *Node {
        const node = try parser.createNode(Node.SuffixOp);
        node.op = .Deref;
        node.rtoken = arg1;
        result = &node.base;
    }
    // a.?
    fn SuffixExpr(PeriodQuestionMark: *Token) *Node {
        const node = try parser.createNode(Node.SuffixOp);
        node.op = .UnwrapOptional;
        node.rtoken = arg1;
        result = &node.base;
    }
    // a()
    fn SuffixExpr(LParen: *Token, MaybeExprList: ?*NodeList, RParen: *Token) *Node {
        const node = try parser.createNode(Node.SuffixOp);
        node.op = Node.SuffixOp.Op{ .Call = Node.SuffixOp.Op.Call{ .async_attr = null, .params = if (arg2) |p| p.* else NodeList.init(parser.allocator) } };
        node.rtoken = arg3;
        result = &node.base;
    }

    // Containers (struct/enum/union)
    fn Expr(ContainerDecl: *Node) *Node;
    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclOp: *Token, LBrace: *Token, MaybeContainerMembers: ?*NodeList, RBrace: *Token) *Node {}
    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclType: *Node, LBrace: *Token, MaybeContainerMembers: ?*NodeList, RBrace: *Token) *Node {}

    // ContainerDecl helper
    fn MaybeExternPacked() ?*Token;
    fn MaybeExternPacked(Keyword_extern: *Token) ?*Token;
    fn MaybeExternPacked(Keyword_packed: *Token) ?*Token;

    fn SwitchExpr(Keyword_switch: *Token, LParen: *Token, Expr: *Node, RParen: *Token, LBrace: *Token, SwitchProngList: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    // Assembly
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, RParen: *Token) *Node {}
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, AsmOutput: *Node, RParen: *Token) *Node {}

    fn AsmOutput(Colon: *Token, AsmOutputList: *NodeList) *Node {}
    fn AsmOutput(Colon: *Token, AsmOutputList: *NodeList, AsmInput: *Node) *Node {}
    fn AsmOutput(Colon: *Token, AsmInput: *Node) *Node {}

    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Identifier: *Token, RParen: *Token) *Node {}
    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, MinusAngleBracketRight: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn AsmInput(Colon: *Token, AsmInputList: *NodeList) *Node {}
    fn AsmInput(Colon: *Token, AsmInputList: *NodeList, AsmClobber: *Node) *Node {}
    fn AsmInput(Colon: *Token, AsmClobber: *Node) *Node {}

    fn AsmInputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn AsmClobber(Colon: *Token) *Node {}
    fn AsmClobber(Colon: *Token, StringList: *NodeList) *Node {}

    // Helper grammar
    fn BreakLabel(Colon: *Token, Identifier: *Token) ?*Token {}

    fn WhileContinueExpr(Colon: *Token, LParen: *Token, AssignExpr: *Node, RParen: *Token) *Node {}

    fn MaybeLinkSection() ?*Node;
    fn MaybeLinkSection(Keyword_linksection: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    // Function specific
    fn MaybeFnCC() ?*Token;
    fn MaybeFnCC(Keyword_nakedcc: *Token) ?*Token;
    fn MaybeFnCC(Keyword_stdcallcc: *Token) ?*Token;
    fn MaybeFnCC(Keyword_extern: *Token) ?*Token;
    fn MaybeFnCC(Keyword_async: *Token) ?*Token;

    fn ParamDecl(MaybeNoalias: ?*Token, ParamType: *Node) *Node {}
    fn ParamDecl(MaybeNoalias: ?*Token, Identifier: *Token, Colon: *Token, ParamType: *Node) *Node {}
    fn ParamDecl(MaybeNoalias: ?*Token, Keyword_comptime: *Token, Identifier: *Token, Colon: *Token, ParamType: *Node) *Node {}

    fn ParamType(Keyword_var: *Token) *Node {}
    fn ParamType(Ellipsis3: *Token) *Node {}
    fn ParamType(Expr: *Node) *Node;

    // Control flow prefixes
    fn IfPrefix(Keyword_if: *Token, LParen: *Token, Expr: *Node, RParen: *Token, MaybePtrPayload: ?*Node) *Node.If {
        const node = try parser.createNode(Node.If);
        node.if_token = arg1;
        node.condition = arg3;
        node.payload = arg5;
        result = node;
    }

    fn ForPrefix(Keyword_for: *Token, LParen: *Token, Expr: *Node, RParen: *Token, PtrIndexPayload: *Node) *Node {}
    fn WhilePrefix(Keyword_while: *Token, LParen: *Token, Expr: *Node, RParen: *Token, MaybePtrPayload: ?*Node) *Node {}
    fn WhilePrefix(Keyword_while: *Token, LParen: *Token, Expr: *Node, RParen: *Token, MaybePtrPayload: ?*Node, WhileContinueExpr: *Node) *Node {}

    // Payloads
    fn MaybePayload() ?*Node;
    fn MaybePayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node;

    fn MaybePtrPayload() ?*Node;
    fn MaybePtrPayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn MaybePtrPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    fn PtrIndexPayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Identifier: *Token, Comma: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Comma: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    // Switch specific
    fn SwitchProng(SwitchCase: *Node, EqualAngleBracketRight: *Token, MaybePtrPayload: ?*Node, AssignExpr: *Node) *Node {}

    fn SwitchCase(Keyword_else: *Token) *Node {}
    fn SwitchCase(SwitchItems: *NodeList, MaybeComma: ?*Token) *Node {}

    fn SwitchItems(SwitchItem: *Node) *NodeList {}
    fn SwitchItems(SwitchItems: *NodeList, Comma: *Token, SwitchItem: *Node) *NodeList {}

    fn SwitchItem(Expr: *Node) *Node;
    fn SwitchItem(Expr: *Node, Ellipsis3: *Token, Expr: *Node) *Node {}

    fn MaybeVolatile() ?*Token;
    fn MaybeVolatile(Keyword_volatile: *Token) ?*Token;

    fn MaybeAllowzero() ?*Token;
    fn MaybeAllowzero(Keyword_allowzero: *Token) ?*Token;

    // ContainerDecl specific
    fn ContainerDeclType(Keyword_union: *Token, LParen: *Token, Keyword_enum: *Token, RParen: *Token) *Node {}
    fn ContainerDeclType(Keyword_union: *Token, LParen: *Token, Keyword_enum: *Token, LParen: *Token, Expr: *Node, RParen: *Token, RParen: *Token) *Node {}
    fn ContainerDeclType(Keyword_union: *Token, LParen: *Token, Expr: *Node, RParen: *Token) *Node {}
    fn ContainerDeclType(Keyword_enum: *Token, LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn ContainerDeclOp(Keyword_struct: *Token) *Token;
    fn ContainerDeclOp(Keyword_union: *Token) *Token;
    fn ContainerDeclOp(Keyword_enum: *Token) *Token;

    // Alignment
    fn MaybeByteAlign() ?*Node;
    fn MaybeByteAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    fn MaybeAlign() ?*Node;
    fn MaybeAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}
    fn MaybeAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, Colon: *Token, IntegerLiteral: *Token, Colon: *Token, IntegerLiteral: *Token, RParen: *Token) ?*Node {}
    fn MaybeAlign(Keyword_align: *Token, LParen: *Token, Identifier: *Token, Colon: *Token, IntegerLiteral: *Token, Colon: *Token, IntegerLiteral: *Token, RParen: *Token) ?*Node {}

    // Lists
    fn IdentifierList(Identifier: *Token) *NodeList {}
    fn IdentifierList(IdentifierList: *NodeList, Comma: *Token, Identifier: *Token) *NodeList {}

    fn SwitchProngList(SwitchProng: *Node) *NodeList {}
    fn SwitchProngList(SwitchProngList: *NodeList, Comma: *Token, SwitchProng: *Node) *NodeList {}

    fn AsmOutputList(AsmOutputItem: *Node) *NodeList {}
    fn AsmOutputList(AsmOutputList: *NodeList, Comma: *Token, AsmOutputItem: *Node) *NodeList {}

    fn AsmInputList(AsmInputItem: *Node) *NodeList {}
    fn AsmInputList(AsmInputList: *NodeList, Comma: *Token, AsmInputItem: *Node) *NodeList {}

    fn StringList(StringLiteral: *Token) *NodeList {}
    fn StringList(StringList: *NodeList, Comma: *Token, StringLiteral: *Token) *NodeList {}

    fn MaybeParamDeclList() ?*NodeList;
    fn MaybeParamDeclList(ParamDeclList: *NodeList, MaybeComma: ?*Token) *NodeList {}

    fn ParamDeclList(ParamDecl: *Node) *NodeList {}
    fn ParamDeclList(ParamDeclList: *NodeList, Comma: *Token, ParamDecl: *Node) *NodeList {}

    fn MaybeExprList() ?*NodeList {}
    fn MaybeExprList(ExprList: *NodeList, MaybeComma: ?*Token) ?*NodeList {
        result = arg1;
    }

    fn ExprList(Expr: *Node) *NodeList {
        result = try parser.createListWithNode(NodeList, arg1);
    }
    fn ExprList(ExprList: *NodeList, Comma: *Token, Expr: *Node) *NodeList {
        result = arg1;
        try arg1.append(arg3);
    }

    fn MaybeInitList() ?*NodeList {}
    fn MaybeInitList(InitList: *NodeList, MaybeComma: ?*Token) ?*NodeList {
        result = arg1;
    }

    fn InitList(Expr: *Node) *NodeList {
        result = try parser.createListWithNode(NodeList, arg1);
    }
    fn InitList(Period: *Token, Identifier: *Token, Equal: *Token, Expr: *Node) *NodeList {
        const node = try parser.createNode(Node.FieldInitializer);
        node.period_token = arg1;
        node.name_token = arg2;
        node.expr = arg4;
        result = try parser.createListWithNode(NodeList, &node.base);
    }
    fn InitList(InitList: *NodeList, Comma: *Token, Expr: *Node) *NodeList {
        result = arg1;
        try arg1.append(arg3);
    }
    fn InitList(InitList: *NodeList, Comma: *Token, Period: *Token, Identifier: *Token, Equal: *Token, Expr: *Node) *NodeList {
        result = arg1;
        const node = try parser.createNode(Node.FieldInitializer);
        node.period_token = arg3;
        node.name_token = arg4;
        node.expr = arg6;
        try arg1.append(&node.base);
    }

    // Various helpers
    fn MaybePub() ?*Token;
    fn MaybePub(Keyword_pub: *Token) ?*Token;

    fn MaybeColonTypeExpr() ?*Node;
    fn MaybeColonTypeExpr(Colon: *Token, TypeExpr: *Node) ?*Node {}

    fn MaybeExpr() ?*Node;
    fn MaybeExpr(Expr: *Node) ?*Node;

    fn MaybeNoalias() ?*Token;
    fn MaybeNoalias(Keyword_noalias: *Token) ?*Token;

    fn MaybeInline() ?*Token;
    fn MaybeInline(Keyword_inline: *Token) ?*Token;

    fn MaybeIdentifier() ?*Token;
    fn MaybeIdentifier(Identifier: *Token) ?*Token;

    fn MaybeComma() ?*Token;
    fn MaybeComma(Comma: *Token) ?*Token;

    fn MaybeConst() ?*Token;
    fn MaybeConst(Keyword_const: *Token) ?*Token;

    fn MultilineStringLiteral(LineString: *Token) *NodeList {}
    fn MultilineStringLiteral(MultilineStringLiteral: *NodeList, LineString: *Token) *NodeList {}

    fn MultilineCStringLiteral(LineCString: *Token) *NodeList {}
    fn MultilineCStringLiteral(MultilineCStringLiteral: *NodeList, LineCString: *Token) *NodeList {}

    fn FnProtoType(Keyword_var: *Token) *Node;
    fn FnProtoType(TypeExpr: *Node) *Node;

    fn TypeExpr(Identifier: *Token) *Node;
    fn TypeExpr(ContainerDecl: *Node) *Node;
    fn TypeExpr(TypeExpr: *Node, SuffixExpr: *Node) *Node;
    fn TypeExpr(TypeExpr: *Node, Bang: *Token, TypeExpr: *Node) *Node;
    fn TypeExpr(Builtin: *Token, LParen: *Token, MaybeExprList: ?*Node, RParen: *Token) *Node {}
    fn TypeExpr(QuestionMark: *Token, TypeExpr: *Node) *Node;
    fn TypeExpr(Keyword_promise: *Token, MinusAngleBracketRight: *Token, TypeExpr: *Node) *Node {}
    // ArrayType
    fn TypeExpr(LBracket: *Token, Expr: *Node, RBracket: *Token, TypeExpr: *Node) *Node {}
    // SliceType
    fn TypeExpr(LBracket: *Token, RBracket: *Token, MaybeAllowzero: ?*Token, MaybeByteAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, TypeExpr: *Node) *Node {}
    // PtrType
    fn TypeExpr(Asterisk: Precedence_none(*Token), MaybeAllowzero: ?*Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, TypeExpr: *Node) *Node {}
    fn TypeExpr(AsteriskAsterisk: Precedence_none(*Token), MaybeAllowzero: ?*Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, TypeExpr: *Node) *Node {}
    fn TypeExpr(BracketStarBracket: *Token, MaybeAllowzero: ?*Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, TypeExpr: *Node) *Node {}
    fn TypeExpr(BracketStarCBracket: *Token, MaybeAllowzero: ?*Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, TypeExpr: *Node) *Node {}
};
