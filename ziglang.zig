pub extern "LALR" const ZigGrammar = struct {
    fn Root(ContainerMembers: *Node) ?*Node { return arg1; }

    // Containers
    fn ContainerMembers(ContainerMembers: *Node, ContainerMember: *Node) *Node {}
    fn ContainerMembers(ContainerMembers: *Node, ContainerMemberWithDocComment: *Node) *Node {}
    fn ContainerMembers(ContainerMember: *Node) *Node { return arg1; }
    fn ContainerMembers(ContainerMemberWithDocComment: *Node) *Node { return arg1; }

    fn ContainerMemberWithDocComment(DocCommentLines: *Node, ContainerMember: *Node) *Node {}

    fn ContainerMember(TestDecl: *Node) *Node { return arg1; }
    fn ContainerMember(TopLevelComptime: *Node) *Node { return arg1; }
    fn ContainerMember(MaybePub: ?*Token, TopLevelDecl: *Node) *Node {}
    fn ContainerMember(MaybePub: ?*Token, ContainerFields: *Node, Semicolon: *Token) *Node {}

    fn ContainerFields(ContainerField: *Node) *Node { return arg1; }
    fn ContainerFields(ContainerFields: *Node, Comma: *Token, ContainerField: *Node) *Node {}

    fn ContainerField(Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeEqualExpr: ?*Node) *Node {}

    fn DocCommentLines(DocCommentLines: *Node, DocComment: *Token) *Node {}
    fn DocCommentLines(DocComment: *Token) *Node {}

    fn ContainerDeclAuto(ContainerDeclType: *Node, LBrace: *Token, RBrace: *Token) *Node {}
    fn ContainerDeclAuto(ContainerDeclType: *Node, LBrace: *Token, ContainerMembers: *Node, RBrace: *Token) *Node {}

    fn ContainerDeclType(Keyword_struct: *Token) *Node {}
    fn ContainerDeclType(Keyword_union: *Token) *Node {}
    fn ContainerDeclType(Keyword_enum: *Token) *Node {}
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
    fn MaybeExternPackage() ?*Node { return null; }
    fn MaybeExternPackage(Keyword_extern: *Token, StringLiteral: *Token) ?*Node {}

    fn MaybeExportExtern() ?*Token { return null; }
    fn MaybeExportExtern(Keyword_export: *Token) ?*Token { return arg1; }
    fn MaybeExportExtern(Keyword_extern: *Token) ?*Token { return arg1; }

    fn MaybeExportInline() ?*Token { return null; }
    fn MaybeExportInline(Keyword_export: *Token) ?*Token { return arg1; }
    fn MaybeExportInline(Keyword_inline: *Token) ?*Token { return arg1; }

    fn MaybeThreadlocal() ?*Token { return null; }
    fn MaybeThreadlocal(Keyword_threadlocal: *Token) ?*Token { return arg1; }

    // Variables
    fn VarDecl(Keyword_const: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}
    fn VarDecl(Keyword_var: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}

    // Functions
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: *Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, Keyword_var: *Token) *Node {}
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, TypeExpr: *Node) *Node {}
    fn FnProto(AsyncPrefix: *Node, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, Keyword_var: *Token) *Node {}
    fn FnProto(AsyncPrefix: *Node, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, TypeExpr: *Node) *Node {}

    // Function call conventions
    fn MaybeFnCC() ?*Token { return null; }
    fn MaybeFnCC(Keyword_nakedcc: *Token) ?*Token { return arg1; }
    fn MaybeFnCC(Keyword_stdcallcc: *Token) ?*Token { return arg1; }
    fn MaybeFnCC(Keyword_extern: *Token) ?*Token { return arg1; }

    fn AsyncPrefix(Keyword_async: *Token) *Node {}
    fn AsyncPrefix(Keyword_async: *Token, AngleBracketLeft: *Token, PrefixExpr: *Node, AngleBracketRight: *Token) *Node {}

    // Parameters
    fn ParamDeclList(LParen: *Token, RParen: *Token) *Node {}
    fn ParamDeclList(LParen: *Token, ParamDecls: *Node, RParen: *Token) *Node {}

    fn ParamDecls(ParamDecl: *Node) *Node { return arg1; }
    fn ParamDecls(ParamDecls: *Node, Comma: *Token, ParamDecl: *Node) *Node {}

    fn ParamDecl(MaybeNoaliasComptime: ?*Token, ParamType: *Node) *Node {}
    fn ParamDecl(MaybeNoaliasComptime: ?*Token, Identifer: *Token, Colon: *Token, ParamType: *Node) *Node {}

    fn ParamType(Keyword_var: *Token) *Node {}
    fn ParamType(Keyword_ellipsis3: *Token) *Node {}
    fn ParamType(TypeExpr: *Node) *Node { return arg1; }

    // Declaration post modifiers
    fn MaybeByteAlign() ?*Node { return null; }
    fn MaybeByteAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    fn MaybeLinkSection() ?*Node { return null; }
    fn MaybeLinkSection(Keyword_linksection: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    // Blocks
    fn Block(LBrace: *Token, RBrace: *Token) *Node {}
    fn Block(LBrace: *Token, Statements: *Node, RBrace: *Token) *Node {}

    fn BlockLabel(Identifier: *Token, Colon: *Token) *Token { return arg1; }
    fn BreakLabel(Colon: *Token, Identifier: *Token) *Token { return arg2; }

    fn BlockExpr(Block: *Node) *Node { return arg1; }
    fn BlockExpr(BlockLabel: *Token, Block: *Node) *Node {}

    fn BlockExprStatement(BlockExpr: *Node) *Node { return arg1; }
    fn BlockExprStatement(NestedStatement: *Node, Semicolon: *Token) *Node { return arg1; }

    // Statements
    fn Statements(Statement: *Node) *Node { return arg1; }
    fn Statements(Statements: *Node, Statement: *Node) *Node {}

    fn Statement(VarDecl: *Node) *Node { return arg1; }
    fn Statement(Keyword_comptime: *Token, VarDecl: *Node) *Node {}
    fn Statement(Keyword_comptime: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_defer: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_errdefer: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_suspend: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_suspend: *Token, Semicolon: *Token) *Node {}
    fn Statement(BlockExpr: *Node) *Node { return arg1; }
    fn Statement(NestedStatement: *Node) *Node { return arg1; }

    fn NestedStatement(IfStatement: *Node) *Node { return arg1; }
    fn NestedStatement(LoopStatement: *Node) *Node { return arg1; }
    fn NestedStatement(LabeledLoopStatement: *Node) *Node { return arg1; }
    fn NestedStatement(AssignExpr: *Node, Semicolon: *Token) *Node { return arg1; }

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
    fn MaybePayload() ?*Node { return null; }
    fn MaybePayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    fn MaybePtrPayload() ?*Node { return null; }
    fn MaybePtrPayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn MaybePtrPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    fn PtrIndexPayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Identifier: *Token, Comma: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Comma: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    // Expressions
    fn AssignExpr(LExpr: *Node, AssignOp: *Token, RExpr: *Node) *Node {}
    fn AssignExpr(SExpr: *Node) *Node { return arg1; }

    fn LExpr(Identifier: *Token) *Node {}
    fn LExpr(Identifier: *Token, SuffixOps: *Node) *Node {}
    fn LExpr(Builtin: *Token, Identifier: *Token, FnCallArguments: *Node) *Node {}

    fn SExpr(AsmExpr: *Node) *Node { return arg1; }
    fn SExpr(SwitchExpr: *Node) *Node { return arg1; }
    fn SExpr(SExprTails: *Node) *Node { return arg1; }
    fn SExpr(Identifier: *Token, SExprTails: *Node) *Node {}

    fn SExprTails(SExprTail: *Node) *Node { return arg1; }
    fn SExprTails(SExprTails: *Node, SExprTail: *Node) *Node {}

    fn SExprTail(FnCallArguments: *Node) *Node { return arg1; }
    fn SExprTail(SuffixOps: *Node, FnCallArguments: *Node) *Node {}

    fn RExpr(Expr: *Node) *Node { return arg1; }
    fn RExpr(Keyword_overload: *Token, LBrace: *Token, Exprs: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn Exprs(Expr: *Node) *Node { return arg1; }
    fn Exprs(Exprs: *Node, Comma: *Token, Expr: *Node) *Node {}

    fn Expr(BoolOrExpr: *Node) *Node { return arg1; }

    fn BoolOrExpr(BoolAndExpr: *Node) *Node { return arg1; }
    fn BoolOrExpr(BoolOrExpr: *Node, Keyword_or: *Token, BoolAndExpr: *Node) *Node {}
    
    fn BoolAndExpr(BoolCompareExpr: *Node) *Node { return arg1; }
    fn BoolAndExpr(BoolAndExpr: *Node, Keyword_and: *Token, BoolCompareExpr: *Node) *Node {}

    fn BoolCompareExpr(BitwiseExpr: *Node) *Node { return arg1; }
    fn BoolCompareExpr(BoolCompareExpr: *Node, CompareOp: *Token, BitwiseExpr: *Node) *Node {}

    fn BitwiseExpr(BitShiftExpr: *Node) *Node { return arg1; }
    fn BitwiseExpr(BitwiseExpr: *Node, BitwiseOp: *Token, BitShiftExpr: *Node) *Node {}
    fn BitwiseExpr(BitwiseExpr: *Node, Keyword_catch: *Token, MaybePayload: ?*Node, BitShiftExpr: *Node) *Node {}

    fn BitShiftExpr(AdditionExpr: *Node) *Node { return arg1; }
    fn BitShiftExpr(BitShiftExpr: *Node, BitShiftOp: *Token, AdditionExpr: *Node) *Node {}

    fn AdditionExpr(MultiplyExpr: *Node) *Node { return arg1; }
    fn AdditionExpr(AdditionExpr: *Node, AdditionOp: *Token, MultiplyExpr: *Node) *Node {}

    fn MultiplyExpr(PrefixExpr: *Node) *Node { return arg1; }
    fn MultiplyExpr(MultiplyExpr: *Node, MultiplyOp: *Token, PrefixExpr: *Node) *Node {}

    fn IfExpr(IfPrefix: *Node, Expr: *Node) *Node {}
    fn IfExpr(IfPrefix: *Node, Expr: *Node, ElseExpr: *Node) *Node {}

    fn ElseExpr(Keyword_else: *Token, MaybePayload: *Node, Expr: *Node) *Node {}

    fn GroupedExpr(LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn PrefixExpr(PrimaryExpr: *Node) *Node { return arg1; }
    fn PrefixExpr(PrefixOp: *Token, PrefixExpr: *Node) *Node {}

    fn PrimaryExpr(Keyword_comptime: *Token, Expr: *Node) *Node {}
    fn PrimaryExpr(AsmExpr: *Node) *Node { return arg1; }
    fn PrimaryExpr(BlockExpr: *Node) *Node { return arg1; }
    fn PrimaryExpr(TypeExpr: *Node) *Node { return arg1; }
    fn PrimaryExpr(TypeExpr: *Node, InitList: *Node) *Node {}

    // Type expressions
    fn TypeExpr(PrefixTypeOps: *Node, ErrorUnionExpr: *Node) *Node {}

    fn ErrorUnionExpr(SuffixExpr: *Node) *Node { return arg1; }
    fn ErrorUnionExpr(SuffixExpr: *Node, Bang: *Token, TypeExpr: *Node) *Node {}

    fn PrefixTypeOps(PrefixTypeOp: *Node) *Node { return arg1; }
    fn PrefixTypeOps(PrefixTypeOps: *Node, PrefixTypeOp: *Node) *Node {}

    fn PrefixTypeOp(QuestionMark: *Token) *Node {}
    fn PrefixTypeOp(Keyword_promise: *Token, MinusAngleBracketRight: *Token) *Node {}
    fn PrefixTypeOp(ArrayTypeStart: *Node, MaybeByteAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token) *Node {}
    fn PrefixTypeOp(PtrTypeStart: *Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token) *Node {}

    fn SuffixExpr(AsyncPrefix: *Node, PrimaryTypeExpr: *Node, FnCallArguments: *Node) *Node {}
    fn SuffixExpr(AsyncPrefix: *Node, PrimaryTypeExpr: *Node, SuffixOps: *Node, FnCallArguments: *Node) *Node {}
    fn SuffixExpr(PrimaryTypeExpr: *Node) *Node { return arg1; }
    fn SuffixExpr(PrimaryTypeExpr: *Node, SuffixOps: *Node) *Node {}
    fn SuffixExpr(PrimaryTypeExpr: *Node, FnCallArguments: *Node) *Node {}

    fn SuffixOps(SuffixOp: *Node) *Node { return arg1; }
    fn SuffixOps(SuffixOps: *Node, SuffixOp: *Node) *Node {}
    fn SuffixOp(LBracket: *Token, Expr: *Node, RBracket: *Token) *Node {}

    fn SuffixOp(LBracket: *Token, Expr: *Node, Ellipsis2: *Token, RBracket: *Token) *Node {}
    fn SuffixOp(LBracket: *Token, Expr: *Node, Ellipsis2: *Token, Expr: *Node, RBracket: *Token) *Node {}
    fn SuffixOp(Period: *Token, Identifier: *Token) *Node {}
    fn SuffixOp(Period: *Token, Asterisk: *Token) *Node {}
    fn SuffixOp(Period: *Token, QuestionMark: *Token) *Node {}

    fn FnCallArguments(LParen: *Token, RParen: *Token) *Node {}
    fn FnCallArguments(LParen: *Token, Exprs: *Node, RParen: *Token) *Node {}

    fn ArrayTypeStart(LBracket: *Token, RBracket: *Token) *Node {}
    fn ArrayTypeStart(LBracket: *Token, Expr: *Node, RBracket: *Token) *Node {}

    fn PtrTypeStart(Asterisk: *Token) *Token { return arg1; }
    fn PtrTypeStart(AsteriskAsterisk: *Token) *Token { return arg1; }
    fn PtrTypeStart(BracketStarBracket: *Token) *Token { return arg1; }
    fn PtrTypeStart(BracketStarCBracket: *Token) *Token { return arg1; }

    fn PrimaryTypeExpr(Builtin: *Token, Identifier: *Token, FnCallArguments: *Node) *Node {}
    fn PrimaryTypeExpr(CharLiteral: *Token) *Node { return arg1; }
    fn PrimaryTypeExpr(ContainerDecl: *Node) *Node { return arg1; }
    fn PrimaryTypeExpr(Period: *Token, Identifier: *Token) *Node {}
    fn PrimaryTypeExpr(ErrorSetDecl: *Node) *Node { return arg1; }
    fn PrimaryTypeExpr(FloatLiteral: *Token) *Node {}
    fn PrimaryTypeExpr(FnProto: *Node) *Node { return arg1; }
    fn PrimaryTypeExpr(GroupedExpr: *Node) *Node { return arg1; }
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
    fn PrimaryTypeExpr(SwitchExpr: *Node) *Node { return arg1; }
    fn PrimaryTypeExpr(IfExpr: *Node) *Node { return arg1; }

    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclAuto: *Node) *Node {}

    fn ErrorSetDecl(Keyword_error: *Token, LBrace: *Token, RBrace: *Token) *Node {}
    fn ErrorSetDecl(Keyword_error: *Token, LBrace: *Token, Identifiers: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn Identifiers(Identifier: *Token) *Node {}
    fn Identifiers(Identifiers: *Node, Comma: *Token, Identifier: *Token) *Node {}

    // Initializer list
    fn InitList(LBrace: *Token, RBrace: *Token) *Node {}
    fn InitList(LBrace: *Token, FieldInits: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}
    fn InitList(LBrace: *Token, Exprs: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn FieldInits(FieldInit: *Node) *Node { return arg1; }
    fn FieldInits(FieldInits: *Node, Comma: *Token, FieldInit: *Node) *Node {}

    fn FieldInit(Period: *Token, Identifier: *Token, Equal: *Token, Expr: *Node) *Node {}

    // Operators
    fn AssignOp(AsteriskEqual: *Token) *Token { return arg1; }
    fn AssignOp(SlashEqual: *Token) *Token { return arg1; }
    fn AssignOp(PercentEqual: *Token) *Token { return arg1; }
    fn AssignOp(MinusEqual: *Token) *Token { return arg1; }
    fn AssignOp(AngleBracketAngleBracketLeftEqual: *Token) *Token { return arg1; }
    fn AssignOp(AngleBracketAngleBracketRightEqual: *Token) *Token { return arg1; }
    fn AssignOp(AmpersandEqual: *Token) *Token { return arg1; }
    fn AssignOp(CaretEqual: *Token) *Token { return arg1; }
    fn AssignOp(PipeEqual: *Token) *Token { return arg1; }
    fn AssignOp(AsteriskPercentEqual: *Token) *Token { return arg1; }
    fn AssignOp(PlusPercentEqual: *Token) *Token { return arg1; }
    fn AssignOp(MinusPercentEqual: *Token) *Token { return arg1; }
    fn AssignOp(Equal: *Token) *Token { return arg1; }

    fn CompareOp(EqualEqual: *Token) *Token { return arg1; }
    fn CompareOp(BangEqual: *Token) *Token { return arg1; }
    fn CompareOp(AngleBracketLeft: *Token) *Token { return arg1; }
    fn CompareOp(AngleBracketRight: *Token) *Token { return arg1; }
    fn CompareOp(AngleBracketLeftEqual: *Token) *Token { return arg1; }
    fn CompareOp(AngleBracketRightEqual: *Token) *Token { return arg1; }

    fn BitwiseOp(Ampersand: *Token) *Token { return arg1; }
    fn BitwiseOp(Caret: *Token) *Token { return arg1; }
    fn BitwiseOp(Keyword_orelse: *Token) *Token { return arg1; }
    // fn BitwiseOp(Keyword_catch: *Token) *Token { return arg1; }

    fn BitShiftOp(AngleBracketAngleBracketLeft: *Token) *Token { return arg1; }
    fn BitShiftOp(AngleBracketAngleBracketRight: *Token) *Token { return arg1; }

    fn AdditionOp(Plus: *Token) *Token { return arg1; }
    fn AdditionOp(Minus: *Token) *Token { return arg1; }
    fn AdditionOp(PlusPlus: *Token) *Token { return arg1; }
    fn AdditionOp(PlusPercent: *Token) *Token { return arg1; }
    fn AdditionOp(MinusPercent: *Token) *Token { return arg1; }

    fn MultiplyOp(PipePipe: *Token) *Token { return arg1; }
    fn MultiplyOp(Asterisk: *Token) *Token { return arg1; }
    fn MultiplyOp(Slash: *Token) *Token { return arg1; }
    fn MultiplyOp(Percent: *Token) *Token { return arg1; }
    fn MultiplyOp(AsteriskAsterisk: *Token) *Token { return arg1; }
    fn MultiplyOp(AsteriskPercent: *Token) *Token { return arg1; }

    fn PrefixOp(Bang: *Token) *Token { return arg1; }
    fn PrefixOp(Minus: Precedence_neg(*Token)) *Token { return arg1; }
    fn PrefixOp(Tilde: *Token) *Token { return arg1; }
    fn PrefixOp(MinusPercent: Precedence_neg(*Token)) *Token { return arg1; }
    fn PrefixOp(Ampersand: *Token) *Token { return arg1; }
    fn PrefixOp(Keyword_try: *Token) *Token { return arg1; }
    fn PrefixOp(Keyword_await: *Token) *Token { return arg1; }

    // Assembly
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, RParen: *Token) *Node {}
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, AsmOuput: *Node, RParen: *Token) *Node {}

    fn AsmOutput(Colon: *Token, AsmOutputItems: *Node) *Node {}
    fn AsmOutput(Colon: *Token, AsmOutputItems: *Node, AsmInput: *Node) *Node {}
    fn AsmOutput(Colon: *Token, AsmInput: *Node) *Node {}

    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Identifier: *Token, RParen: *Token) *Node {}
    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, MinusAngleBracketRight: *Token, TypeExpr: *Node, RParen: *Token) *Node {}

    fn AsmOutputItems(AsmOutputItem: *Node) *Node { return arg1; }
    fn AsmOutputItems(AsmOutputItems: *Node, Comma: *Token, AsmOutputItem: *Node) *Node {}

    fn AsmInput(Colon: *Token, AsmInputItems: *Node) *Node {}
    fn AsmInput(Colon: *Token, AsmInputItems: *Node, AsmClobber: *Node) *Node {}
    fn AsmInput(Colon: *Token, AsmClobber: *Node) *Node {}

    fn AsmInputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn AsmInputItems(AsmInputItem: *Node) *Node { return arg1; }
    fn AsmInputItems(AsmInputItems: *Node, Comma: *Token, AsmInputItem: *Node) *Node {}

    fn AsmClobber(Colon: *Token) *Node {}
    fn AsmClobber(Colon: *Token, Strings: *Node) *Node {}

    fn Strings(StringLiteral: *Token) *Node {}
    fn Strings(Strings: *Node, Comma: *Token, StringLiteral: *Token) *Node {}

    // Switch
    fn Switch(Keyword_switch: *Token, LParen: *Token, Expr: *Node, RParen: *Token, LBrace: *Token, SwitchProngs: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn SwitchProngs(SwitchProng: *Node) *Node { return arg1; }
    fn SwitchProngs(SwitchProngs: *Node, Comma: *Token, SwitchProng: *Node) *Node {}

    fn SwitchProng(SwitchCase: *Node, EqualAngleBracketRight: *Token, MaybePtrPayload: ?*Node, Expr: *Node) *Node {}

    fn SwitchCase(Keyword_else: *Token) *Node {}
    fn SwitchCase(SwitchItems: *Node, MaybeComma: ?*Token) *Node {}

    fn SwitchItems(SwitchItem: *Node) *Node { return arg1; }
    fn SwitchItems(SwitchItems: *Node, Comma: *Token, SwitchItem: *Node) *Node {}

    fn SwitchItem(Expr: *Node) *Node { return arg1; }
    fn SwitchItem(Expr: *Node, Ellipsis3: *Token, Expr: *Node) *Node {}

    // Maybe helpers
    fn MaybePub() ?*Token { return null; }
    fn MaybePub(Keyword_pub: *Token) ?*Token { return arg1; }

    fn MaybeColonTypeExpr() ?*Node { return null; }
    fn MaybeColonTypeExpr(Colon: *Token, TypeExpr: *Node) ?*Node {}

    fn MaybeEqualExpr() ?*Node { return null; }
    fn MaybeEqualExpr(Equal: *Token, RExpr: *Node) ?*Node {}

    fn MaybeBang() ?*Token { return null; }
    fn MaybeBang(Bang: *Token) ?*Token { return arg1; }

    fn MaybeNoaliasComptime() ?*Token { return null; }
    fn MaybeNoaliasComptime(Keyword_noalias: *Token) ?*Token { return arg1; }
    fn MaybeNoaliasComptime(Keyword_comptime: *Token) ?*Token { return arg1; }

    fn MaybeInline() ?*Token { return null; }
    fn MaybeInline(Inline: *Token) ?*Token { return arg1; }

    fn MaybeComma() ?*Token { return null; }
    fn MaybeComma(Comma: *Token) ?*Token { return arg1; }

    fn MaybeConst() ?*Token { return null; }
    fn MaybeConst(Keyword_const: *Token) ?*Token { return arg1; }

    fn MaybeVolatile() ?*Token { return null; }
    fn MaybeVolatile(Keyword_volatile: *Token) ?*Token { return arg1; }

    fn MaybeAllowzero() ?*Token { return null; }
    fn MaybeAllowzero(Keyword_allowzero: *Token) ?*Token { return arg1; }

    fn MaybeExternPacked() ?*Token { return null; }
    fn MaybeExternPacked(Keyword_extern: *Token) ?*Token { return arg1; }
    fn MaybeExternPacked(Keyword_packed: *Token) ?*Token { return arg1; }
};
