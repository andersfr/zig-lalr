pub extern "LALR" const ZigGrammar = struct {
    fn Root(ContainerMembers: *Node) ?*Node {}

    // Containers
    fn ContainerMembers(ContainerMembers: *Node, ContainerMember: *Node) *Node {}
    fn ContainerMembers(ContainerMembers: *Node, ContainerMemberWithDocComment: *Node) *Node {}
    fn ContainerMembers(ContainerMember: *Node) *Node {}
    fn ContainerMembers(ContainerMemberWithDocComment: *Node) *Node {}

    fn ContainerMemberWithDocComment(DocCommentLines: *Node, ContainerMember: *Node) *Node {}

    fn ContainerMember(TestDecl: *Node) *Node {}
    fn ContainerMember(TopLevelComptime: *Node) *Node {}
    fn ContainerMember(MaybePub: ?*Token, TopLevelDecl: *Node) *Node {}
    fn ContainerMember(MaybePub: ?*Token, ContainerFields: *Node, Semicolon: *Token) *Node {}

    fn ContainerFields(ContainerField: *Node) *Node {}
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
    fn MaybeExternPackage() ?*Node {}
    fn MaybeExternPackage(Keyword_extern: *Token, StringLiteral: *Token) ?*Node {}

    fn MaybeExportExtern() ?*Token {}
    fn MaybeExportExtern(Keyword_export: *Token) ?*Token {}
    fn MaybeExportExtern(Keyword_extern: *Token) ?*Token {}

    fn MaybeExportInline() ?*Token {}
    fn MaybeExportInline(Keyword_export: *Token) ?*Token {}
    fn MaybeExportInline(Keyword_inline: *Token) ?*Token {}

    fn MaybeThreadlocal() ?*Token {}
    fn MaybeThreadlocal(Keyword_threadlocal: *Token) ?*Token {}

    // Variables
    fn VarDecl(Keyword_const: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}
    fn VarDecl(Keyword_var: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}

    // Functions
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: *Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, Keyword_var: *Token) *Node {}
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, TypeExpr: *Node) *Node {}
    fn FnProto(AsyncPrefix: *Node, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, Keyword_var: *Token) *Node {}
    fn FnProto(AsyncPrefix: *Node, Keyword_fn: *Token, MaybeIdentifier: ?*Token, ParamDeclList: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, TypeExpr: *Node) *Node {}

    // Function call conventions
    fn MaybeFnCC() ?*Token {}
    fn MaybeFnCC(Keyword_nakedcc: *Token) ?*Token {}
    fn MaybeFnCC(Keyword_stdcallcc: *Token) ?*Token {}
    fn MaybeFnCC(Keyword_extern: *Token) ?*Token {}

    fn AsyncPrefix(Keyword_async: *Token) *Node {}
    fn AsyncPrefix(Keyword_async: *Token, AngleBracketLeft: *Token, PrefixExpr: *Node, AngleBracketRight: *Token) *Node {}

    // Parameters
    fn ParamDeclList(LParen: *Token, RParen: *Token) *Node {}
    fn ParamDeclList(LParen: *Token, ParamDecls: *Node, RParen: *Token) *Node {}

    fn ParamDecls(ParamDecl: *Node) *Node {}
    fn ParamDecls(ParamDecls: *Node, Comma: *Token, ParamDecl: *Node) *Node {}

    fn ParamDecl(MaybeNoaliasComptime: ?*Token, ParamType: *Node) *Node {}
    fn ParamDecl(MaybeNoaliasComptime: ?*Token, Identifer: *Token, Colon: *Token, ParamType: *Node) *Node {}

    fn ParamType(Keyword_var: *Token) *Node {}
    fn ParamType(Keyword_ellipsis3: *Token) *Node {}
    fn ParamType(TypeExpr: *Node) *Node {}

    // Declaration post modifiers
    fn MaybeByteAlign() ?*Node {}
    fn MaybeByteAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    fn MaybeLinkSection() ?*Node {}
    fn MaybeLinkSection(Keyword_linksection: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    // Blocks
    fn Block(LBrace: *Token, RBrace: *Token) *Node {}
    fn Block(LBrace: *Token, Statements: *Node, RBrace: *Token) *Node {}

    fn BlockLabel(Identifier: *Token, Colon: *Token) *Token {}
    fn BreakLabel(Colon: *Token, Identifier: *Token) *Token {}

    fn BlockExpr(Block: *Node) *Node {}
    fn BlockExpr(BlockLabel: *Token, Block: *Node) *Node {}

    fn BlockExprStatement(BlockExpr: *Node) *Node {}
    fn BlockExprStatement(NestedStatement: *Node, Semicolon: *Token) *Node {}

    // Statements
    fn Statements(Statement: *Node) *Node {}
    fn Statements(Statements: *Node, Statement: *Node) *Node {}

    fn Statement(VarDecl: *Node) *Node {}
    fn Statement(Keyword_comptime: *Token, VarDecl: *Node) *Node {}
    fn Statement(Keyword_comptime: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_defer: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_errdefer: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_suspend: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_suspend: *Token, Semicolon: *Token) *Node {}
    fn Statement(BlockExpr: *Node) *Node {}
    fn Statement(NestedStatement: *Node) *Node {}

    fn NestedStatement(SwitchExpr: *Node) *Node {}
    fn NestedStatement(IfStatement: *Node) *Node {}
    fn NestedStatement(LoopStatement: *Node) *Node {}
    fn NestedStatement(LabeledLoopStatement: *Node) *Node {}
    fn NestedStatement(AssignExpr: *Node, Semicolon: *Token) *Node {}

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
    fn MaybePayload() ?*Node {}
    fn MaybePayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    fn MaybePtrPayload() ?*Node {}
    fn MaybePtrPayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn MaybePtrPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    fn PtrIndexPayload(Pipe: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Identifier: *Token, Comma: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}
    fn PtrIndexPayload(Pipe: *Token, Asterisk: *Token, Identifier: *Token, Comma: *Token, Identifier: *Token, Pipe: *Token) ?*Node {}

    // Expressions
    fn AssignExpr(LExpr: *Node, AssignOp: *Token, Expr: *Node) *Node {}

    fn LExpr(Identifier: *Token) *Node {}
    fn LExpr(Identifier: *Token, SuffixOps: *Node) *Node {}

    fn Exprs(Expr: *Node) *Node {}
    fn Exprs(Exprs: *Node, Comma: *Token, Expr: *Node) *Node {}

    fn Expr(PrefixExpr: *Node) *Node {}
    fn Expr(Expr: *Node, CompareOp: *Token, Expr: *Node) *Node {}
    fn Expr(Expr: *Node, BitwiseOp: *Token, Expr: *Node) *Node {}
    fn Expr(Expr: *Node, BitshiftOp: *Token, Expr: *Node) *Node {}
    fn Expr(Expr: *Node, AdditionOp: *Token, Expr: *Node) *Node {}
    fn Expr(Expr: *Node, MultiplyOp: *Token, Expr: *Node) *Node {}

    fn GroupedExpr(LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn PrefixExpr(PrimaryExpr: *Node) *Node {}
    fn PrefixExpr(PrefixOp: *Token, PrefixExpr: *Node) *Node {}

    fn PrimaryExpr(Keyword_comptime: *Token, Expr: *Node) *Node {}
    fn PrimaryExpr(AsmExpr: *Node) *Node {}
    fn PrimaryExpr(BlockExpr: *Node) *Node {}
    fn PrimaryExpr(TypeExpr: *Node) *Node {}
    fn PrimaryExpr(TypeExpr: *Node, InitList: *Node) *Node {}

    // Type expressions
    fn TypeExpr(PrefixTypeOps: *Node, ErrorUnionExpr: *Node) *Node {}

    fn ErrorUnionExpr(SuffixExpr: *Node) *Node {}
    fn ErrorUnionExpr(SuffixExpr: *Node, Bang: *Token, TypeExpr: *Node) *Node {}

    fn PrefixTypeOps(PrefixTypeOp: *Node) *Node {}
    fn PrefixTypeOps(PrefixTypeOps: *Node, PrefixTypeOp: *Node) *Node {}

    fn PrefixTypeOp(QuestionMark: *Token) *Node {}
    fn PrefixTypeOp(Keyword_promise: *Token, MinusAngleBracketRight: *Token) *Node {}
    fn PrefixTypeOp(ArrayTypeStart: *Node, MaybeByteAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token) *Node {}
    fn PrefixTypeOp(PtrTypeStart: *Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token, MaybeAllowzero: ?*Token) *Node {}

    fn SuffixExpr(AsyncPrefix: *Node, PrimaryTypeExpr: *Node, FnCallArguments: *Node) *Node {}
    fn SuffixExpr(AsyncPrefix: *Node, PrimaryTypeExpr: *Node, SuffixOps: *Node, FnCallArguments: *Node) *Node {}
    fn SuffixExpr(PrimaryTypeExpr: *Node) *Node {}
    fn SuffixExpr(PrimaryTypeExpr: *Node, SuffixOps: *Node) *Node {}
    fn SuffixExpr(PrimaryTypeExpr: *Node, FnCallArguments: *Node) *Node {}

    fn SuffixOps(SuffixOp: *Node) *Node {}
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

    fn PtrTypeStart(Asterisk: *Token) *Token {}
    fn PtrTypeStart(AsteriskAsterisk: *Token) *Token {}
    fn PtrTypeStart(BracketStarBracket: *Token) *Token {}
    fn PtrTypeStart(BracketStarCBracket: *Token) *Token {}

    fn PrimaryTypeExpr(Builtin: *Token, Identifier: *Token, FnCallArguments: *Node) *Node {}
    fn PrimaryTypeExpr(CharLiteral: *Token) *Node {}
    fn PrimaryTypeExpr(ContainerDecl: *Node) *Node {}
    fn PrimaryTypeExpr(Period: *Token, Identifier: *Token) *Node {}
    fn PrimaryTypeExpr(ErrorSetDecl: *Node) *Node {}
    fn PrimaryTypeExpr(FloatLiteral: *Token) *Node {}
    fn PrimaryTypeExpr(FnProto: *Node) *Node {}
    fn PrimaryTypeExpr(GroupedExpr: *Node) *Node {}
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
    fn PrimaryTypeExpr(SwitchExpr: *Node) *Node {}

    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclAuto: *Node) *Node {}

    fn ErrorSetDecl(Keyword_error: *Token, LBrace: *Token, RBrace: *Token) *Node {}
    fn ErrorSetDecl(Keyword_error: *Token, LBrace: *Token, Identifiers: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn Identifiers(Identifier: *Token) *Node {}
    fn Identifiers(Identifiers: *Node, Comma: *Token, Identifier: *Token) *Node {}

    // Initializer list
    fn InitList(LBrace: *Token, RBrace: *Token) *Node {}
    fn InitList(LBrace: *Token, FieldInits: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}
    fn InitList(LBrace: *Token, Exprs: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn FieldInits(FieldInit: *Node) *Node {}
    fn FieldInits(FieldInits: *Node, Comma: *Token, FieldInit: *Node) *Node {}

    fn FieldInit(Period: *Token, Identifier: *Token, Equal: *Token, Expr: *Node) *Node {}

    // Operators
    fn AssignOp(AsteriskEqual: *Token) *Token {}
    fn AssignOp(SlashEqual: *Token) *Token {}
    fn AssignOp(PercentEqual: *Token) *Token {}
    fn AssignOp(MinusEqual: *Token) *Token {}
    fn AssignOp(AngleBracketAngleBracketLeftEqual: *Token) *Token {}
    fn AssignOp(AngleBracketAngleBracketRightEqual: *Token) *Token {}
    fn AssignOp(AmpersandEqual: *Token) *Token {}
    fn AssignOp(CaretEqual: *Token) *Token {}
    fn AssignOp(PipeEqual: *Token) *Token {}
    fn AssignOp(AsteriskPercentEqual: *Token) *Token {}
    fn AssignOp(PlusPercentEqual: *Token) *Token {}
    fn AssignOp(MinusPercentEqual: *Token) *Token {}
    fn AssignOp(Equal: *Token) *Token {}

    fn CompareOp(EqualEqual: *Token) *Token {}
    fn CompareOp(BangEqual: *Token) *Token {}
    fn CompareOp(AngleBracketLeft: *Token) *Token {}
    fn CompareOp(AngleBracketRight: *Token) *Token {}
    fn CompareOp(AngleBracketLeftEqual: *Token) *Token {}
    fn CompareOp(AngleBracketRightEqual: *Token) *Token {}

    fn BitwiseOp(Ampersand: *Token) *Token {}
    fn BitwiseOp(Caret: *Token) *Token {}
    fn BitwiseOp(Keyword_orelse: *Token) *Token {}
    fn BitwiseOp(Keyword_catch: *Token) *Token {}

    fn BitShiftOp(AngleBracketAngleBracketLeft: *Token) *Token {}
    fn BitShiftOp(AngleBracketAngleBracketRight: *Token) *Token {}

    fn AdditionOp(Plus: *Token) *Token {}
    fn AdditionOp(Minus: *Token) *Token {}
    fn AdditionOp(PlusPlus: *Token) *Token {}
    fn AdditionOp(PlusPercent: *Token) *Token {}
    fn AdditionOp(MinusPercent: *Token) *Token {}

    fn MultiplyOp(PipePipe: *Token) *Token {}
    fn MultiplyOp(Asterisk: *Token) *Token {}
    fn MultiplyOp(Slash: *Token) *Token {}
    fn MultiplyOp(Percent: *Token) *Token {}
    fn MultiplyOp(AsteriskAsterisk: *Token) *Token {}
    fn MultiplyOp(AsteriskPercent: *Token) *Token {}

    fn PrefixOp(Bang: *Token) *Token {}
    fn PrefixOp(Minus: Precedence_neg(*Token)) *Token {}
    fn PrefixOp(Tilde: *Token) *Token {}
    fn PrefixOp(MinusPercent: Precedence_neg(*Token)) *Token {}
    fn PrefixOp(Ampersand: *Token) *Token {}
    fn PrefixOp(Keyword_try: *Token) *Token {}
    fn PrefixOp(Keyword_await: *Token) *Token {}

    // Assembly
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, RParen: *Token) *Node {}
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, AsmOuput: *Node, RParen: *Token) *Node {}

    fn AsmOutput(Colon: *Token, AsmOutputItems: *Node) *Node {}
    fn AsmOutput(Colon: *Token, AsmOutputItems: *Node, AsmInput: *Node) *Node {}
    fn AsmOutput(Colon: *Token, AsmInput: *Node) *Node {}

    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Identifier: *Token, RParen: *Token) *Node {}
    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, MinusAngleBracketRight: *Token, TypeExpr: *Node, RParen: *Token) *Node {}

    fn AsmOutputItems(AsmOutputItem: *Node) *Node {}
    fn AsmOutputItems(AsmOutputItems: *Node, Comma: *Token, AsmOutputItem: *Node) *Node {}

    fn AsmInput(Colon: *Token, AsmInputItems: *Node) *Node {}
    fn AsmInput(Colon: *Token, AsmInputItems: *Node, AsmClobber: *Node) *Node {}
    fn AsmInput(Colon: *Token, AsmClobber: *Node) *Node {}

    fn AsmInputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn AsmInputItems(AsmInputItem: *Node) *Node {}
    fn AsmInputItems(AsmInputItems: *Node, Comma: *Token, AsmInputItem: *Node) *Node {}

    fn AsmClobber(Colon: *Token) *Node {}
    fn AsmClobber(Colon: *Token, Strings: *Node) *Node {}

    fn Strings(StringLiteral: *Token) *Node {}
    fn Strings(Strings: *Node, Comma: *Token, StringLiteral: *Token) *Node {}

    // Switch
    fn Switch(Keyword_switch: *Token, LParen: *Token, Expr: *Node, RParen: *Token, LBrace: *Token, SwitchProngs: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn SwitchProngs(SwitchProng: *Node) *Node {}
    fn SwitchProngs(SwitchProngs: *Node, Comma: *Token, SwitchProng: *Node) *Node {}

    fn SwitchProng(SwitchCase: *Node, EqualAngleBracketRight: *Token, MaybePtrPayload: ?*Node, Expr: *Node) *Node {}

    fn SwitchCase(Keyword_else: *Token) *Node {}
    fn SwitchCase(SwitchItems: *Node, MaybeComma: ?*Token) *Node {}

    fn SwitchItems(SwitchItem: *Node) *Node {}
    fn SwitchItems(SwitchItems: *Node, Comma: *Token, SwitchItem: *Node) *Node {}

    fn SwitchItem(Expr: *Node) *Node {}
    fn SwitchItem(Expr: *Node, Ellipsis3: *Token, Expr: *Node) *Node {}

    // Maybe helpers
    fn MaybePub() ?*Token {}
    fn MaybePub(Keyword_pub: *Token) ?*Token {}

    fn MaybeColonTypeExpr() ?*Node {}
    fn MaybeColonTypeExpr(Colon: *Token, TypeExpr: *Node) ?*Node {}

    fn MaybeEqualExpr() ?*Node {}
    fn MaybeEqualExpr(Equal: *Token, Expr: *Node) ?*Node {}

    fn MaybeBang() ?*Token {}
    fn MaybeBang(Bang: *Token) ?*Token {}

    fn MaybeNoaliasComptime() ?*Token {}
    fn MaybeNoaliasComptime(Keyword_noalias: *Token) ?*Token {}
    fn MaybeNoaliasComptime(Keyword_comptime: *Token) ?*Token {}

    fn MaybeInline() ?*Token {}
    fn MaybeInline(Inline: *Token) ?*Token {}

    fn MaybeComma() ?*Token {}
    fn MaybeComma(Comma: *Token) ?*Token {}

    fn MaybeConst() ?*Token {}
    fn MaybeConst(Keyword_const: *Token) ?*Token {}

    fn MaybeVolatile() ?*Token {}
    fn MaybeVolatile(Keyword_volatile: *Token) ?*Token {}

    fn MaybeAllowzero() ?*Token {}
    fn MaybeAllowzero(Keyword_allowzero: *Token) ?*Token {}

    fn MaybeExternPacked() ?*Token {}
    fn MaybeExternPacked(Keyword_extern: *Token) ?*Token {}
    fn MaybeExternPacked(Keyword_packed: *Token) ?*Token {}
};
