pub extern "LALR" const json_grammar = struct {
    fn Object(LBrace: *Token, MaybeFields: *Variant.Object, RBrace: *Token) *Variant {
        result = &arg2.base;
        arg2.lbrace = arg1;
        arg2.rbrace = arg3;
    }

    fn MaybeFields() *Variant.Object {
        result = try parser.createVariant(Variant.Object);
        result.fields = VariantMap.init(&parser.arena.allocator);
    }
    fn MaybeFields(Fields: *Variant.Object) *Variant.Object;

    fn Fields(StringLiteral: *Token, Colon: *Token, Element: *Variant) *Variant.Object {
        result = try parser.createVariant(Variant.Object);
        result.fields = VariantMap.init(&parser.arena.allocator);
        const r = try result.fields.insert(parser.tokenString(arg1));
        if(r.is_new) {
            r.kv.value = arg3;
        }
    }
    fn Fields(Fields: *Variant.Object, Comma: *Token, StringLiteral: *Token, Colon: *Token, Element: *Variant) *Variant.Object {
        result = arg1;
        const r = try result.fields.insert(parser.tokenString(arg3));
        if(r.is_new) {
            r.kv.value = arg5;
        }
    }

    fn Array(LBracket: *Token, MaybeElements: ?*VariantList, RBracket: *Token) *Variant {
        const variant = try parser.createVariant(Variant.Array);
        variant.lbracket = arg1;
        variant.elements = if(arg2) |l| l.* else VariantList.init(&parser.arena.allocator);
        variant.rbracket = arg3;
        result = &variant.base;
    }

    fn MaybeElements() ?*VariantList;
    fn MaybeElements(Elements: *VariantList) ?*VariantList;

    fn Elements(Element: *Variant) *VariantList {
        result = try parser.createVariantList(VariantList);
        try result.append(arg1);
    }
    fn Elements(Elements: *VariantList, Comma: *Token, Element: *Variant) *VariantList {
        result = arg1;
        try result.append(arg3);
    }

    fn Element(StringLiteral: *Token) *Variant {
        const variant = try parser.createVariant(Variant.StringLiteral);
        variant.token = arg1;
        result = &variant.base;
    }
    fn Element(Keyword_true: *Token) *Variant {
        const variant = try parser.createVariant(Variant.BoolLiteral);
        variant.token = arg1;
        result = &variant.base;
    }
    fn Element(Keyword_false: *Token) *Variant {
        const variant = try parser.createVariant(Variant.BoolLiteral);
        variant.token = arg1;
        result = &variant.base;
    }
    fn Element(IntegerLiteral: *Token) *Variant {
        const variant = try parser.createVariant(Variant.IntegerLiteral);
        variant.token = arg1;
        result = &variant.base;
    }
    fn Element(Object: *Variant) *Variant;
    fn Element(Array: *Variant) *Variant;
};
