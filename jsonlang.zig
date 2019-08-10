pub extern "LALR" const json_grammar = struct {
    fn Object(LBrace: *Token, MaybeFields: ?*VariantList, RBrace: *Token) *Variant;

    fn MaybeFields() ?*Variant.Object;
    fn MaybeFields(Fields: *VariantList) ?*Variant.Object;

    fn Fields(StringLiteral: *Token, Colon: *Token, Element: *Variant) *Variant.Object;
    fn Fields(Fields: *VariantList, Comma, *Token, StringLiteral: *Token, Colon: *Token, Element: *Variant) *Variant.Object;

    fn Array(LBracket: *Token, MaybeElements: ?*VariantList, RBracket: *Token) *Variant;

    fn MaybeElements() ?*VariantList;
    fn MaybeElements(Elements: *VariantList) ?*VariantList;

    fn Elements(Element: *Variant) *VariantList;
    fn Elements(Elements: *VariantList, Comma, *Token, Element: *Variant) *VariantList;

    fn Element(StringLiteral: *Token) *Variant;
    fn Element(Keyword_true: *Token) *Variant;
    fn Element(Keyword_false: *Token) *Variant;
    fn Element(IntegerLiteral: *Token) *Variant;
    fn Element(Object: *Variant) *Variant;
    fn Element(Array: *Variant) *Variant;
};
