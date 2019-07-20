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
        // left: enum { PrefixOp },
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

    fn MaybePub() ?*Token {}

    fn MaybePub(Keyword_pub: *Token) ?*Token {}

    fn MaybeColonTypeExpr() ?*Node {}

    fn MaybeColonTypeExpr(Colon: *Token, TypeExpr: *Node) ?*Node {}

    fn MaybeEqualExpr() ?*Node {}

    fn MaybeEqualExpr(Equal: *Token, Expr: *Node) ?*Node {}
};

// Root <- ContainerMembers* Eof
// ContainerMembers <- TestDecl
// ContainerMembers <- TopLevelComptime
// ContainerMembers <- Keyword_pub? TopLevelDecl
// ContainerMembers <- Keyword_pub? ContainerFields Semicolon
// ContainerFields <- ContainerField (Comma ContainerField)*
// ContainerField <- Identifier (Colon TypeExpr)? (Equal Expr)?
// TestDecl <- Keyword_test StringLiteral Block
// TopLevelComptime <- Keyword_comptime BlockExpr
// TopLevelDecl <- (Keyword_export | (Keyword_extern StringLiteral?) | Keyword_inline)? FnProto (SemiColon | Block)
// TopLevelDecl <- (Keyword_export | (Keyword_extern StringLiteral?))? Keyword_threadlocal? VarDecl (SemiColon | Block)
// FnProto <- (Keyword_nakedcc | Keyword_stdcallcc | Keyword_extern | Keyword_async)? Keyword_fn Identifier? LParen ParamDeclList RParen ByteAlign? LinkSection? Bang? (Keyword_var | TypeExpr)
// VarDecl <- (Keyword_const | Keyword_var) Identifier (Colon TypeExpr)? ByteAlign? LinkSection? (Equal Expr)? Semicolon
// Statement <- Keyword_comptime? VarDecl
// Statement <- Keyword_comptime BlockExprStatement
// Statement <- Keyword_suspend (Semicolon | BlockExprStatement)
// Statement <- Keyword_defer BlockExprStatement
// Statement <- Keyword_errdefer BlockExprStatement
// Statement <- IfStatement
// Statement <- LabeledStatement
// Statement <- SwitchExpr
// Statement <- AssignExpr Semicolon
// IfStatement <- IfPrefix BlockExpr (Keyword_else Payload? Statement)?
// IfStatement <- IfPrefix AssignExpr (Semicolon | Keyword_else Payload? Statement)
// LabeledStatement <- BlockLabel? (Block | LoopStatement)
// LoopStatement <- Keyword_inline? (ForStatement | WhileStatement)
// ForStatement <- ForPrefix BlockExpr (Keyword_else Statement)?
// ForStatement <- ForPrefix AssignExpr (Semicolon | Keyword_else Statement)
// WhileStatement <- WhilePrefix BlockExpr (Keyword_else Payload? Statement)?
// WhileStatement <- WhilePrefix AssignExpr (Semicolon | Keyword_else Payload? Statement)
// BlockExprStatement <- BlockExpr
// BlockExprStatement <- AssignExpr Semicolon
// BlockExpr <- BlockLabel? Block
// AssignExpr <- Expr (AssignOp Expr)?
// Expr <- Keyword_try? BoolOrExpr
// BoolOrExpr <- BoolAndExpr (Keyword_or BoolAndExpr)*
// BoolAndExpr <- CompareExpr (Keyword_and CompareExpr)*
// CompareExpr <- BitwiseExpr (CompareOp BitwiseExpr)?
// BitwiseExpr <- BitShiftExpr (BitwiseOp BitShiftExpr)*
// BitShiftExpr <- AdditionExpr (BitShiftOp AdditionExpr)*
// AdditionExpr <- MultiplyExpr (AdditionOp MultiplyExpr)*
// MultiplyExpr <- PrefixExpr (MultiplyOp PrefixExpr)*
// PrefixExpr <- PrefixOp* PrimaryExpr
// PrimaryExpr <- AsmExpr
// PrimaryExpr <- IfExpr
// PrimaryExpr <- Keyword_break BreakLabel? Expr?
// PrimaryExpr <- Keyword_cancel Expr
// PrimaryExpr <- Keyword_comptime Expr
// PrimaryExpr <- Keyword_continue BreakLabel?
// PrimaryExpr <- Keyword_resume Expr
// PrimaryExpr <- Keyword_return Expr?
// PrimaryExpr <- BlockLabel? LoopExpr
// PrimaryExpr <- Block
// PrimaryExpr <- CurlySuffixExpr
// IfExpr <- IfPrefix Expr (Keyword_else Payload? Expr)?
// Block <- LBrace Statement* RBrace
// LoopExpr <- Keyword_inline? (ForExpr | WhileExpr)
// ForExpr <- ForPrefix Expr (Keyword_else Expr)?
// WhileExpr <- WhilePrefix Expr (Keyword_else Payload? Expr)?
// CurlySuffixExpr <- TypeExpr InitList?
// InitList <- LBrace FieldInit (Comma FieldInit)* Comma? RBrace
// InitList <- LBrace Expr (Comma Expr)* Comma? RBrace
// InitList <- LBrace RBrace
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
// BreakLabel <- Colon Identifier
// BlockLabel <- Identifier Colon
// FieldInit <- Period Identifier Equal Expr
// WhileContinueExpr <- Colon LParen AssignExpr RParen
// LinkSection <- Keyword_linksection LParen Expr RParen
// ParamDecl <- (Keyword_noalias | Keyword_comptime)? (Identifier Colon)? ParamType
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
// AssignOp <- AsteriskEqual | SlashEqual | PercentEqual | MinusEqual | AngleBracketAngleBracketLeftEqual
// AssignOp <- AngleBracketAngleBracketRightEqual | AmpersandEqual | CaretEqual | PipeEqual | AsteriskPercentEqual
// AssignOp <- PlusPercentEqual | MinusPercentEqual | Equal
// CompareOp <- EqualEqual | BangEqual | AngleBracketLeft | AngleBracketRight | AngleBracketLeftEqual | AngleBracketRightEqual
// BitwiseOp <- Ampersand | Caret | Keyword_orelse | (Keyword_catch Payload?)
// BitShiftOp <- AngleBracketAngleBracketLeft | AngleBracketAngleBracketRight
// AdditionOp <- Plus | Minus | PlusPlus | PlusPercent | MinusPercent
// MultiplyOp <- PipePipe | Asterisk | Slash | Percent | AsteriskAsterisk | AsteriskPercent
// PrefixOp <- Bang | Minus | Tilde | MinusPercent | Ampersand | Keyword_try | Keyword_await
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
// ByteAlign <- Keyword_align LParen Expr RParen
// IdentifierList <- (Identifier Comma)* Identifier?
// SwitchProngList <- (SwitchProng Comma)* SwitchProng?
// AsmOutputList <- (AsmOutputItem Comma)* AsmOutputItem?
// AsmInputList <- (AsmInputItem Comma)* AsmInputItem?
// StringList <- (StringLiteral Comma)* StringLiteral?
// ParamDeclList <- (ParamDecl Comma)* ParamDecl?
// ExprList <- (Expr Comma)* Expr?
