pub extern "LALR" const ZigGrammar = struct {
    fn Root(ContainerMembers: *Node) *Node { break :result arg1; }

    // Containers
    fn ContainerMembers(ContainerMembers: *NodeList, ContainerMember: *Node) *NodeList {}
    fn ContainerMembers(ContainerMembers: *NodeList, ContainerMemberWithDocComment: *Node) *NodeList {}
    fn ContainerMembers(ContainerMember: *Node) *NodeList {}
    fn ContainerMembers(ContainerMemberWithDocComment: *Node) *NodeList {}

    fn ContainerMemberWithDocComment(DocCommentLines: *Node, ContainerMember: *Node) *Node {}

    fn ContainerMember(TestDecl: *Node) *Node { break :result arg1; }
    fn ContainerMember(TopLevelComptime: *Node) *Node { break :result arg1; }
    fn ContainerMember(MaybePub: ?*Token, TopLevelDecl: *Node) *Node {}
    fn ContainerMember(MaybePub: ?*Token, ContainerFields: *Node, Semicolon: *Token) *Node {}

    fn ContainerFields(ContainerField: *Node) *NodeList { break :result arg1; }
    fn ContainerFields(ContainerFields: *NodeList, Comma: *Token, ContainerField: *Node) *NodeList {}

    fn ContainerField(Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeEqualExpr: ?*Node) *Node {}

    fn DocCommentLines(DocCommentLines: *NodeList, DocComment: *Token) *NodeList {}
    fn DocCommentLines(DocComment: *Token) *NodeList {}

    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclOp: *Token, LBrace: *Token, RBrace: *Token) *Node {}
    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclOp: *Token, LBrace: *Token, ContainerMembers: *Node, RBrace: *Token) *Node {}
    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclType: *Node, LBrace: *Token, RBrace: *Token) *Node {}
    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclType: *Node, LBrace: *Token, ContainerMembers: *Node, RBrace: *Token) *Node {}

    fn ContainerDeclOp(Keyword_struct: *Token) *Token { break :result arg1; }
    fn ContainerDeclOp(Keyword_union: *Token) *Token { break :result arg1; }
    fn ContainerDeclOp(Keyword_enum: *Token) *Token { break :result arg1; }

    fn ContainerDeclType(Keyword_enum: *Token, LParen: *Token, Keyword_union: *Token, RParen: *Token) *Node {}
    fn ContainerDeclType(Keyword_enum: *Token, LParen: *Token, TypeExpr: *Node, RParen: *Token) *Node {}

    // Test
    fn TestDecl(Keyword_test: *Token, StringLiteral: *Token, Block: *Node) *Node {}

    // Comptime
    fn TopLevelComptime(Keyword_comptime: *Token, Block: *Node) *Node {}

    // TopLevel declarations
    fn TopLevelDecl(MaybeExternPackage: ?*Node, FnProto: *Node, Semicolon: *Token) *Node {}
    fn TopLevelDecl(MaybeExternPackage: ?*Node, FnProto: *Node, Block: *Node) *Node {}
    fn TopLevelDecl(MaybeExportInline: ?*Token, FnProto: *Node, Semicolon: *Token) *Node {}
    fn TopLevelDecl(MaybeExportInline: ?*Token, FnProto: *Node, Block: *Node) *Node {}
    fn TopLevelDecl(MaybeExternPackage: ?*Node, MaybeThreadlocal: ?*Token, VarDecl: *Node, Semicolon: *Token) *Node {}
    fn TopLevelDecl(MaybeExternPackage: ?*Node, MaybeThreadlocal: ?*Token, VarDecl: *Node, Block: *Node) *Node {}
    fn TopLevelDecl(MaybeExportExtern: ?*Token, MaybeThreadlocal: ?*Token, VarDecl: *Node, Semicolon: *Token) *Node {}
    fn TopLevelDecl(MaybeExportExtern: ?*Token, MaybeThreadlocal: ?*Token, VarDecl: *Node, Block: *Node) *Node {}
    fn TopLevelDecl(Keyword_usingnamespace: *Token, Expr: *Node, Semicolon: *Token) *Node {}

    // TopLevel binding types
    fn MaybeExternPackage() ?*Node { break :result null; }
    fn MaybeExternPackage(Keyword_extern: *Token, StringLiteral: *Token) ?*Node {}

    fn MaybeExportExtern() ?*Token { break :result null; }
    fn MaybeExportExtern(Keyword_export: *Token) ?*Token { break :result arg1; }
    fn MaybeExportExtern(Keyword_extern: *Token) ?*Token { break :result arg1; }

    fn MaybeExportInline() ?*Token { break :result null; }
    fn MaybeExportInline(Keyword_export: *Token) ?*Token { break :result arg1; }
    fn MaybeExportInline(Keyword_inline: *Token) ?*Token { break :result arg1; }

    fn MaybeThreadlocal() ?*Token { break :result null; }
    fn MaybeThreadlocal(Keyword_threadlocal: *Token) ?*Token { break :result arg1; }

    // Variables
    fn VarDecl(Keyword_const: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}
    fn VarDecl(Keyword_var: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}

    // Functions
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: *Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, Keyword_var: *Token) *Node {}
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: *Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, TypeExpr: *Node) *Node {}
    fn FnProto(AsyncPrefix: *Node, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: *Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, Keyword_var: *Token) *Node {}
    fn FnProto(AsyncPrefix: *Node, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: *Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, TypeExpr: *Node) *Node {}

    // Function call conventions
    fn MaybeFnCC() ?*Token { break :result null; }
    fn MaybeFnCC(Keyword_nakedcc: *Token) ?*Token { break :result arg1; }
    fn MaybeFnCC(Keyword_stdcallcc: *Token) ?*Token { break :result arg1; }
    fn MaybeFnCC(Keyword_extern: *Token) ?*Token { break :result arg1; }

    fn AsyncPrefix(Keyword_async: *Token) *Node {}
    fn AsyncPrefix(Keyword_async: *Token, AngleBracketLeft: *Token, PrefixExpr: *Node, AngleBracketRight: *Token) *Node {}

    // Parameters
    fn ParamDeclList(LParen: *Token, RParen: *Token) *Node {}
    fn ParamDeclList(LParen: *Token, ParamDecls: *NodeList, RParen: *Token) *Node {}

    fn ParamDecls(ParamDecl: *Node) *NodeList {}
    fn ParamDecls(ParamDecls: *NodeList, Comma: *Token, ParamDecl: *Node) *NodeList {}

    fn ParamDecl(MaybeNoaliasComptime: ?*Token, ParamType: *Node) *Node {}
    fn ParamDecl(MaybeNoaliasComptime: ?*Token, Identifer: *Token, Colon: *Token, ParamType: *Node) *Node {}

    fn ParamType(Keyword_var: *Token) *Node {}
    fn ParamType(Keyword_ellipsis3: *Token) *Node {}
    fn ParamType(TypeExpr: *Node) *Node { break :result arg1; }

    // Declaration post modifiers
    fn MaybeByteAlign() ?*Node { break :result null; }
    fn MaybeByteAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    fn MaybeLinkSection() ?*Node { break :result null; }
    fn MaybeLinkSection(Keyword_linksection: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    // Blocks
    fn Block(LBrace: *Token, RBrace: *Token) *Node {}
    fn Block(LBrace: *Token, Statements: *Node, RBrace: *Token) *Node {}

    fn BlockLabel(Identifier: *Token, Colon: *Token) *Token { break :result arg1; }
    fn BreakLabel(Colon: *Token, Identifier: *Token) *Token { break :result arg2; }

    fn BlockExpr(Block: *Node) *Node { break :result arg1; }
    fn BlockExpr(BlockLabel: *Token, Block: *Node) *Node {}

    fn BlockExprStatement(BlockExpr: *Node) *Node { break :result arg1; }
    fn BlockExprStatement(NestedStatement: *Node, Semicolon: *Token) *Node { break :result arg1; }

    // Statements
    fn Statements(Statement: *Node) *NodeList {}
    fn Statements(Statements: *NodeList, Statement: *Node) *NodeList {}

    fn Statement(VarDecl: *Node) *Node { break :result arg1; }
    fn Statement(Keyword_comptime: *Token, VarDecl: *Node) *Node {}
    fn Statement(Keyword_comptime: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_defer: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_errdefer: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_suspend: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_suspend: *Token, Semicolon: *Token) *Node {}
    fn Statement(BlockExpr: *Node) *Node { break :result arg1; }
    fn Statement(NestedStatement: *Node) *Node { break :result arg1; }

    fn NestedStatement(IfStatement: *Node) *Node { break :result arg1; }
    fn NestedStatement(LoopStatement: *Node) *Node { break :result arg1; }
    fn NestedStatement(LabeledLoopStatement: *Node) *Node { break :result arg1; }
    fn NestedStatement(AssignExpr: *Node, Semicolon: *Token) *Node { break :result arg1; }

    fn LabeledLoopStatement(BlockLabel: *Token, LoopStatement: *Node) *Node {}

    fn LoopStatement(MaybeInline: ?*Token, ForStatement: *Node) *Node {}
    fn LoopStatement(MaybeInline: ?*Token, WhileStatement: *Node) *Node {}

    fn IfPrefix(Keyword_if: *Token, LParen: *Token, Expr: *Node, RParen: *Token, MaybePtrPayload: ?*Node) *Node {}
    fn IfStatement(IfPrefix: *Node, BlockExpr: *Node) *Node {}
    fn IfStatement(IfPrefix: *Node, BlockExpr: *Node, ElseStatement: *Node) *Node {}
    fn IfStatement(IfPrefix: *Node, AssignExpr: *Node, Semicolon: *Token) *Node {}
    fn IfStatement(IfPrefix: *Node, AssignExpr: *Node, ElseStatement: *Node) *Node {}

    fn ElseStatement(Keyword_else: *Token, MaybePayload: ?*Node, Statement: *Node) *Node {}
    fn ElseNoPayloadStatement(Keyword_else: *Token, Statement: *Node) *Node {}

    fn ForPrefix(Keyword_for: *Token, LParen: *Token, Expr: *Node, RParen: *Token, PtrIndexPayload: *Node) *Node {}
    fn ForStatement(ForPrefix: *Node, BlockExpr: *Node) *Node {}
    fn ForStatement(ForPrefix: *Node, BlockExpr: *Node, ElseNoPayloadStatement: *Node) *Node {}
    fn ForStatement(ForPrefix: *Node, AssignExpr: *Node, Semicolon: *Token) *Node {}
    fn ForStatement(ForPrefix: *Node, AssignExpr: *Node, ElseNoPayloadStatement: *Node) *Node {}

    fn WhilePrefix(Keyword_while: *Token, LParen: *Token, Expr: *Node, RParen: *Token, MaybePtrPayload: ?*Node) *Node {}
    fn WhilePrefix(Keyword_while: *Token, LParen: *Token, Expr: *Node, RParen: *Token, MaybePtrPayload: ?*Node, WhileContinueExpr: *Node) *Node {}
    fn WhileStatement(WhilePrefix: *Node, BlockExpr: *Node) *Node {}
    fn WhileStatement(WhilePrefix: *Node, BlockExpr: *Node, ElseStatement: *Node) *Node {}
    fn WhileStatement(WhilePrefix: *Node, AssignExpr: *Node, Semicolon: *Token) *Node {}
    fn WhileStatement(WhilePrefix: *Node, AssignExpr: *Node, ElseStatement: *Node) *Node {}
    fn WhileContinueExpr(Colon: *Token, LParen: *Token, AssignExpr: *Node, RParen: *Token) *Node {}

    // Payloads
    fn MaybePayload() ?*Node { break :result null; }
    fn MaybePayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    fn MaybePtrPayload() ?*Node { break :result null; }
    fn MaybePtrPayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn MaybePtrPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    fn PtrIndexPayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Identifier: *Token, Comma: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Comma: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    // Expressions
    fn AssignExpr(LExpr: *Node, AssignOp: *Token, RExpr: *Node) *Node {}
    fn AssignExpr(SExpr: *Node) *Node { break :result arg1; }

    fn LExpr(Identifier: *Token) *Node {}
    fn LExpr(Identifier: *Token, SuffixOps: *Node) *Node {}
    fn LExpr(Builtin: *Token, Identifier: *Token, FnCallArguments: *Node) *Node {}

    fn SExpr(Keyword_break: *Token) *Node {}
    fn SExpr(Keyword_continue: *Token) *Node {}
    fn SExpr(Keyword_cancel: *Token) *Node {}
    fn SExpr(Keyword_resume: *Token) *Node {}
    fn SExpr(AsmExpr: *Node) *Node { break :result arg1; }
    fn SExpr(SwitchExpr: *Node) *Node { break :result arg1; }
    // fn SExpr(SExprTails: *Node) *Node { break :result arg1; }
    fn SExpr(Identifier: *Token, SExprTails: *Node) *Node {}

    fn SExprTails(SExprTail: *Node) *Node { break :result arg1; }
    fn SExprTails(SExprTails: *Node, SExprTail: *Node) *Node {}

    fn SExprTail(FnCallArguments: *Node) *Node { break :result arg1; }
    fn SExprTail(SuffixOps: *Node, FnCallArguments: *Node) *Node {}

    fn RExpr(Expr: *Node) *Node { break :result arg1; }
    fn RExpr(Keyword_overload: *Token, LBrace: *Token, ExprList: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn ExprList(Expr: *Node) *Node { break :result arg1; }
    fn ExprList(ExprList: *Node, Comma: *Token, Expr: *Node) *Node {}

    fn Expr(BoolOrExpr: *Node) *Node { break :result arg1; }

    fn BoolOrExpr(BoolAndExpr: *Node) *Node { break :result arg1; }
    fn BoolOrExpr(BoolOrExpr: *Node, Keyword_or: *Token, BoolAndExpr: *Node) *Node {}
    
    fn BoolAndExpr(BoolCompareExpr: *Node) *Node { break :result arg1; }
    fn BoolAndExpr(BoolAndExpr: *Node, Keyword_and: *Token, BoolCompareExpr: *Node) *Node {}

    fn BoolCompareExpr(BitwiseExpr: *Node) *Node { break :result arg1; }
    fn BoolCompareExpr(BoolCompareExpr: *Node, CompareOp: *Token, BitwiseExpr: *Node) *Node {}

    fn BitwiseExpr(BitShiftExpr: *Node) *Node { break :result arg1; }
    fn BitwiseExpr(BitwiseExpr: *Node, BitwiseOp: *Token, BitShiftExpr: *Node) *Node {}
    fn BitwiseExpr(BitwiseExpr: *Node, Keyword_catch: *Token, MaybePayload: ?*Node, BitShiftExpr: *Node) *Node {}

    fn BitShiftExpr(AdditionExpr: *Node) *Node { break :result arg1; }
    fn BitShiftExpr(BitShiftExpr: *Node, BitShiftOp: *Token, AdditionExpr: *Node) *Node {}

    fn AdditionExpr(MultiplyExpr: *Node) *Node { break :result arg1; }
    fn AdditionExpr(AdditionExpr: *Node, AdditionOp: *Token, MultiplyExpr: *Node) *Node {}

    fn MultiplyExpr(PrefixExpr: *Node) *Node { break :result arg1; }
    fn MultiplyExpr(MultiplyExpr: *Node, MultiplyOp: *Token, PrefixExpr: *Node) *Node {}

    fn IfExpr(IfPrefix: *Node, Expr: *Node) *Node {}
    fn IfExpr(IfPrefix: *Node, Expr: *Node, ElseExpr: *Node) *Node {}

    fn ElseExpr(Keyword_else: *Token, MaybePayload: *Node, Expr: *Node) *Node {}

    fn GroupedExpr(LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn PrefixExpr(PrimaryExpr: *Node) *Node { break :result arg1; }
    fn PrefixExpr(PrefixOp: *Token, PrefixExpr: *Node) *Node {}

    fn PrimaryExpr(Keyword_comptime: *Token, Expr: *Node) *Node {}
    fn PrimaryExpr(AsmExpr: *Node) *Node { break :result arg1; }
    fn PrimaryExpr(BlockExpr: *Node) *Node { break :result arg1; }
    fn PrimaryExpr(TypeExpr: *Node) *Node { break :result arg1; }
    fn PrimaryExpr(TypeExpr: *Node, InitList: *Node) *Node {}

    // Type expressions
    fn TypeExpr(PrefixTypeOps: *Node, ErrorUnionExpr: *Node) *Node {}

    fn ErrorUnionExpr(SuffixExpr: *Node) *Node { break :result arg1; }
    fn ErrorUnionExpr(SuffixExpr: *Node, Bang: *Token, TypeExpr: *Node) *Node {}

    fn PrefixTypeOps(PrefixTypeOp: *Node) *Node { break :result arg1; }
    fn PrefixTypeOps(PrefixTypeOps: *Node, PrefixTypeOp: *Node) *Node {}

    fn PrefixTypeOp(QuestionMark: *Token) *Node {}
    fn PrefixTypeOp(Keyword_promise: *Token, MinusAngleBracketRight: *Token) *Node {}
    fn PrefixTypeOp(ArrayTypeStart: *Node, MaybeByteAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token) *Node {}
    fn PrefixTypeOp(PtrTypeStart: *Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token) *Node {}

    fn SuffixExpr(AsyncPrefix: *Node, PrimaryTypeExpr: *Node, FnCallArguments: *Node) *Node {}
    fn SuffixExpr(AsyncPrefix: *Node, PrimaryTypeExpr: *Node, SuffixOps: *Node, FnCallArguments: *Node) *Node {}
    fn SuffixExpr(PrimaryTypeExpr: *Node) *Node { break :result arg1; }
    fn SuffixExpr(PrimaryTypeExpr: *Node, SuffixOps: *Node) *Node {}
    fn SuffixExpr(PrimaryTypeExpr: *Node, FnCallArguments: *Node) *Node {}

    fn SuffixOps(SuffixOp: *Node) *Node { break :result arg1; }
    fn SuffixOps(SuffixOps: *Node, SuffixOp: *Node) *Node {}
    fn SuffixOp(LBracket: *Token, Expr: *Node, RBracket: *Token) *Node {}

    fn SuffixOp(LBracket: *Token, Expr: *Node, Ellipsis2: *Token, RBracket: *Token) *Node {}
    fn SuffixOp(LBracket: *Token, Expr: *Node, Ellipsis2: *Token, Expr: *Node, RBracket: *Token) *Node {}
    fn SuffixOp(Period: *Token, Identifier: *Token) *Node {}
    fn SuffixOp(Period: *Token, Asterisk: *Token) *Node {}
    fn SuffixOp(Period: *Token, QuestionMark: *Token) *Node {}

    fn FnCallArguments(LParen: *Token, RParen: *Token) *Node {}
    fn FnCallArguments(LParen: *Token, ExprList: *NodeList, RParen: *Token) *Node {}

    fn ArrayTypeStart(LBracket: *Token, RBracket: *Token) *Node {}
    fn ArrayTypeStart(LBracket: *Token, Expr: *Node, RBracket: *Token) *Node {}

    fn PtrTypeStart(Asterisk: *Token) *Token { break :result arg1; }
    fn PtrTypeStart(AsteriskAsterisk: *Token) *Token { break :result arg1; }
    fn PtrTypeStart(BracketStarBracket: *Token) *Token { break :result arg1; }
    fn PtrTypeStart(BracketStarCBracket: *Token) *Token { break :result arg1; }

    fn PrimaryTypeExpr(Builtin: *Token, Identifier: *Token, FnCallArguments: *Node) *Node {}
    fn PrimaryTypeExpr(CharLiteral: *Token) *Node { break :result arg1; }
    fn PrimaryTypeExpr(ContainerDecl: *Node) *Node { break :result arg1; }
    fn PrimaryTypeExpr(Period: *Token, Identifier: *Token) *Node {}
    fn PrimaryTypeExpr(ErrorSetDecl: *Node) *Node { break :result arg1; }
    fn PrimaryTypeExpr(FloatLiteral: *Token) *Node {}
    fn PrimaryTypeExpr(FnProto: *Node) *Node { break :result arg1; }
    fn PrimaryTypeExpr(GroupedExpr: *Node) *Node { break :result arg1; }
    fn PrimaryTypeExpr(Identifier: *Token) *Node {}
    fn PrimaryTypeExpr(IntegerLiteral: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_anyerror: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_comptime: *Token, TypeExpr: *Node) *Node {}
    fn PrimaryTypeExpr(Keyword_error: *Token, Period: *Token, Identifier: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_false: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_null: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_promise: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_true: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_undefined: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_unreachable: *Token) *Node {}
    fn PrimaryTypeExpr(StringLiteral: *Token) *Node {}
    fn PrimaryTypeExpr(SwitchExpr: *Node) *Node { break :result arg1; }
    fn PrimaryTypeExpr(IfExpr: *Node) *Node { break :result arg1; }

    fn ErrorSetDecl(Keyword_error: *Token, LBrace: *Token, RBrace: *Token) *Node {}
    fn ErrorSetDecl(Keyword_error: *Token, LBrace: *Token, IdentifierList: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn IdentifierList(Identifier: *Token) *NodeList {}
    fn IdentifierList(IdentifierList: *NodeList, Comma: *Token, Identifier: *Token) *NodeList {}

    // Initializer list
    fn InitList(LBrace: *Token, RBrace: *Token) *Node {}
    fn InitList(LBrace: *Token, FieldInits: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {}
    fn InitList(LBrace: *Token, ExprList: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn FieldInits(FieldInit: *Node) *NodeList {}
    fn FieldInits(FieldInits: *NodeList, Comma: *Token, FieldInit: *Node) *NodeList {}

    fn FieldInit(Period: *Token, Identifier: *Token, Equal: *Token, Expr: *Node) *Node {}

    // Operators
    fn AssignOp(AsteriskEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(SlashEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(PercentEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(MinusEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(AngleBracketAngleBracketLeftEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(AngleBracketAngleBracketRightEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(AmpersandEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(CaretEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(PipeEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(AsteriskPercentEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(PlusPercentEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(MinusPercentEqual: *Token) *Token { break :result arg1; }
    fn AssignOp(Equal: *Token) *Token { break :result arg1; }

    fn CompareOp(EqualEqual: *Token) *Token { break :result arg1; }
    fn CompareOp(BangEqual: *Token) *Token { break :result arg1; }
    fn CompareOp(AngleBracketLeft: *Token) *Token { break :result arg1; }
    fn CompareOp(AngleBracketRight: *Token) *Token { break :result arg1; }
    fn CompareOp(AngleBracketLeftEqual: *Token) *Token { break :result arg1; }
    fn CompareOp(AngleBracketRightEqual: *Token) *Token { break :result arg1; }

    fn BitwiseOp(Ampersand: *Token) *Token { break :result arg1; }
    fn BitwiseOp(Caret: *Token) *Token { break :result arg1; }
    fn BitwiseOp(Keyword_orelse: *Token) *Token { break :result arg1; }
    // fn BitwiseOp(Keyword_catch: *Token) *Token { break :result arg1; }

    fn BitShiftOp(AngleBracketAngleBracketLeft: *Token) *Token { break :result arg1; }
    fn BitShiftOp(AngleBracketAngleBracketRight: *Token) *Token { break :result arg1; }

    fn AdditionOp(Plus: *Token) *Token { break :result arg1; }
    fn AdditionOp(Minus: *Token) *Token { break :result arg1; }
    fn AdditionOp(PlusPlus: *Token) *Token { break :result arg1; }
    fn AdditionOp(PlusPercent: *Token) *Token { break :result arg1; }
    fn AdditionOp(MinusPercent: *Token) *Token { break :result arg1; }

    fn MultiplyOp(PipePipe: *Token) *Token { break :result arg1; }
    fn MultiplyOp(Asterisk: *Token) *Token { break :result arg1; }
    fn MultiplyOp(Slash: *Token) *Token { break :result arg1; }
    fn MultiplyOp(Percent: *Token) *Token { break :result arg1; }
    fn MultiplyOp(AsteriskAsterisk: *Token) *Token { break :result arg1; }
    fn MultiplyOp(AsteriskPercent: *Token) *Token { break :result arg1; }

    fn PrefixOp(Bang: *Token) *Token { break :result arg1; }
    fn PrefixOp(Minus: *Token) *Token { break :result arg1; }
    fn PrefixOp(Tilde: *Token) *Token { break :result arg1; }
    fn PrefixOp(MinusPercent: *Token) *Token { break :result arg1; }
    fn PrefixOp(Ampersand: *Token) *Token { break :result arg1; }
    fn PrefixOp(Keyword_try: *Token) *Token { break :result arg1; }
    fn PrefixOp(Keyword_await: *Token) *Token { break :result arg1; }

    // Assembly
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, RParen: *Token) *Node {}
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, AsmOuput: *Node, RParen: *Token) *Node {}

    fn AsmOutput(Colon: *Token, AsmOutputItems: *NodeList) *Node {}
    fn AsmOutput(Colon: *Token, AsmOutputItems: *NodeList, AsmInput: *Node) *Node {}
    fn AsmOutput(Colon: *Token, AsmInput: *Node) *Node {}

    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Identifier: *Token, RParen: *Token) *Node {}
    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, MinusAngleBracketRight: *Token, TypeExpr: *Node, RParen: *Token) *Node {}

    fn AsmOutputItems(AsmOutputItem: *Node) *NodeList {}
    fn AsmOutputItems(AsmOutputItems: *NodeList, Comma: *Token, AsmOutputItem: *Node) *NodeList {}

    fn AsmInput(Colon: *Token, AsmInputItems: *NodeList) *Node {}
    fn AsmInput(Colon: *Token, AsmInputItems: *NodeList, AsmClobber: *Node) *Node {}
    fn AsmInput(Colon: *Token, AsmClobber: *Node) *Node {}

    fn AsmInputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn AsmInputItems(AsmInputItem: *Node) *Node {}
    fn AsmInputItems(AsmInputItems: *NodeList, Comma: *Token, AsmInputItem: *Node) *NodeList {}

    fn AsmClobber(Colon: *Token) *Node {}
    fn AsmClobber(Colon: *Token, StringList: *NodeList) *Node {}

    fn StringList(StringLiteral: *Token) *NodeList {}
    fn StringList(StringList: *NodeList, Comma: *Token, StringLiteral: *Token) *NodeList {}

    // Switch
    fn Switch(Keyword_switch: *Token, LParen: *Token, Expr: *Node, RParen: *Token, LBrace: *Token, SwitchProngs: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn SwitchProngs(SwitchProng: *Node) *NodeList {}
    fn SwitchProngs(SwitchProngs: *NodeList, Comma: *Token, SwitchProng: *Node) *NodeList {}

    fn SwitchProng(SwitchCase: *Node, EqualAngleBracketRight: *Token, MaybePtrPayload: ?*Node, Expr: *Node) *Node {}

    fn SwitchCase(Keyword_else: *Token) *Node {}
    fn SwitchCase(SwitchItems: *NodeList, MaybeComma: ?*Token) *Node { break :result arg1; }

    fn SwitchItems(SwitchItem: *Node) *NodeList {}
    fn SwitchItems(SwitchItems: *NodeList, Comma: *Token, SwitchItem: *Node) *NodeList {}

    fn SwitchItem(Expr: *Node) *Node { break :result arg1; }
    fn SwitchItem(Expr: *Node, Ellipsis3: *Token, Expr: *Node) *Node {}

    // Maybe helpers
    fn MaybePub() ?*Token { break :result null; }
    fn MaybePub(Keyword_pub: *Token) ?*Token { break :result arg1; }

    fn MaybeColonTypeExpr() ?*Node { break :result null; }
    fn MaybeColonTypeExpr(Colon: *Token, TypeExpr: *Node) ?*Node { break :result arg2; }

    fn MaybeEqualExpr() ?*Node { break :result null; }
    fn MaybeEqualExpr(Equal: *Token, RExpr: *Node) ?*Node { break :result arg2; }

    fn MaybeBang() ?*Token { break :result null; }
    fn MaybeBang(Bang: *Token) ?*Token { break :result arg1; }

    fn MaybeNoaliasComptime() ?*Token { break :result null; }
    fn MaybeNoaliasComptime(Keyword_noalias: *Token) ?*Token { break :result arg1; }
    fn MaybeNoaliasComptime(Keyword_comptime: *Token) ?*Token { break :result arg1; }

    fn MaybeInline() ?*Token { break :result null; }
    fn MaybeInline(Inline: *Token) ?*Token { break :result arg1; }

    fn MaybeComma() ?*Token { break :result null; }
    fn MaybeComma(Comma: *Token) ?*Token { break :result arg1; }

    fn MaybeConst() ?*Token { break :result null; }
    fn MaybeConst(Keyword_const: *Token) ?*Token { break :result arg1; }

    fn MaybeVolatile() ?*Token { break :result null; }
    fn MaybeVolatile(Keyword_volatile: *Token) ?*Token { break :result arg1; }

    fn MaybeAllowzero() ?*Token { break :result null; }
    fn MaybeAllowzero(Keyword_allowzero: *Token) ?*Token { break :result arg1; }

    fn MaybeExternPacked() ?*Token { break :result null; }
    fn MaybeExternPacked(Keyword_extern: *Token) ?*Token { break :result arg1; }
    fn MaybeExternPacked(Keyword_packed: *Token) ?*Token { break :result arg1; }
};
