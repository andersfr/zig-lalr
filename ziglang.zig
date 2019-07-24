pub extern "LALR" const Grammar = struct {
    const Precedence = struct {
        left: enum {
            Keyword_or,
        },
        left: enum {
            Keyword_and,
        },
        left: enum {
            EqualEqual,
            BangEqual,
            AngleBracketLeft,
            AngleBracketLeftEqual,
            AngleBracketRight,
            AngleBracketRightEqual,
        },
        left: enum {
            Ampersand,
            Caret,
            Bang,
            Tilde,
        },
        left: enum {
            Plus,
            Minus,
            PlusPercent,
            MinusPercent,
        },
        left: enum {
            Asterisk,
            Slash,
            AsteriskPercent,
        },
        right: enum {
            Precedence_neg,
        },
    };

    fn Root() ?*Node {}

    fn Root(ContainerMembers: *Node) ?*Node {}

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

    fn TestDecl(Keyword_test: *Token, StringLiteral: *Token, Block: *Node) *Node {}

    fn TopLevelComptime(Keyword_comptime: *Token, BlockExpr: *Node) *Node {}

    fn TopLevelDecl(MaybeExternPackage: ?*Node, FnProto: *Node, Semicolon: *Token) *Node {}

    fn TopLevelDecl(MaybeExternPackage: ?*Node, FnProto: *Node, Block: *Node) *Node {}

    fn TopLevelDecl(MaybeExportInline: ?*Token, FnProto: *Node, Semicolon: *Token) *Node {}

    fn TopLevelDecl(MaybeExportInline: ?*Token, FnProto: *Node, Block: *Node) *Node {}

    fn TopLevelDecl(MaybeExternPackage: ?*Node, MaybeThreadlocal: ?*Token, VarDecl: *Node, Semicolon: *Token) *Node {}

    fn TopLevelDecl(MaybeExternPackage: ?*Node, MaybeThreadlocal: ?*Token, VarDecl: *Node, Block: *Node) *Node {}

    fn TopLevelDecl(MaybeExportExtern: ?*Token, MaybeThreadlocal: ?*Token, VarDecl: *Node, Semicolon: *Token) *Node {}

    fn TopLevelDecl(MaybeExportExtern: ?*Token, MaybeThreadlocal: ?*Token, VarDecl: *Node, Block: *Node) *Node {}

    fn MaybeExpr() ?*Node {}

    fn MaybeExpr(Expr: *Node) ?*Node {}

    fn MaybePub() ?*Token {}

    fn MaybePub(Keyword_pub: *Token) ?*Token {}

    fn MaybeColonTypeExpr() ?*Node {}

    fn MaybeColonTypeExpr(Colon: *Token, TypeExpr: *Node) ?*Node {}

    fn MaybeEqualExpr() ?*Node {}

    fn MaybeEqualExpr(Equal: *Token, Expr: *Node) ?*Node {}

    fn MaybeIdentifier() ?*Token {}

    fn MaybeIdentifier(Identifier: *Token) ?*Token {}

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

    fn MaybeFnProtoModifier() ?*Token {}

    fn MaybeFnProtoModifier(Keyword_nakedcc: *Token) ?*Token {}

    fn MaybeFnProtoModifier(Keyword_stdcallcc: *Token) ?*Token {}

    fn MaybeFnProtoModifier(Keyword_extern: *Token) ?*Token {}

    fn MaybeFnProtoModifier(Keyword_async: *Token) ?*Token {}

    fn MaybeComma() ?*Token {}

    fn MaybeComma(Comma: *Token) ?*Token {}

    fn MaybeBang() ?*Token {}

    fn MaybeBang(Bang: *Token) ?*Token {}

    fn MaybeByteAlign() ?*Node {}

    fn MaybeByteAlign(Keyword_align: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    fn MaybeLinkSection() ?*Node {}

    fn MaybeLinkSection(Keyword_linksection: *Token, LParen: *Token, Expr: *Node, RParen: *Token) ?*Node {}

    fn MaybeNoaliasComptime() ?*Token {}

    fn MaybeNoaliasComptime(Keyword_noalias: *Token) ?*Token {}

    fn MaybeNoaliasComptime(Keyword_comptime: *Token) ?*Token {}

    fn MaybeBreakLabel() ?*Token {}

    fn MaybeBreakLabel(Colon: *Token, Identifier: *Token) ?*Token {}

    fn FnProto(MaybeFnProtoModifier: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, LParen: *Token, ParamDeclList: ?*Node, RParen: *Token, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, Keyword_var: *Token) *Node {}

    fn FnProto(MaybeFnProtoModifier: ?*Token, Keyword_fn: *Token, MaybeIdentifier: ?*Token, LParen: *Token, ParamDeclList: ?*Node, RParen: *Token, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeBang: ?*Token, TypeExpr: *Node) *Node {}

    fn ParamDeclList() ?*Node {}

    fn ParamDeclList(ParamDecls: *node) ?*Node {}

    fn ParamDecls(ParamDecl: *Node) *Node {}

    fn ParamDecls(ParamDecls: *Node, Comma: *Token, ParamDecl: *Node) *Node {}

    fn ParamDecl(MaybeNoaliasComptime: ?*Token, ParamType: *node) *Node {}

    fn ParamDecl(MaybeNoaliasComptime: ?*Token, Identifer: *Token, Colon: *Token, ParamType: *Node) *Node {}

    fn VarDecl(Keyword_const: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}

    fn VarDecl(Keyword_var: *Token, Identifier: *Token, MaybeColonTypeExpr: ?*Node, MaybeByteAlign: ?*Node, MaybeLinkSection: ?*Node, MaybeEqualExpr: ?*Node, Semicolon: *Token) *Node {}

    fn BlockExpr(MaybeBlockLabel: ?*Token, Block: *Node) *Node {}

    fn MaybeBlockLabel() ?*Token {}

    fn MaybeBlockLabel(Identifier: *Token, Colon: *Token) ?*Token {}

    fn Block(LBrace: *Token, RBrace: *Token) *Node {}

    fn Block(LBrace: *Token, Statements: *Node, RBrace: *Token) *Node {}

    fn Statements(Statement: *Node) *Node {}

    fn Statements(Statements: *Node, Statement: *Node) *Node {}

    fn Statement(VarDecl: *Node) *Node {}

    fn Statement(Keyword_comptime: *Token, VarDecl: *Node) *Node {}

    fn Statement(Keyword_comptime: *Token, BlockExprStatement: *Node) *Node {}

    fn Statement(Keyword_suspend: *Token, Semicolon: *Token) *Node {}

    fn Statement(Keyword_suspend: *Token, BlockExprStatement: *Node) *Node {}

    fn Statement(Keyword_defer: *Token, BlockExprStatement: *Node) *Node {}

    fn Statement(Keyword_errdefer: *Token, BlockExprStatement: *Node) *Node {}

    fn Statement(IfStatement: *Node) *Node {}

    fn Statement(LabeledStatement: *Node) *Node {}

    fn Statement(SwitchExpr: *Node) *Node {}

    fn Statement(AssignExpr: *Node, Semicolon: *Token) *Node {}

    fn BlockExprStatement(BlockExpr: *Node) *Node {}

    fn BlockExprStatement(AssignExpr: *Node, Semicolon: *Token) *Node {}

    fn AssignExpr(Expr: *Node) *Node {}

    fn AssignExpr(Expr: *Node, AssignOp: *Token, Expr: *Node) *Node {}

    fn Expr(BoolOrExpr: *Node) *Node {}

    fn Expr(Keyword_try: *Token, BoolOrExpr: *Node) *Node {}

    fn BoolOrExpr(BoolAndExpr: *Node) *Node {}

    fn BoolOrExpr(BoolOrExpr: *Node, Keyword_or: *Token, BoolAndExpr: *Node) *Node {}

    fn BoolAndExpr(BoolCompareExpr: *Node) *Node {}

    fn BoolAndExpr(BoolAndExpr: *Node, Keyword_and: *Token, BoolCompareExpr: *Node) *Node {}

    fn BoolCompareExpr(BitwiseExpr: *Node) *Node {}

    fn BoolCompareExpr(BoolCompareExpr: *Node, CompareOp: *Token, BitwiseExpr: *Node) *Node {}

    fn BitwiseExpr(BitShiftExpr: *Node) *Node {}

    fn BitwiseExpr(BitwiseExpr: *Node, BitwiseOp: *Token, BitShiftExpr: *Node) *Node {}

    fn BitwiseExpr(BitwiseExpr: *Node, Keyword_catch: *Token, Payload: *Node, BitShiftExpr: *Node) *Node {}

    fn BitShiftExpr(AdditionExpr: *Node) *Node {}

    fn BitShiftExpr(BitShiftExpr: *Node, BitShiftOp: *Token, AdditionExpr: *Node) *Node {}

    fn AdditionExpr(MultiplyExpr: *Node) *Node {}

    fn AdditionExpr(AdditionExpr: *Node, AdditionOp: *Token, MultiplyExpr: *Node) *Node {}

    fn MultiplyExpr(PrefixExpr: *Node) *Node {}

    fn MultiplyExpr(MultiplyExpr: *Node, MultiplyOp: *Token, PrefixExpr: *Node) *Node {}

    fn PrefixExpr(PrimaryExpr: *Node) *Node {}

    fn PrefixExpr(PrefixOp: *Node, PrefixExpr: *Node) *Node {}

    fn PrimaryExpr(AsmExpr: *Node) *Node {}

    fn PrimaryExpr(IfExpr: *Node) *Node {}

    fn PrimaryExpr(Keyword_break: *Token, MaybeBreakLabel: ?*Token, MaybeExpr: ?*Node) *Node {}

    fn PrimaryExpr(Keyword_cancel: *Token, Expr: *Node) *Node {}

    fn PrimaryExpr(Keyword_comptime: *Token, Expr: *Node) *Node {}

    fn PrimaryExpr(Keyword_continue: *Token, MaybeBreakLabel: ?*Token) *Node {}

    fn PrimaryExpr(Keyword_resume: *Token, Expr: *Node) *Node {}

    fn PrimaryExpr(Keyword_return: *Token, MaybeExpr: ?*Node) *Node {}

    fn PrimaryExpr(LoopExpr: *Node) *Node {}

    fn PrimaryExpr(Identifier: *Token, Colon: *Token, LoopExpr: *Node) *Node {}

    fn PrimaryExpr(Block: *Node) *Node {}

    fn PrimaryExpr(CurlySuffixExpr: *Node) *Node {}

    fn CurlySuffixExpr(TypeExpr: *Node) *Node {}

    fn CurlySuffixExpr(TypeExpr: *Node, InitList: *Node) *Node {}

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

    fn PrefixOp(Minus: *Token) *Token {}

    fn PrefixOp(Tilde: *Token) *Token {}

    fn PrefixOp(MinusPercent: *Token) *Token {}

    fn PrefixOp(Ampersand: *Token) *Token {}

    fn PrefixOp(Keyword_try: *Token) *Token {}

    fn PrefixOp(Keyword_await: *Token) *Token {}

    fn InitList(LBrace: *Token, RBrace: *Token) *Node {}

    fn InitList(LBrace: *Token, FieldInits: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn InitList(LBrace: *Token, Exprs: *Node, MaybeComma: ?*Token, RBrace: *Token) *Node {}

    fn FieldInits(FieldInit: *Node) *Node {}

    fn FieldInits(FieldInits: *Node, Comma: *Token, FieldInit: *Node) *Node {}

    fn FieldInit(Period: *Token, Identifier: *Token, Equal: *Token, Expr: *Node) *Node {}

    fn Exprs(Expr: *Node) *Node {}

    fn Exprs(Exprs: *Node, Comma: *Token, Expr: *Node) *Node {}

};
// IfStatement <- IfPrefix BlockExpr (Keyword_else Payload? Statement)?
// IfStatement <- IfPrefix AssignExpr (Semicolon | Keyword_else Payload? Statement)
// LabeledStatement <- BlockLabel? (Block | LoopStatement)
// LoopStatement <- Keyword_inline? (ForStatement | WhileStatement)
// ForStatement <- ForPrefix BlockExpr (Keyword_else Statement)?
// ForStatement <- ForPrefix AssignExpr (Semicolon | Keyword_else Statement)
// WhileStatement <- WhilePrefix BlockExpr (Keyword_else Payload? Statement)?
// WhileStatement <- WhilePrefix AssignExpr (Semicolon | Keyword_else Payload? Statement)
// IfExpr <- IfPrefix Expr (Keyword_else Payload? Expr)?
// LoopExpr <- Keyword_inline? (ForExpr | WhileExpr)
// ForExpr <- ForPrefix Expr (Keyword_else Expr)?
// WhileExpr <- WhilePrefix Expr (Keyword_else Payload? Expr)?
// TypeExpr <- PrefixTypeOp* ErrorUnionExpr
// ErrorUnionExpr <- SuffixExpr (Bang TypeExpr)?
// SuffixExpr <- AsyncPrefix PrimaryTypeExpr SuffixOp* FnCallArguments
// SuffixExpr <- PrimaryTypeExpr (SuffixOp | FnCallArguments)*
// PrimaryTypeExpr <- Builtin Identifier FnCallArguments
// PrimaryTypeExpr <- CharLiteral
// PrimaryTypeExpr <- ContainerDecl
// PrimaryTypeExpr <- Period Identifier
// PrimaryTypeExpr <- ErrorSetDecl
// PrimaryTypeExpr <- FloatLiteral
// PrimaryTypeExpr <- FnProto
// PrimaryTypeExpr <- GroupedExpr
// PrimaryTypeExpr <- LabeledTypeExpr
// PrimaryTypeExpr <- Identifier
// PrimaryTypeExpr <- IfTypeExpr
// PrimaryTypeExpr <- IntegerLiteral
// PrimaryTypeExpr <- Keyword_anyerror
// PrimaryTypeExpr <- Keyword_comptime TypeExpr
// PrimaryTypeExpr <- Keyword_error Period Identifer
// PrimaryTypeExpr <- Keyword_false | Keyword_null | Keyword_promise | Keyword_true
// PrimaryTypeExpr <- Keyword_undefined | Keyword_unreachable
// PrimaryTypeExpr <- StringLiteral
// PrimaryTypeExpr <- SwitchExpr
// ContainerDecl <- (Keyword_extern | Keyword_packed)? ContainerDeclAuto
// ErrorSetDecl <- Keyword_error LBrace IdentifierList RBrace
// GroupedExpr <- LParen Expr RParen
// IfTypeExpr <- IfPrefix TypeExpr (Keyword_else Payload? TypeExpr)?
// LabeledTypeExpr <- BlockLabel Block
// LabeledTypeExpr <- BlockLabel? LoopTypeExpr
// LoopTypeExpr <- Keyword_inline? (ForTypeExpr | WhileTypeExpr)
// ForTypeExpr <- ForPrefix TypeExpr (Keyword_else TypeExpr)?
// WhileTypeExpr <- WhilePrefix TypeExpr (Keyword_else Payload? TypeExpr)?
// SwitchExpr <- Keyword_switch LParen Expr RParen LBrace SwitchProngList RBrace
// AsmExpr <- Keyword_asm Keyword_volatile? LParen StringLiteral AsmOutput? RParen
// AsmOutput <- Colon AsmOutputList AsmInput?
// AsmOutputItem <- LBracket Identifier RBracket StringLiteral LParen (MinusAngleBracketArrowRight TypeExpr | Identifier) RParen
// AsmInput <- Colon AsmInputList AsmClobbers?
// AsmInputItem <- LBracket Identifier RBracket StringLiteral LParen Expr RParen
// AsmClobbers <- Colon StringList
// WhileContinueExpr <- Colon LParen AssignExpr RParen
// ParamType <- Keyword_var | Ellipsis3 | TypeExpr
// IfPrefix <- Keyword_if LParen Expr RParen PtrPayload?
// WhilePrefix <- Keyword_while LParen Expr RParen PtrPayload? WhileContinueExpr?
// ForPrefix <- Keyword_for LParen Expr RParen PtrIndexPayload
// Payload <- Pipe Identifier Pipe
// PtrPayload <- Pipe Asterisk? Identifier Pipe
// PtrIndexPayload <- Pipe Asterisk? Identifier (Comma Identifier)? Pipe
// SwitchProng <- SwitchCase EqualAngleBracketRight PtrPayload? AssignExpr
// SwitchCase <- SwitchItem (Comma SwitchItem)* Comma?
// SwitchCast <- Keyword_else
// SwitchItem <- Expr (Ellipsis3 Expr)?
// PrefixTypeOp <- QuestionMark
// PrefixTypeOp <- Keyword_promise MinusAngleBracketRight
// PrefixTypeOp <- ArrayTypeStart (ByteAlign | Keyword_const | Keyword_volatile | Keyword_allowzero)*
// PrefixTypeOp <- PtrTypeStart (Keyword_align LParen Expr (Colon IntegerLiteral Colon IntegerLiteral)? RParen | Keyword_const | Keyword_volatile | Keyword_allowzero)*
// SuffixOp <- LBracket Expr (Ellipsis2 Expr?)? RBracket
// SuffixOp <- Period (Identifier | Asterisk | QuestionMark)
// AsyncPrefix <- Keyword_async (AngleBracketLeft PrefixExpr AngleBracketRight)?
// FnCallArguments <- LParen ExprList RParen
// ArrayTypeStart <- LBracket Expr? RBracket
// PtrTypeStart <- Asterisk | AsteriskAsterisk | BracketStarBracket | BracketStarCBracket
// ContainerDeclAuto <- ContainerDeclType LBrace ContainerMembers RBrace
// ContainerDeclType <- (Keyword_struct | Keyword_enum) (LParen Expr RParen)?
// ContainerDeclType <- Keyword_struct Period
// ContainerDeclType <- Keyword_union (LParen (Keyword_enum (LParen Expr RParen)? | Expr) RParen)?
// IdentifierList <- (Identifier Comma)* Identifier?
// SwitchProngList <- (SwitchProng Comma)* SwitchProng?
// AsmOutputList <- (AsmOutputItem Comma)* AsmOutputItem?
// AsmInputList <- (AsmInputItem Comma)* AsmInputItem?
// StringList <- (StringLiteral Comma)* StringLiteral?
// ExprList <- (Expr Comma)* Expr?
