pub extern "LALR" const zig_grammar = struct {
    fn Root(MaybeContainerMembers: ?*NodeList) *Node { result = @ptrCast(?*Node, arg1).?; }

    // DocComments
    fn ContainerMemberWithDocComment(DocCommentLines: *Node, ContainerMember: *Node) *Node {}
    fn DocCommentLines(DocCommentLines: *NodeList, DocComment: *Token) *NodeList {}
    fn DocCommentLines(DocComment: *Token) *NodeList {}

    // Containers
    fn MaybeContainerMembers() ?*NodeList {}
    fn MaybeContainerMembers(ContainerMembers: *NodeList) ?*NodeList {}
    // Note: these exist to allow a trailing container field without comma
    fn MaybeContainerMembers(MaybePub: ?*Token, ContainerField: *Node) *Node {}
    fn MaybeContainerMembers(DocCommentLines: *NodeList, MaybePub: ?*Token, ContainerField: *Node) *Node {}
    fn MaybeContainerMembers(ContainerMembers: *NodeList, MaybePub: ?*Token, ContainerField: *Node) *Node {}
    fn MaybeContainerMembers(ContainerMembers: *NodeList, DocCommentLines: *NodeList, MaybePub: ?*Token, ContainerField: *Node) *Node {}

    fn ContainerMembers(ContainerMembers: *NodeList, ContainerMember: *Node) *NodeList {}
    fn ContainerMembers(ContainerMembers: *NodeList, ContainerMemberWithDocComment: *Node) *NodeList {}
    fn ContainerMembers(ContainerMember: *Node) *NodeList {}
    fn ContainerMembers(ContainerMemberWithDocComment: *Node) *NodeList {}

    fn ContainerMember(TestDecl: *Node) *Node {}
    fn ContainerMember(TopLevelComptime: *Node) *Node {}
    fn ContainerMember(MaybePub: ?*Token, TopLevelDecl: *Node) *Node {}
    fn ContainerMember(MaybePub: ?*Token, ContainerField: *Node, Comma: *Token) *Node {}

    // Test
    fn TestDecl(Keyword_test: *Token, StringLiteral: *Token, Block: *Node) *Node {}

    // Comptime
    fn TopLevelComptime(Keyword_comptime: *Token, BlockExpr: *Node) *Node {}

    // TopLevel declarations
    fn TopLevelDecl(MaybeExternPackage: ?*Node, FnProto: *Node, SemicolonOrBlock: ?*Node) *Node {}
    fn TopLevelDecl(MaybeExportInline: ?*Token, FnProto: *Node, SemicolonOrBlock: ?*Node) *Node {}
    fn TopLevelDecl(MaybeExternPackage: ?*Node, MaybeThreadlocal: ?*Token, VarDecl: *Node) *Node {}
    fn TopLevelDecl(MaybeExportExtern: ?*Token, MaybeThreadlocal: ?*Token, VarDecl: *Node) *Node {}
    fn TopLevelDecl(Keyword_usingnamespace: *Token, Expr: *Node, Semicolon: *Token) *Node {}
    // TODO: Keyword_use is deprecated
    fn TopLevelDecl(Keyword_use: *Token, Expr: *Node, Semicolon: *Token) *Node {}

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

    // Functions
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, LParen: *Token, MaybeParamDeclList: ?*Node, RParen: *Token, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, Keyword_var: *Token) *Node {}
    fn FnProto(MaybeFnCC: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, LParen: *Token, MaybeParamDeclList: ?*Node, RParen: *Token, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, TypeExpr: *Node) *Node {}
    fn FnProto(AsyncPrefix: *Node, Keyword_fn: *Token, MaybeIdentifier: ?*Token, LParen: *Token, MaybeParamDeclList: ?*Node, RParen: *Token, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, Keyword_var: *Token) *Node {}
    fn FnProto(AsyncPrefix: *Node, Keyword_fn: *Token, MaybeIdentifier: ?*Token, LParen: *Token, MaybeParamDeclList: ?*Node, RParen: *Token, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, TypeExpr: *Node) *Node {}

    // Variables
    fn VarDecl(Keyword_const: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}
    fn VarDecl(Keyword_var: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}

    // Container field
    fn ContainerField(Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeEqualExpr: ?*Node) *Node {}

    // Statements
    fn MaybeStatements() ?*NodeList {}
    fn MaybeStatements(Statements: *Node) ?*NodeList {}

    fn Statements(Statement: *Node) *NodeList {}
    fn Statements(Statements: *NodeList, Statement: *Node) *NodeList {}

    fn Statement(Keyword_comptime: *Token, VarDecl: *Node) *Node {}
    fn Statement(VarDecl: *Node) *Node {}
    fn Statement(Keyword_comptime: *Token, BlockExpr: *Node) *Node {}
    fn Statement(Keyword_suspend: *Token, Semicolon: *Token) *Node {}
    fn Statement(Keyword_suspend: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_defer: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(Keyword_errdefer: *Token, BlockExprStatement: *Node) *Node {}
    fn Statement(IfStatement: *Node) *Node {}
    fn Statement(LabeledStatement: *Node) *Node {}
    fn Statement(SwitchExpr: *Node) *Node {}
    fn Statement(BlockExprStatement: *Node) *Node {}
    // fn Statement(AssignExpr: *Node, Semicolon: *Token) *Node {}

    fn IfStatement(IfPrefix: *Node, BlockExpr: *Node) *Node {}
    fn IfStatement(IfPrefix: *Node, BlockExpr: *Node, ElseStatement: *Node) *Node {}
    fn IfStatement(IfPrefix: *Node, AssignExpr: *Node, Semicolon: *Token) *Node {}
    fn IfStatement(IfPrefix: *Node, AssignExpr: *Node, ElseStatement: *Node) *Node {}
    fn ElseStatement(Keyword_else: *Token, MaybePayload: ?*Node, Statement: *Node) *Node {}

    fn LabeledStatement(LoopStatement: *Node) *Node {}
    fn LabeledStatement(BlockLabel: *Token, LoopStatement: *Node) *Node {}
    // fn LabeledStatement(BlockExpr: *Node) *Node {}

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

    fn BlockExprStatement(BlockExpr: *Node) *Node {}
    fn BlockExprStatement(AssignExpr: *Node, Semicolon: *Token) *Node {}

    fn BlockExpr(Block: *Node) *Node {}
    fn BlockExpr(BlockLabel: *Token, Block: *Node) *Node {}

    // Expression level
    fn AssignExpr(TypeExpr: *Node, AssignOp: *Token, Expr: *Node) *Node {}
    fn AssignExpr(Expr: *Node) *Node {}

    fn MaybeEqualExpr() ?*Node {}
    fn MaybeEqualExpr(Equal: *Token, Expr: *Node) ?*Node {}

    // Note: this should be deprecated
    // fn Expr(Keyword_try: *Token, BoolOrExpr: *Node) *Node {}
    fn Expr(BoolOrExpr: *Node) *Node {}

    fn BoolOrExpr(BoolAndExpr: *Node) *Node {}
    fn BoolOrExpr(BoolOrExpr: *Node, Keyword_or: *Token, BoolAndExpr: *Node) *Node {}
    
    fn BoolAndExpr(BoolCompareExpr: *Node) *Node {}
    fn BoolAndExpr(BoolAndExpr: *Node, Keyword_and: *Token, BoolCompareExpr: *Node) *Node {}

    fn BoolCompareExpr(BitwiseExpr: *Node) *Node {}
    fn BoolCompareExpr(BoolCompareExpr: *Node, CompareOp: *Token, BitwiseExpr: *Node) *Node {}

    fn BitwiseExpr(BitShiftExpr: *Node) *Node {}
    fn BitwiseExpr(BitwiseExpr: *Node, BitwiseOp: *Token, BitShiftExpr: *Node) *Node {}
    fn BitwiseExpr(BitwiseExpr: *Node, Keyword_catch: *Token, MaybePayload: ?*Node, BitShiftExpr: *Node) *Node {}

    fn BitShiftExpr(AdditionExpr: *Node) *Node {}
    fn BitShiftExpr(BitShiftExpr: *Node, BitShiftOp: *Token, AdditionExpr: *Node) *Node {}

    fn AdditionExpr(MultiplyExpr: *Node) *Node {}
    fn AdditionExpr(AdditionExpr: *Node, AdditionOp: *Token, MultiplyExpr: *Node) *Node {}

    fn MultiplyExpr(PrefixExpr: *Node) *Node {}
    fn MultiplyExpr(MultiplyExpr: *Node, MultiplyOp: *Token, PrefixExpr: *Node) *Node {}

    fn PrefixExpr(PrefixOp: *Token, PrefixExpr: *Node) *Node {}
    fn PrefixExpr(PrimaryExpr: *Node) *Node {}

    fn PrimaryExpr(AsmExpr: *Node) *Node {}
    fn PrimaryExpr(Keyword_resume: *Token, Expr: *Node) *Node {}
    fn PrimaryExpr(Keyword_cancel: *Token, Expr: *Node) *Node {}
    fn PrimaryExpr(Keyword_break: *Token) *Node {}
    fn PrimaryExpr(Keyword_break: *Token, BreakLabel: *Token) *Node {}
    fn PrimaryExpr(Keyword_break: *Token, Expr: *Node) *Node {}
    fn PrimaryExpr(Keyword_break: *Token, BreakLabel: *Token, Expr: *Node) *Node {}
    fn PrimaryExpr(Keyword_continue: *Token) *Node {}
    fn PrimaryExpr(Keyword_continue: *Token, BreakLabel: *Token) *Node {}
    fn PrimaryExpr(Keyword_return: *Token) *Node {}
    fn PrimaryExpr(Keyword_return: *Token, Expr: *Node) *Node {}
    // Note: IfExpr and IfTypeExpr are combined to avoid conflicts
    // fn PrimaryExpr(IfExpr: *Node) *Node {}
    // fn PrimaryExpr(Keyword_comptime: *Token, Expr: *Node) *Node {}
    // Note: this makes no sense as TypeExpr already implements BlockExpr
    // fn PrimaryExpr(Block: *Node) *Node {}
    // fn PrimaryExpr(LoopExpr: *Node) *Node {}
    // fn PrimaryExpr(BlockLabel: *Token, LoopExpr: *Node) *Node {}
    fn PrimaryExpr(CurlySuffixExpr: *Node) *Node {}

    fn IfExpr(IfPrefix: *Node, Expr: *Node) *Node {}
    fn IfExpr(IfPrefix: *Node, Expr: *Node, ElseExpr: *Node) *Node {}
    fn ElseExpr(Keyword_else: *Token, MaybePayload: *Node, Expr: *Node) *Node {}

    fn Block(LBrace: *Token, MaybeStatements: ?*Node, RBrace: *Token) *Node {}

    // Note: LoopExpr should be deprecated

    fn CurlySuffixExpr(TypeExpr: *Node) *Node {}
    fn CurlySuffixExpr(TypeExpr: *Node, InitList: *Node) *Node {}

    // Initializer list
    fn InitList(LBrace: *Token, RBrace: *Token) *Node {}
    fn InitList(LBrace: *Token, FieldInits: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {}
    fn InitList(LBrace: *Token, ExprList: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn TypeExpr(PrefixTypeOps: *Node, ErrorUnionExpr: *Node) *Node {}
    fn TypeExpr(ErrorUnionExpr: *Node) *Node {}

    fn ErrorUnionExpr(SuffixExpr: *Node) *Node {}
    fn ErrorUnionExpr(SuffixExpr: *Node, Bang: *Token, TypeExpr: *Node) *Node {}

    fn SuffixExpr(AsyncPrefix: *Node, PrimaryTypeExpr: *Node, FnCallArguments: *Node) *Node {}
    fn SuffixExpr(AsyncPrefix: *Node, PrimaryTypeExpr: *Node, SuffixOps: *NodeList, FnCallArguments: *Node) *Node {}
    fn SuffixExpr(PrimaryTypeExpr: *Node) *Node {}
    fn SuffixExpr(PrimaryTypeExpr: *Node, SuffixOpsEx: *NodeList) *Node {}

    fn PrimaryTypeExpr(Builtin: *Token, Identifier: *Token, FnCallArguments: *Node) *Node {}
    fn PrimaryTypeExpr(CharLiteral: *Token) *Node {}
    fn PrimaryTypeExpr(ContainerDecl: *Node) *Node {}
    fn PrimaryTypeExpr(Period: *Token, Identifier: *Token) *Node {}
    fn PrimaryTypeExpr(ErrorSetDecl: *Node) *Node {}
    fn PrimaryTypeExpr(FloatLiteral: *Token) *Node {}
    fn PrimaryTypeExpr(FnProto: *Node) *Node {}
    fn PrimaryTypeExpr(GroupedExpr: *Node) *Node {}
    // Note: LabeledTypeExpr should be replaced with BlockExpr
    fn PrimaryTypeExpr(BlockExpr: Shadow(*Node)) *Node {}
    fn PrimaryTypeExpr(Identifier: *Token) *Node {}
    // Note: IfExpr and IfTypeExpr were combined to avoid conflicts
    fn PrimaryTypeExpr(IfExpr: *Node) *Node {}
    fn PrimaryTypeExpr(IntegerLiteral: *Token) *Node {}
    // fn PrimaryTypeExpr(Keyword_comptime: *Token, TypeExpr: *Node) *Node {}
    fn PrimaryTypeExpr(Keyword_comptime: *Token, Expr: *Node) *Node {}
    fn PrimaryTypeExpr(Keyword_error: *Token, Period: *Token, Identifier: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_false: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_null: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_promise: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_true: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_undefined: *Token) *Node {}
    fn PrimaryTypeExpr(Keyword_unreachable: *Token) *Node {}
    fn PrimaryTypeExpr(StringLiteral: *Token) *Node {}
    fn PrimaryTypeExpr(MultilineStringLiteral: *NodeList) *Node {}
    fn PrimaryTypeExpr(MultilineCStringLiteral: *NodeList) *Node {}
    fn PrimaryTypeExpr(SwitchExpr: Shadow(*Node)) *Node {}

    // Note: ContainerDeclAuto has been inlined
    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclOp: *Token, LBrace: *Token, MaybeContainerMembers: ?*NodeList, RBrace: *Token) *Node {}
    fn ContainerDecl(MaybeExternPacked: ?*Token, ContainerDeclType: *Node, LBrace: *Token, MaybeContainerMembers: ?*NodeList, RBrace: *Token) *Node {}

    // ContainerDecl helper
    fn MaybeExternPacked() ?*Token {}
    fn MaybeExternPacked(Keyword_extern: *Token) ?*Token {}
    fn MaybeExternPacked(Keyword_packed: *Token) ?*Token {}

    fn ErrorSetDecl(Keyword_error: *Token, LBrace: *Token, RBrace: *Token) *Node {}
    fn ErrorSetDecl(Keyword_error: *Token, LBrace: *Token, IdentifierList: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn GroupedExpr(LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    // Note: LabeledTypeExpr has been deprecated

    fn SwitchExpr(Keyword_switch: *Token, LParen: *Token, Expr: *Node, RParen: *Token, LBrace: *Token, SwitchProngList: *NodeList, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    // Assembly
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, RParen: *Token) *Node {}
    fn AsmExpr(Keyword_asm: *Token, MaybeVolatile: ?*Token, LParen: *Token, StringLiteral: *Token, AsmOutput: *Node, RParen: *Token) *Node {}

    fn AsmOutput(Colon: *Token, AsmOutputList: *NodeList) *Node {}
    fn AsmOutput(Colon: *Token, AsmOutputList: *NodeList, AsmInput: *Node) *Node {}
    fn AsmOutput(Colon: *Token, AsmInput: *Node) *Node {}

    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Identifier: *Token, RParen: *Token) *Node {}
    fn AsmOutputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, MinusAngleBracketRight: *Token, TypeExpr: *Node, RParen: *Token) *Node {}

    fn AsmInput(Colon: *Token, AsmInputList: *NodeList) *Node {}
    fn AsmInput(Colon: *Token, AsmInputList: *NodeList, AsmClobber: *Node) *Node {}
    fn AsmInput(Colon: *Token, AsmClobber: *Node) *Node {}

    fn AsmInputItem(LBracket: *Token, Identifier: *Token, RBracket: *Token, StringLiteral: *Token, LParen: *Token, Expr: *Node, RParen: *Token) *Node {}

    fn AsmClobber(Colon: *Token) *Node {}
    fn AsmClobber(Colon: *Token, StringList: *NodeList) *Node {}

    // Helper grammar
    fn BreakLabel(Colon: *Token, Identifier: *Token) ?*Token {}
    fn BlockLabel(Identifier: *Token, Colon: *Token) *Token {}

    fn FieldInits(FieldInit: *Node) *NodeList {}
    fn FieldInits(FieldInits: *NodeList, Comma: *Token, FieldInit: *Node) *NodeList {}

    fn FieldInit(Period: *Token, Identifier: *Token, Equal: *Token, Expr: *Node) *Node {}

    fn WhileContinueExpr(Colon: *Token, LParen: *Token, AssignExpr: *Node, RParen: *Token) *Node {}

    fn MaybeLinkSection() ?*Node {}
    fn MaybeLinkSection(Keyword_linksection: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    // Function specific
    fn MaybeFnCC() ?*Token {}
    fn MaybeFnCC(Keyword_nakedcc: *Token) ?*Token {}
    fn MaybeFnCC(Keyword_stdcallcc: *Token) ?*Token {}
    fn MaybeFnCC(Keyword_extern: *Token) ?*Token {}

    fn ParamDecl(MaybeNoaliasComptime: ?*Token, ParamType: *Node) *Node {}
    fn ParamDecl(MaybeNoaliasComptime: ?*Token, Identifier: *Token, Colon: *Token, ParamType: *Node) *Node {}

    fn ParamType(Keyword_var: *Token) *Node {}
    fn ParamType(Ellipsis3: *Token) *Node {}
    fn ParamType(TypeExpr: *Node) *Node {}

    // Control flow prefixes
    fn IfPrefix(Keyword_if: *Token, LParen: *Token, Expr: *Node, RParen: *Token, MaybePtrPayload: ?*Node) *Node {}

    fn ForPrefix(Keyword_for: *Token, LParen: *Token, Expr: *Node, RParen: *Token, PtrIndexPayload: *Node) *Node {}
    fn WhilePrefix(Keyword_while: *Token, LParen: *Token, Expr: *Node, RParen: *Token, MaybePtrPayload: ?*Node) *Node {}
    fn WhilePrefix(Keyword_while: *Token, LParen: *Token, Expr: *Node, RParen: *Token, MaybePtrPayload: ?*Node, WhileContinueExpr: *Node) *Node {}

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

    // Switch specific
    fn SwitchProng(SwitchCase: *Node, EqualAngleBracketRight: *Token, MaybePtrPayload: ?*Node, AssignExpr: *Node) *Node {}

    fn SwitchCase(Keyword_else: *Token) *Node {}
    fn SwitchCase(SwitchItems: *NodeList, MaybeComma: ?*Token) *Node {}

    fn SwitchItems(SwitchItem: *Node) *NodeList {}
    fn SwitchItems(SwitchItems: *NodeList, Comma: *Token, SwitchItem: *Node) *NodeList {}

    fn SwitchItem(Expr: *Node) *Node {}
    fn SwitchItem(Expr: *Node, Ellipsis3: *Token, Expr: *Node) *Node {}

    // Operators
    fn AssignOp(AsteriskEqual: *Token) *Token {}
    fn AssignOp(SlashEqual: *Token) *Token {}
    fn AssignOp(PercentEqual: *Token) *Token {}
    fn AssignOp(PlusEqual: *Token) *Token {}
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
    fn BitwiseOp(Pipe: *Token) *Token {}
    // Note: Inconsistent with declared precedence rules
    fn BitwiseOp(Keyword_orelse: *Token) *Token {}
    // fn BitwiseOp(Keyword_catch: *Token) *Token {}

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
    fn PrefixOp(Minus: *Token) *Token {}
    fn PrefixOp(Tilde: *Token) *Token {}
    fn PrefixOp(MinusPercent: *Token) *Token {}
    fn PrefixOp(Ampersand: *Token) *Token {}
    fn PrefixOp(Keyword_try: *Token) *Token {}
    fn PrefixOp(Keyword_await: *Token) *Token {}

    fn PrefixTypeOps(PrefixTypeOp: *Node) *Node {}
    fn PrefixTypeOps(PrefixTypeOps: *Node, PrefixTypeOp: *Node) *Node {}

    fn PrefixTypeOp(QuestionMark: *Token) *Node {}
    fn PrefixTypeOp(Keyword_promise: *Token, MinusAngleBracketRight: *Token) *Node {}
    // Note: ArrayTypeStart inlined and split into Array and Slice to better model modifiers
    fn PrefixTypeOp(LBracket: *Token, Expr: *Node, RBracket: *Token) *Node {}
    fn PrefixTypeOp(LBracket: *Token, RBracket: *Token, MaybeAllowzero: ?*Token, MaybeByteAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token) *Node {}
    fn PrefixTypeOp(PtrTypeStart: *Token, MaybeAllowzero: ?*Token, MaybeAlign: ?*Node, MaybeConst: ?*Token, MaybeVolatile: ?*Token) *Node {}

    fn SuffixOpsEx(SuffixOp: *Node) *NodeList {}
    fn SuffixOpsEx(FnCallArguments: *Node) *NodeList {}
    fn SuffixOpsEx(SuffixOpsEx: *NodeList, SuffixOp: *Node) *NodeList {}
    fn SuffixOpsEx(SuffixOpsEx: *NodeList, FnCallArguments: *Node) *NodeList {}

    fn SuffixOps(SuffixOp: *Node) *NodeList {}
    fn SuffixOps(SuffixOps: *NodeList, SuffixOp: *Node) *NodeList {}

    fn SuffixOp(LBracket: *Token, Expr: *Node, RBracket: *Token) *Node {}
    fn SuffixOp(LBracket: *Token, Expr: *Node, Ellipsis2: *Token, RBracket: *Token) *Node {}
    fn SuffixOp(LBracket: *Token, Expr: *Node, Ellipsis2: *Token, Expr: *Node, RBracket: *Token) *Node {}
    fn SuffixOp(Period: *Token, Identifier: *Token) *Node {}
    fn SuffixOp(Period: *Token, Asterisk: *Token) *Node {}
    fn SuffixOp(Period: *Token, QuestionMark: *Token) *Node {}

    fn AsyncPrefix(Keyword_async: *Token) *Node {}
    fn AsyncPrefix(Keyword_async: *Token, AngleBracketLeft: *Token, PrefixExpr: *Node, AngleBracketRight: *Token) *Node {}

    fn FnCallArguments(LParen: *Token, RParen: *Token) *Node {}
    fn FnCallArguments(LParen: *Token, ExprList: *NodeList, MaybeComma: ?*Token, RParen: *Token) *Node {}

    // Ptr specific
    // Note: deprecated these and inlined in PrefixTypeOp
    // fn ArrayTypeStart(LBracket: *Token, RBracket: *Token) *Node {}
    // fn ArrayTypeStart(LBracket: *Token, Expr: *Node, RBracket: *Token) *Node {}

    fn PtrTypeStart(Asterisk: *Token) *Token {}
    fn PtrTypeStart(AsteriskAsterisk: *Token) *Token {}
    fn PtrTypeStart(BracketStarBracket: *Token) *Token {}
    fn PtrTypeStart(BracketStarCBracket: *Token) *Token {}

    fn MaybeVolatile() ?*Token {}
    fn MaybeVolatile(Keyword_volatile: *Token) ?*Token {}

    fn MaybeAllowzero() ?*Token {}
    fn MaybeAllowzero(Keyword_allowzero: *Token) ?*Token {}

    // ContainerDecl specific
    fn ContainerDeclType(Keyword_union: *Token, LParen: *Token, Keyword_enum: *Token, RParen: *Token) *Node {}
    fn ContainerDeclType(Keyword_union: *Token, LParen: *Token, Keyword_enum: *Token, LParen: *Token, Expr: *Node, RParen: *Token, RParen: *Token) *Node {}
    fn ContainerDeclType(Keyword_union: *Token, LParen: *Token, TypeExpr: *Node, RParen: *Token) *Node {}
    fn ContainerDeclType(Keyword_enum: *Token, LParen: *Token, TypeExpr: *Node, RParen: *Token) *Node {}

    fn ContainerDeclOp(Keyword_struct: *Token) *Token {}
    fn ContainerDeclOp(Keyword_union: *Token) *Token {}
    fn ContainerDeclOp(Keyword_enum: *Token) *Token {}

    // Alignment
    fn MaybeByteAlign() ?*Node {}
    fn MaybeByteAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}
    
    fn MaybeAlign() *Node {}
    fn MaybeAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, RParen: *Token) *Node {}
    fn MaybeAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, Colon: *Token, IntegerLiteral: *Token, Colon: *Token, IntegerLiteral: *Token, RParen: *Token) *Node {}
    fn MaybeAlign(Keyword_align: *Token, LParen: *Token, Identifier: *Token, Colon: *Token, IntegerLiteral: *Token, Colon: *Token, IntegerLiteral: *Token, RParen: *Token) *Node {}

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

    fn MaybeParamDeclList() ?*NodeList {}
    fn MaybeParamDeclList(ParamDeclList: *NodeList, MaybeComma: ?*Token) *NodeList {}

    fn ParamDeclList(ParamDecl: *Node) *NodeList {}
    fn ParamDeclList(ParamDeclList: *NodeList, Comma: *Token, ParamDecl: *Node) *NodeList {}

    fn ExprList(Expr: *Node) *Node {}
    fn ExprList(ExprList: *Node, Comma: *Token, Expr: *Node) *Node {}

    // Various helpers
    fn MaybePub() ?*Token {}
    fn MaybePub(Keyword_pub: *Token) ?*Token {}

    fn MaybeColonTypeExpr() ?*Node {}
    fn MaybeColonTypeExpr(Colon: *Token, TypeExpr: *Node) ?*Node {}

    fn MaybeExpr() ?*Node {}
    fn MaybeExpr(Expr: *Node) ?*Node {}

    fn MaybeBang() ?*Token {}
    fn MaybeBang(Bang: *Token) ?*Token {}

    fn MaybeNoaliasComptime() ?*Token {}
    fn MaybeNoaliasComptime(Keyword_noalias: *Token) ?*Token {}
    fn MaybeNoaliasComptime(Keyword_comptime: *Token) ?*Token {}

    fn MaybeInline() ?*Token {}
    fn MaybeInline(Keyword_inline: *Token) ?*Token {}

    fn MaybeIdentifier() ?*Token {}
    fn MaybeIdentifier(Identifier: *Token) ?*Token {}

    fn MaybeComma() ?*Token {}
    fn MaybeComma(Comma: *Token) ?*Token {}

    fn MaybeConst() ?*Token {}
    fn MaybeConst(Keyword_const: *Token) ?*Token {}

    fn SemicolonOrBlock(Semicolon: *Token) ?*Node {}
    fn SemicolonOrBlock(Block: *Node) ?*Node {}

    fn MultilineStringLiteral(LineString: *Token) *NodeList {}
    fn MultilineStringLiteral(MultilineStringLiteral: *NodeList, LineString: *Token) *NodeList {}

    fn MultilineCStringLiteral(LineCString: *Token) *NodeList {}
    fn MultilineCStringLiteral(MultilineCStringLiteral: *NodeList, LineCString: *Token) *NodeList {}
};
