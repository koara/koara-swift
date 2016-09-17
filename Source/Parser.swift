class Parser {

    var cs : CharStream!
    var token, nextToken, scanPosition, lastPosition : Token!
    var tm : TokenManager!
    var tree : TreeState!
    var currentBlockLevel : Int = 0
    var currentQuoteLevel : Int = 0
    var lookAhead : Int = 0
    var nextTokenKind : Int = 0
    var lookingAhead : Bool = false
    var semanticLookAhead : Bool = false
    var modules : [String] = ["paragraphs", "headings", "lists", "links", "images", "formatting", "blockquotes", "code"]
    let lookAheadSuccess : LookaheadSuccess
    
    init() {
        self.lookAheadSuccess = LookaheadSuccess()
    }
    
    func parse(text: String) -> Document {
        return self.parseReader(StringReader(text: text))
    }
//    
//    public Document parseFile(File file) throws IOException {
//    if(!file.getName().toLowerCase().endsWith(".kd")) {
//    throw new IllegalArgumentException("Can only parse files with extension .kd");
//    }
//    return parseReader(new FileReader(file));
//    }
//    
    func parseReader(reader: Reader) -> Document {
        cs = CharStream(reader: reader)
        tm = TokenManager(stream: cs)
        token = Token()
        tree = TreeState()
        nextTokenKind = -1
        let document = Document()
        tree.openScope()
        
        while getNextTokenKind() == TokenManager.EOL {
            consumeToken(TokenManager.EOL);
        }
        whiteSpace()
        if hasAnyBlockElementsAhead() {
            blockElement()
            while blockAhead(0) {
                while (getNextTokenKind() == TokenManager.EOL) {
                    consumeToken(TokenManager.EOL);
                    whiteSpace()
                }
                blockElement()
            }
            while (getNextTokenKind() == TokenManager.EOL) {
                consumeToken(TokenManager.EOL);
            }
            whiteSpace();
        }
        consumeToken(TokenManager.EOF);
        tree.closeScope(document);
        return document;
    }

    func blockElement() {
        currentBlockLevel += 1
        if (modules.contains("headings") && headingAhead(1)) {
            heading()
        } else if (modules.contains("blockquotes") && getNextTokenKind() == TokenManager.GT) {
            blockQuote()
        } else if (modules.contains("lists") && getNextTokenKind() == TokenManager.DASH) {
            unorderedList()
        } else if (modules.contains("lists") && hasOrderedListAhead()) {
            orderedList()
        } else if (modules.contains("code") && hasFencedCodeBlockAhead()) {
            fencedCodeBlock()
        } else {
            paragraph()
        }
        currentBlockLevel -= 1
    }
    
    func heading() {
        var heading = Heading();
        tree.openScope();
        var headingLevel : Int = 0;
        while (getNextTokenKind() == TokenManager.EQ) {
            consumeToken(TokenManager.EQ);
            headingLevel += 1
        }
        whiteSpace();
        while headingHasInlineElementsAhead() {
            if hasTextAhead() {
                text()
            } else if (modules.contains("images") && hasImageAhead()) {
                image()
            } else if (modules.contains("links") && hasLinkAhead()) {
                link()
            } else if (modules.contains("formatting") && hasStrongAhead()) {
                strong()
            } else if (modules.contains("formatting") && hasEmAhead()) {
                em()
            } else if (modules.contains("code") && hasCodeAhead()) {
                code()
            } else {
                looseChar()
            }
        }
        heading.value = headingLevel
        tree.closeScope(heading);
    }

    func blockQuote() {
        var blockQuote = BlockQuote()
        tree.openScope()
        currentQuoteLevel += 1
        consumeToken(TokenManager.GT);
        while blockQuoteHasEmptyLineAhead() {
            blockQuoteEmptyLine()
        }
        whiteSpace()
        if blockQuoteHasAnyBlockElementseAhead() {
            blockElement()
            while (blockAhead(0)) {
                while (getNextTokenKind() == TokenManager.EOL) {
                    consumeToken(TokenManager.EOL)
                    whiteSpace();
                    blockQuotePrefix()
                }
                blockElement()
            }
        }
        while (hasBlockQuoteEmptyLinesAhead()) {
            blockQuoteEmptyLine()
        }
        currentQuoteLevel -= 1
        tree.closeScope(blockQuote)
    }
    
    func blockQuotePrefix() {
        var i : Int = 0;
       
        
//    do {
//    consumeToken(GT);
        whiteSpace();
//    } while (++i < currentQuoteLevel);
    }

    func blockQuoteEmptyLine() {
        consumeToken(TokenManager.EOL);
        whiteSpace();
//    do {
//    consumeToken(GT);
        whiteSpace();
//    } while (getNextTokenKind() == GT);
    }

    func unorderedList() {
        var list = ListBlock(ordered: false)
        tree.openScope()
        var listBeginColumn = unorderedListItem();
        while listItemAhead(listBeginColumn, ordered: false) {
            while getNextTokenKind() == TokenManager.EOL {
                consumeToken(TokenManager.EOL);
            }
            whiteSpace();
            if currentQuoteLevel > 0 {
                blockQuotePrefix()
            }
            unorderedListItem()
        }
        tree.closeScope(list)
    }
  
    func unorderedListItem() -> Int {
        let listItem = ListItem()
        tree.openScope()
        var t = consumeToken(TokenManager.DASH)
        whiteSpace();
        if listItemHasInlineElements() {
            blockElement();
            while blockAhead(t.beginColumn) {
                while getNextTokenKind() == TokenManager.EOL {
                    consumeToken(TokenManager.EOL);
                    whiteSpace()
                    if (currentQuoteLevel > 0) {
                        blockQuotePrefix()
                    }
                }
                blockElement();
            }
        }
        tree.closeScope(listItem)
        return t.beginColumn;
    }

    func orderedList() {
        var list = ListBlock(ordered: true)
        tree.openScope()
        var listBeginColumn : Int = orderedListItem()
        while listItemAhead(listBeginColumn, ordered: true) {
            while getNextTokenKind() == TokenManager.EOL {
                consumeToken(TokenManager.EOL)
            }
            whiteSpace()
            if currentQuoteLevel > 0 {
                blockQuotePrefix()
            }
            orderedListItem()
        }
        tree.closeScope(list)
    }
//    
    func orderedListItem() -> Int {
        var listItem = ListItem()
        tree.openScope()
        var t = consumeToken(TokenManager.DIGITS)
        consumeToken(TokenManager.DOT)
        whiteSpace()
        if listItemHasInlineElements() {
            blockElement()
            while blockAhead(t.beginColumn) {
                while getNextTokenKind() == TokenManager.EOL {
                    consumeToken(TokenManager.EOL)
                    whiteSpace()
                    if currentQuoteLevel > 0 {
                        blockQuotePrefix()
                    }
                }
                blockElement()
            }
        }
        listItem.number = Int(t.image)!
        tree.closeScope(listItem)
        return t.beginColumn
    }
    
    func fencedCodeBlock() {
//    CodeBlock codeBlock = new CodeBlock();
//    tree.openScope();
//    StringBuilder s = new StringBuilder();
//    int beginColumn = consumeToken(BACKTICK).beginColumn;
//    do {
//    consumeToken(BACKTICK);
//    } while (getNextTokenKind() == BACKTICK);
        whiteSpace()
//    if (getNextTokenKind() == CHAR_SEQUENCE) {
//    codeBlock.setLanguage(codeLanguage());
//    }
//    if (getNextTokenKind() != EOF && !fencesAhead()) {
//    consumeToken(EOL);
//    levelWhiteSpace(beginColumn);
//    }
//    
//    int kind = getNextTokenKind();
//    while (kind != EOF && ((kind != EOL && kind != BACKTICK) || !fencesAhead())) {
//    switch (kind) {
//    case CHAR_SEQUENCE:
//    s.append(consumeToken(CHAR_SEQUENCE).image);
//    break;
//    case ASTERISK:
//    s.append(consumeToken(ASTERISK).image);
//    break;
//    case BACKSLASH:
//    s.append(consumeToken(BACKSLASH).image);
//    break;
//    case COLON:
//    s.append(consumeToken(COLON).image);
//    break;
//    case DASH:
//    s.append(consumeToken(DASH).image);
//    break;
//    case DIGITS:
//    s.append(consumeToken(DIGITS).image);
//    break;
//    case DOT:
//    s.append(consumeToken(DOT).image);
//    break;
//    case EQ:
//    s.append(consumeToken(EQ).image);
//    break;
//    case ESCAPED_CHAR:
//    s.append(consumeToken(ESCAPED_CHAR).image);
//    break;
//    case IMAGE_LABEL:
//    s.append(consumeToken(IMAGE_LABEL).image);
//    break;
//    case LT:
//    s.append(consumeToken(LT).image);
//    break;
//    case GT:
//    s.append(consumeToken(GT).image);
//    break;
//    case LBRACK:
//    s.append(consumeToken(LBRACK).image);
//    break;
//    case RBRACK:
//    s.append(consumeToken(RBRACK).image);
//    break;
//    case LPAREN:
//    s.append(consumeToken(LPAREN).image);
//    break;
//    case RPAREN:
//    s.append(consumeToken(RPAREN).image);
//    break;
//    case UNDERSCORE:
//    s.append(consumeToken(UNDERSCORE).image);
//    break;
//    case BACKTICK:
//    s.append(consumeToken(BACKTICK).image);
//    break;
//    default:
//    if (!nextAfterSpace(EOL, EOF)) {
//    switch (kind) {
//    case SPACE:
//    s.append(consumeToken(SPACE).image);
//    break;
//    case TAB:
//    consumeToken(TAB);
//    s.append("    ");
//    break;
//    }
//    } else if (!fencesAhead()) {
//    consumeToken(EOL);
//    s.append("\n");
//    levelWhiteSpace(beginColumn);
//    }
//    }
//    kind = getNextTokenKind();
//    }
//    if (fencesAhead()) {
//    consumeToken(EOL);
//    blockQuotePrefix();
        whiteSpace()
//    while (getNextTokenKind() == BACKTICK) {
//    consumeToken(BACKTICK);
//    }
//    }
//    codeBlock.setValue(s.toString());
//    tree.closeScope(codeBlock);
    }
//    
    func paragraph() {
//    BlockElement paragraph = modules.contains("paragraphs") ? new Paragraph() : new BlockElement();
//    tree.openScope();
//    inline();
//    while (textAhead()) {
//    lineBreak();
        whiteSpace()
//    if (modules.contains("blockquotes")) {
//    while (getNextTokenKind() == GT) {
//    consumeToken(GT);
        whiteSpace()
//    }
//    }
//    inline();
//    }
//    tree.closeScope(paragraph);
    }
   
    func text() {
//    Text text = new Text();
//    tree.openScope();
//    StringBuffer s = new StringBuffer();
//    while (textHasTokensAhead()) {
//    switch (getNextTokenKind()) {
//    case CHAR_SEQUENCE:
//    s.append(consumeToken(CHAR_SEQUENCE).image);
//    break;
//    case BACKSLASH:
//    s.append(consumeToken(BACKSLASH).image);
//    break;
//    case COLON:
//    s.append(consumeToken(COLON).image);
//    break;
//    case DASH:
//    s.append(consumeToken(DASH).image);
//    break;
//    case DIGITS:
//    s.append(consumeToken(DIGITS).image);
//    break;
//    case DOT:
//    s.append(consumeToken(DOT).image);
//    break;
//    case EQ:
//    s.append(consumeToken(EQ).image);
//    break;
//    case ESCAPED_CHAR:
//    s.append(consumeToken(ESCAPED_CHAR).image.substring(1));
//    break;
//    case GT:
//    s.append(consumeToken(GT).image);
//    break;
//    case IMAGE_LABEL:
//    s.append(consumeToken(IMAGE_LABEL).image);
//    break;
//    case LPAREN:
//    s.append(consumeToken(LPAREN).image);
//    break;
//    case LT:
//    s.append(consumeToken(LT).image);
//    break;
//    case RBRACK:
//    s.append(consumeToken(RBRACK).image);
//    break;
//    case RPAREN:
//    s.append(consumeToken(RPAREN).image);
//    break;
//    default:
//    if (!nextAfterSpace(EOL, EOF)) {
//    switch (getNextTokenKind()) {
//    case SPACE:
//    s.append(consumeToken(SPACE).image);
//    break;
//    case TAB:
//    consumeToken(TAB);
//    s.append("    ");
//    break;
//    }
//    }
//    }
//    }
//    text.setValue(s.toString());
//    tree.closeScope(text);
    }
  
    func image() {
//    Image image = new Image();
//    tree.openScope();
//    String ref = "";
//    consumeToken(LBRACK);
        whiteSpace()
//    consumeToken(IMAGE_LABEL);
        whiteSpace()
//    while (imageHasAnyElements()) {
//    if (hasTextAhead()) {
//    resourceText();
//    } else {
//    looseChar();
//    }
//    }
        whiteSpace()
//    consumeToken(RBRACK);
//    if (hasResourceUrlAhead()) {
//    ref = resourceUrl();
//    }
//    image.setValue(ref);
//    tree.closeScope(image);
    }
    
    func link() {
//    Link link = new Link();
//    tree.openScope();
//    String ref = "";
//    consumeToken(LBRACK);
        whiteSpace()
//    while (linkHasAnyElements()) {
//    if (modules.contains("images") && hasImageAhead()) {
//    image();
//    } else if (modules.contains("formatting") && hasStrongAhead()) {
//    strong();
//    } else if (modules.contains("formatting") && hasEmAhead()) {
//    em();
//    } else if (modules.contains("code") && hasCodeAhead()) {
//    code();
//    } else if (hasResourceTextAhead()) {
//    resourceText();
//    } else {
//    looseChar();
//    }
//    }
        whiteSpace()
//    consumeToken(RBRACK);
//    if (hasResourceUrlAhead()) {
//    ref = resourceUrl();
//    }
//    link.setValue(ref);
//    tree.closeScope(link);
    }
    
    func strong() {
//    Strong strong = new Strong();
//    tree.openScope();
//    consumeToken(ASTERISK);
//    while (strongHasElements()) {
//    if (hasTextAhead()) {
//    text();
//    } else if (modules.contains("images") && hasImage()) {
//    image();
//    } else if (modules.contains("links") && hasLinkAhead()) {
//    link();
//    } else if (modules.contains("code") && multilineAhead(BACKTICK)) {
//    codeMultiline();
//    } else if (strongEmWithinStrongAhead()) {
//    emWithinStrong();
//    } else {
//    switch (getNextTokenKind()) {
//    case BACKTICK:
//    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
//    break;
//    case LBRACK:
//    tree.addSingleValue(new Text(), consumeToken(LBRACK));
//    break;
//    case UNDERSCORE:
//    tree.addSingleValue(new Text(), consumeToken(UNDERSCORE));
//    break;
//    }
//    }
//    }
//    consumeToken(ASTERISK);
//    tree.closeScope(strong);
    }
  
    func em() {
//    Em em = new Em();
//    tree.openScope();
//    consumeToken(UNDERSCORE);
//    while (emHasElements()) {
//    if (hasTextAhead()) {
//    text();
//    } else if (modules.contains("images") && hasImage()) {
//    image();
//    } else if (modules.contains("links") && hasLinkAhead()) {
//    link();
//    } else if (modules.contains("code") && hasCodeAhead()) {
//    code();
//    } else if (emHasStrongWithinEm()) {
//    strongWithinEm();
//    } else {
//    switch (getNextTokenKind()) {
//    case ASTERISK:
//    tree.addSingleValue(new Text(), consumeToken(ASTERISK));
//    break;
//    case BACKTICK:
//    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
//    break;
//    case LBRACK:
//    tree.addSingleValue(new Text(), consumeToken(LBRACK));
//    break;
//    }
//    }
//    }
//    consumeToken(UNDERSCORE);
//    tree.closeScope(em);
    }

    func code() {
//    Code code = new Code();
//    tree.openScope();
//    consumeToken(BACKTICK);
//    codeText();
//    consumeToken(BACKTICK);
//    tree.closeScope(code);
    }

    func codeText() {
//    Text text = new Text();
//    tree.openScope();
//    StringBuffer s = new StringBuffer();
//    do {
//    switch (getNextTokenKind()) {
//    case CHAR_SEQUENCE:
//    s.append(consumeToken(CHAR_SEQUENCE).image);
//    break;
//    case ASTERISK:
//    s.append(consumeToken(ASTERISK).image);
//    break;
//    case BACKSLASH:
//    s.append(consumeToken(BACKSLASH).image);
//    break;
//    case COLON:
//    s.append(consumeToken(COLON).image);
//    break;
//    case DASH:
//    s.append(consumeToken(DASH).image);
//    break;
//    case DIGITS:
//    s.append(consumeToken(DIGITS).image);
//    break;
//    case DOT:
//    s.append(consumeToken(DOT).image);
//    break;
//    case EQ:
//    s.append(consumeToken(EQ).image);
//    break;
//    case ESCAPED_CHAR:
//    s.append(consumeToken(ESCAPED_CHAR).image);
//    break;
//    case IMAGE_LABEL:
//    s.append(consumeToken(IMAGE_LABEL).image);
//    break;
//    case LT:
//    s.append(consumeToken(LT).image);
//    break;
//    case LBRACK:
//    s.append(consumeToken(LBRACK).image);
//    break;
//    case RBRACK:
//    s.append(consumeToken(RBRACK).image);
//    break;
//    case LPAREN:
//    s.append(consumeToken(LPAREN).image);
//    break;
//    case GT:
//    s.append(consumeToken(GT).image);
//    break;
//    case RPAREN:
//    s.append(consumeToken(RPAREN).image);
//    break;
//    case UNDERSCORE:
//    s.append(consumeToken(UNDERSCORE).image);
//    break;
//    default:
//    if (!nextAfterSpace(EOL, EOF)) {
//    switch (getNextTokenKind()) {
//    case SPACE:
//    s.append(consumeToken(SPACE).image);
//    break;
//    case TAB:
//    consumeToken(TAB);
//    s.append("    ");
//    break;
//    }
//    }
//    }
//    } while (codeTextHasAnyTokenAhead());
//    text.setValue(s.toString());
//    tree.closeScope(text);
    }

    func looseChar() {
//    Text text = new Text();
//    tree.openScope();
//    switch (getNextTokenKind()) {
//    case ASTERISK:
//    text.setValue(consumeToken(ASTERISK).image);
//    break;
//    case BACKTICK:
//    text.setValue(consumeToken(BACKTICK).image);
//    break;
//    case LBRACK:
//    text.setValue(consumeToken(LBRACK).image);
//    break;
//    case UNDERSCORE:
//    text.setValue(consumeToken(UNDERSCORE).image);
//    break;
//    }
//    tree.closeScope(text);
    }

    func lineBreak() {
//    LineBreak linebreak = new LineBreak();
//    tree.openScope();
//    while (getNextTokenKind() == SPACE || getNextTokenKind() == TAB) {
//    consumeToken(getNextTokenKind());
//    }
//    Token t = consumeToken(EOL);
//    linebreak.setExplicit(t.image.startsWith("  "));
//    tree.closeScope(linebreak);
//    }
//    
//    private void levelWhiteSpace(int threshold) {
//    int currentPos = 1;
//    while (getNextTokenKind() == GT) {
//    consumeToken(getNextTokenKind());
//    }
//    while ((getNextTokenKind() == SPACE || getNextTokenKind() == TAB) && currentPos < (threshold - 1)) {
//    currentPos = consumeToken(getNextTokenKind()).beginColumn;
//    }
    }

    func codeLanguage() {
//    StringBuilder s = new StringBuilder();
//    do {
//    switch (getNextTokenKind()) {
//    case CHAR_SEQUENCE:
//    s.append(consumeToken(CHAR_SEQUENCE).image);
//    break;
//    case ASTERISK:
//    s.append(consumeToken(ASTERISK).image);
//    break;
//    case BACKSLASH:
//    s.append(consumeToken(BACKSLASH).image);
//    break;
//    case BACKTICK:
//    s.append(consumeToken(BACKTICK).image);
//    break;
//    case COLON:
//    s.append(consumeToken(COLON).image);
//    break;
//    case DASH:
//    s.append(consumeToken(DASH).image);
//    break;
//    case DIGITS:
//    s.append(consumeToken(DIGITS).image);
//    break;
//    case DOT:
//    s.append(consumeToken(DOT).image);
//    break;
//    case EQ:
//    s.append(consumeToken(EQ).image);
//    break;
//    case ESCAPED_CHAR:
//    s.append(consumeToken(ESCAPED_CHAR).image);
//    break;
//    case IMAGE_LABEL:
//    s.append(consumeToken(IMAGE_LABEL).image);
//    break;
//    case LT:
//    s.append(consumeToken(LT).image);
//    break;
//    case GT:
//    s.append(consumeToken(GT).image);
//    break;
//    case LBRACK:
//    s.append(consumeToken(LBRACK).image);
//    break;
//    case RBRACK:
//    s.append(consumeToken(RBRACK).image);
//    break;
//    case LPAREN:
//    s.append(consumeToken(LPAREN).image);
//    break;
//    case RPAREN:
//    s.append(consumeToken(RPAREN).image);
//    break;
//    case UNDERSCORE:
//    s.append(consumeToken(UNDERSCORE).image);
//    break;
//    case SPACE:
//    s.append(consumeToken(SPACE).image);
//    break;
//    case TAB:
//    s.append("    ");
//    break;
//    default:
//    break;
//    }
//    } while (getNextTokenKind() != EOL && getNextTokenKind() != EOF);
//    return s.toString();
    }
  
    func inline() {
//    do {
//    if (hasInlineTextAhead()) {
//    text();
//    } else if (modules.contains("images") && hasImageAhead()) {
//    image();
//    } else if (modules.contains("links") && hasLinkAhead()) {
//    link();
//    } else if (modules.contains("formatting") && multilineAhead(ASTERISK)) {
//    strongMultiline();
//    } else if (modules.contains("formatting") && multilineAhead(UNDERSCORE)) {
//    emMultiline();
//    } else if (modules.contains("code") && multilineAhead(BACKTICK)) {
//    codeMultiline();
//    } else {
//    looseChar();
//    }
//    } while (hasInlineElementAhead());
    }
   
    func resourceText() {
//    Text text = new Text();
//    tree.openScope();
//    StringBuilder s = new StringBuilder();
//    do {
//    switch (getNextTokenKind()) {
//    case CHAR_SEQUENCE:
//    s.append(consumeToken(CHAR_SEQUENCE).image);
//    break;
//    case BACKSLASH:
//    s.append(consumeToken(BACKSLASH).image);
//    break;
//    case COLON:
//    s.append(consumeToken(COLON).image);
//    break;
//    case DASH:
//    s.append(consumeToken(DASH).image);
//    break;
//    case DIGITS:
//    s.append(consumeToken(DIGITS).image);
//    break;
//    case DOT:
//    s.append(consumeToken(DOT).image);
//    break;
//    case EQ:
//    s.append(consumeToken(EQ).image);
//    break;
//    case ESCAPED_CHAR:
//    s.append(consumeToken(ESCAPED_CHAR).image.substring(1));
//    break;
//    case IMAGE_LABEL:
//    s.append(consumeToken(IMAGE_LABEL).image);
//    break;
//    case GT:
//    s.append(consumeToken(GT).image);
//    break;
//    case LPAREN:
//    s.append(consumeToken(LPAREN).image);
//    break;
//    case LT:
//    s.append(consumeToken(LT).image);
//    break;
//    case RPAREN:
//    s.append(consumeToken(RPAREN).image);
//    break;
//    default:
//    if (!nextAfterSpace(RBRACK)) {
//    switch (getNextTokenKind()) {
//    case SPACE:
//    s.append(consumeToken(SPACE).image);
//    break;
//    case TAB:
//    consumeToken(TAB);
//    s.append("    ");
//    break;
//    }
//    }
//    }
//    } while (resourceHasElementAhead());
//    text.setValue(s.toString());
//    tree.closeScope(text);
    }
   
    func resourceUrl() -> String {
//    consumeToken(LPAREN);
        whiteSpace()
        let ref = "" //resourceUrlText();
        whiteSpace()
//    consumeToken(RPAREN);
        return ref;
    }
    
    func resourceUrlText() -> String {
//    StringBuilder s = new StringBuilder();
//    while (resourceTextHasElementsAhead()) {
//    switch (getNextTokenKind()) {
//    case CHAR_SEQUENCE:
//    s.append(consumeToken(CHAR_SEQUENCE).image);
//    break;
//    case ASTERISK:
//    s.append(consumeToken(ASTERISK).image);
//    break;
//    case BACKSLASH:
//    s.append(consumeToken(BACKSLASH).image);
//    break;
//    case BACKTICK:
//    s.append(consumeToken(BACKTICK).image);
//    break;
//    case COLON:
//    s.append(consumeToken(COLON).image);
//    break;
//    case DASH:
//    s.append(consumeToken(DASH).image);
//    break;
//    case DIGITS:
//    s.append(consumeToken(DIGITS).image);
//    break;
//    case DOT:
//    s.append(consumeToken(DOT).image);
//    break;
//    case EQ:
//    s.append(consumeToken(EQ).image);
//    break;
//    case ESCAPED_CHAR:
//    s.append(consumeToken(ESCAPED_CHAR).image.substring(1));
//    break;
//    case IMAGE_LABEL:
//    s.append(consumeToken(IMAGE_LABEL).image);
//    break;
//    case GT:
//    s.append(consumeToken(GT).image);
//    break;
//    case LBRACK:
//    s.append(consumeToken(LBRACK).image);
//    break;
//    case LPAREN:
//    s.append(consumeToken(LPAREN).image);
//    break;
//    case LT:
//    s.append(consumeToken(LT).image);
//    break;
//    case RBRACK:
//    s.append(consumeToken(RBRACK).image);
//    break;
//    case UNDERSCORE:
//    s.append(consumeToken(UNDERSCORE).image);
//    break;
//    default:
//    if (!nextAfterSpace(RPAREN)) {
//    switch (getNextTokenKind()) {
//    case SPACE:
//    s.append(consumeToken(SPACE).image);
//    break;
//    case TAB:
//    consumeToken(TAB);
//    s.append("    ");
//    break;
//    }
//    }
//    }
//    }
//    return s.toString();
        return ""
    }
    
    func strongMultiline() {
//    Strong strong = new Strong();
//    tree.openScope();
//    consumeToken(ASTERISK);
//    strongMultilineContent();
//    while (textAhead()) {
//    lineBreak();
        whiteSpace()
//    strongMultilineContent();
//    }
//    consumeToken(ASTERISK);
//    tree.closeScope(strong);
    }

    func strongMultilineContent() {
//    do {
//    if (hasTextAhead()) {
//    text();
//    } else if (modules.contains("images") && hasImageAhead()) {
//    image();
//    } else if (modules.contains("links") && hasLinkAhead()) {
//    link();
//    } else if (modules.contains("code") && hasCodeAhead()) {
//    code();
//    } else if (hasEmWithinStrongMultiline()) {
//    emWithinStrongMultiline();
//    } else {
//    switch (getNextTokenKind()) {
//    case BACKTICK:
//    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
//    break;
//    case LBRACK:
//    tree.addSingleValue(new Text(), consumeToken(LBRACK));
//    break;
//    case UNDERSCORE:
//    tree.addSingleValue(new Text(), consumeToken(UNDERSCORE));
//    break;
//    }
//    }
//    } while (strongMultilineHasElementsAhead());
    }
    
    func strongWithinEmMultiline() {
//    Strong strong = new Strong();
//    tree.openScope();
//    consumeToken(ASTERISK);
//    strongWithinEmMultilineContent();
//    while (textAhead()) {
//    lineBreak();
//    strongWithinEmMultilineContent();
//    }
//    consumeToken(ASTERISK);
//    tree.closeScope(strong);
    }

    func strongWithinEmMultilineContent() {
//    do {
//    if (hasTextAhead()) {
//    text();
//    } else if (modules.contains("images") && hasImageAhead()) {
//    image();
//    } else if (modules.contains("links") && hasLinkAhead()) {
//    link();
//    } else if (modules.contains("code") && hasCodeAhead()) {
//    code();
//    } else {
//    switch (getNextTokenKind()) {
//    case BACKTICK:
//    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
//    break;
//    case LBRACK:
//    tree.addSingleValue(new Text(), consumeToken(LBRACK));
//    break;
//    case UNDERSCORE:
//    tree.addSingleValue(new Text(), consumeToken(UNDERSCORE));
//    break;
//    }
//    }
//    } while (strongWithinEmMultilineHasElementsAhead());
    }
    
    func strongWithinEm() {
//    Strong strong = new Strong();
//    tree.openScope();
//    consumeToken(ASTERISK);
//    do {
//    if (hasTextAhead()) {
//    text();
//    } else if (modules.contains("images") && hasImageAhead()) {
//    image();
//    } else if (modules.contains("links") && hasLinkAhead()) {
//    link();
//    } else if (modules.contains("code") && hasCodeAhead()) {
//    code();
//    } else {
//    switch (getNextTokenKind()) {
//    case BACKTICK:
//    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
//    break;
//    case LBRACK:
//    tree.addSingleValue(new Text(), consumeToken(LBRACK));
//    break;
//    case UNDERSCORE:
//    tree.addSingleValue(new Text(), consumeToken(UNDERSCORE));
//    break;
//    }
//    }
//    } while (strongWithinEmHasElementsAhead());
//    consumeToken(ASTERISK);
//    tree.closeScope(strong);
    }
   
    func emMultiline() {
//    Em em = new Em();
//    tree.openScope();
//    consumeToken(UNDERSCORE);
//    emMultilineContent();
//    while (textAhead()) {
//    lineBreak();
        whiteSpace()
//    emMultilineContent();
//    }
//    consumeToken(UNDERSCORE);
//    tree.closeScope(em);
    }
    
    func emMultilineContent() {
//    do {
//    if (hasTextAhead()) {
//    text();
//    } else if (modules.contains("images") && hasImageAhead()) {
//    image();
//    } else if (modules.contains("links") && hasLinkAhead()) {
//    link();
//    } else if (modules.contains("code") && multilineAhead(BACKTICK)) {
//    codeMultiline();
//    } else if (hasStrongWithinEmMultilineAhead()) {
//    strongWithinEmMultiline();
//    } else {
//    switch (getNextTokenKind()) {
//    case ASTERISK:
//    tree.addSingleValue(new Text(), consumeToken(ASTERISK));
//    break;
//    case BACKTICK:
//    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
//    break;
//    case LBRACK:
//    tree.addSingleValue(new Text(), consumeToken(LBRACK));
//    break;
//    }
//    }
//    } while (emMultilineContentHasElementsAhead());
    }
    
    func emWithinStrongMultiline() {
//    Em em = new Em();
//    tree.openScope();
//    consumeToken(UNDERSCORE);
//    emWithinStrongMultilineContent();
//    while (textAhead()) {
//    lineBreak();
//    emWithinStrongMultilineContent();
//    }
//    consumeToken(UNDERSCORE);
//    tree.closeScope(em);
    }
    
    func emWithinStrongMultilineContent() {
//    do {
//    if (hasTextAhead()) {
//    text();
//    } else if (modules.contains("images") && hasImageAhead()) {
//    image();
//    } else if (modules.contains("links") && hasLinkAhead()) {
//    link();
//    } else if (modules.contains("code") && hasCodeAhead()) {
//    code();
//    } else {
//    switch (getNextTokenKind()) {
//    case ASTERISK:
//    tree.addSingleValue(new Text(), consumeToken(ASTERISK));
//    break;
//    case BACKTICK:
//    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
//    break;
//    case LBRACK:
//    tree.addSingleValue(new Text(), consumeToken(LBRACK));
//    break;
//    }
//    }
//    } while (emWithinStrongMultilineContentHasElementsAhead());
    }
    
    func emWithinStrong() {
//    Em em = new Em();
//    tree.openScope();
//    consumeToken(UNDERSCORE);
//    do {
//    if (hasTextAhead()) {
//    text();
//    } else if (modules.contains("images") && hasImageAhead()) {
//    image();
//    } else if (modules.contains("links") && hasLinkAhead()) {
//    link();
//    } else if (modules.contains("code") && hasCodeAhead()) {
//    code();
//    } else {
//    switch (getNextTokenKind()) {
//    case ASTERISK:
//    tree.addSingleValue(new Text(), consumeToken(ASTERISK));
//    break;
//    case BACKTICK:
//    tree.addSingleValue(new Text(), consumeToken(BACKTICK));
//    break;
//    case LBRACK:
//    tree.addSingleValue(new Text(), consumeToken(LBRACK));
//    break;
//    }
//    }
//    } while (emWithinStrongHasElementsAhead());
//    consumeToken(UNDERSCORE);
//    tree.closeScope(em);
    }
   
    func codeMultiline() {
//    Code code = new Code();
//    tree.openScope();
//    consumeToken(BACKTICK);
//    codeText();
//    while (textAhead()) {
//    lineBreak();
        whiteSpace()
//    while (getNextTokenKind() == GT) {
//    consumeToken(GT);
        whiteSpace()
//    }
//    codeText();
//    }
//    consumeToken(BACKTICK);
//    tree.closeScope(code);
    }
    
    func whiteSpace() {
//    while (getNextTokenKind() == SPACE || getNextTokenKind() == TAB) {
//    consumeToken(getNextTokenKind());
//    }
    }
    
    func hasAnyBlockElementsAhead() -> Bool {
//    try {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    return !scanMoreBlockElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
    
    func blockAhead(blockBeginColumn : Int) -> Bool {
//    int quoteLevel;
//    
//    if (getNextTokenKind() == EOL) {
//    Token t;
//    int i = 2;
//    quoteLevel = 0;
//    do {
//    quoteLevel = 0;
//    do {
//    t = getToken(i++);
//    if (t.kind == GT) {
//    if (t.beginColumn == 1 && currentBlockLevel > 0 && currentQuoteLevel == 0) {
//    return false;
//    }
//    quoteLevel++;
//    }
//    } while (t.kind == GT || t.kind == SPACE || t.kind == TAB);
//    if (quoteLevel > currentQuoteLevel) {
//    return true;
//    }
//    if (quoteLevel < currentQuoteLevel) {
//    return false;
//    }
//    } while (t.kind == EOL);
//    return t.kind != EOF && (currentBlockLevel == 0 || t.beginColumn >= blockBeginColumn + 2);
//    }
        return false;
    }
    
    func multilineAhead(token : Int) -> Bool {
//    if (getNextTokenKind() == token && getToken(2).kind != token && getToken(2).kind != EOL) {
//    
//    for (int i = 2;; i++) {
//    Token t = getToken(i);
//    if (t.kind == token) {
//    return true;
//    } else if (t.kind == EOL) {
//    i = skip(i + 1, SPACE, TAB);
//    int quoteLevel = newQuoteLevel(i);
//    if (quoteLevel == currentQuoteLevel) {
//    i = skip(i, SPACE, TAB, GT);
//    if (getToken(i).kind == token || getToken(i).kind == EOL || getToken(i).kind == DASH
//    || (getToken(i).kind == DIGITS && getToken(i + 1).kind == DOT)
//    || (getToken(i).kind == BACKTICK && getToken(i + 1).kind == BACKTICK
//    && getToken(i + 2).kind == BACKTICK)
//    || headingAhead(i)) {
//    return false;
//    }
//    } else {
//    return false;
//    }
//    } else if (t.kind == EOF) {
//    return false;
//    }
//    }
//    }
        return false;
    }

    func fencesAhead() -> Bool {
        var i = skip(2, tokens: [TokenManager.SPACE, TokenManager.TAB, TokenManager.GT]);
//    if (getToken(i).kind == BACKTICK && getToken(i + 1).kind == BACKTICK && getToken(i + 2).kind == BACKTICK) {
//    i = skip(i + 3, SPACE, TAB);
//    return getToken(i).kind == EOL || getToken(i).kind == EOF;
//    }
        return false;
    }

    func headingAhead(offset : Int) -> Bool {
//    if (getToken(offset).kind == EQ) {
//    int heading = 1;
//    for (int i = (offset + 1);; i++) {
//    if (getToken(i).kind != EQ) {
//    return true;
//    }
//    if (++heading > 6) {
//    return false;
//    }
//    }
//    }
        return false
    }

    func listItemAhead(listBeginColumn : Int, ordered : Bool) -> Bool {
//    if (getNextTokenKind() == EOL) {
//    for (int i = 2, eol = 1;; i++) {
//    Token t = getToken(i);
//    
//    if (t.kind == EOL && ++eol > 2) {
//    return false;
//    } else if (t.kind != SPACE && t.kind != TAB && t.kind != GT && t.kind != EOL) {
//    if (ordered) {
//    return (t.kind == DIGITS && getToken(i + 1).kind == DOT && t.beginColumn >= listBeginColumn);
//    }
//    return t.kind == DASH && t.beginColumn >= listBeginColumn;
//    }
//    }
//    }
        return false;
    }

    func textAhead() -> Bool {
//    if (getNextTokenKind() == EOL && getToken(2).kind != EOL) {
//    int i = skip(2, SPACE, TAB);
//    int quoteLevel = newQuoteLevel(i);
//    if (quoteLevel == currentQuoteLevel || !modules.contains("blockquotes")) {
//    i = skip(i, SPACE, TAB, GT);
//    
//    Token t = getToken(i);
//    return getToken(i).kind != EOL && !(modules.contains("lists") && t.kind == DASH)
//    && !(modules.contains("lists") && t.kind == DIGITS && getToken(i + 1).kind == DOT)
//    && !(getToken(i).kind == BACKTICK && getToken(i + 1).kind == BACKTICK
//    && getToken(i + 2).kind == BACKTICK)
//    && !(modules.contains("headings") && headingAhead(i));
//    }
//    }
        return false
    }

    func nextAfterSpace(tokens : Int...) {
        var i : Int = skip(1, tokens: [TokenManager.SPACE, TokenManager.TAB])
//    return Arrays.asList(tokens).contains(getToken(i).kind);
    }

    func newQuoteLevel(offset : Int) -> Int {
//    int quoteLevel = 0;
//    for (int i = offset;; i++) {
//    Token t = getToken(i);
//    if (t.kind == GT) {
//    quoteLevel++;
//    } else if (t.kind != SPACE && t.kind != TAB) {
        return 0 //    return quoteLevel;
//    }
//    
//    }
    }
    
    func skip(offset : Int, tokens : [Int]) -> Int {
//    List<Integer> tokenList = Arrays.asList(tokens);
//    for (int i = offset;; i++) {
//    Token t = getToken(i);
//    if (!tokenList.contains(t.kind)) {
        return 0 //    return i;
//    }
//    }
    }
    
    func hasOrderedListAhead() -> Bool {
//    lookAhead = 2;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanToken(DIGITS) && !scanToken(DOT);
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasFencedCodeBlockAhead() -> Bool {
//    lookAhead = 3;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanFencedCodeBlock();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
  
    func headingHasInlineElementsAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    if (scanStrong()) {
//    scanPosition = xsp;
//    if (scanEm()) {
//    scanPosition = xsp;
//    if (scanCode()) {
//    scanPosition = xsp;
//    if (scanLooseChar()) {
//    return false;
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    return true;
//    } catch (LookaheadSuccess ls) {
        return true;
//    }
    }

    func hasTextAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanTextTokens();
//    } catch (LookaheadSuccess ls) {
        return true;
//    }
    }

    func hasImageAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanImage();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
    
    func blockQuoteHasEmptyLineAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanBlockQuoteEmptyLine();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasStrongAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanStrong();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
 
    func hasEmAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanEm();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasCodeAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanCode();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
    
    func blockQuoteHasAnyBlockElementseAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanMoreBlockElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasBlockQuoteEmptyLinesAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanBlockQuoteEmptyLines();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func listItemHasInlineElements() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanMoreBlockElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
  
    func hasInlineTextAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanTextTokens();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasInlineElementAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanInlineElement();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func imageHasAnyElements() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanImageElement();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
 
    func hasResourceTextAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanResourceElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func linkHasAnyElements() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanLinkElement();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasResourceUrlAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanResourceUrl();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func resourceHasElementAhead() -> Bool {
//    lookAhead = 2;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanResourceElement();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
   
    func resourceTextHasElementsAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanResourceTextElement();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasEmWithinStrongMultiline() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanEmWithinStrongMultiline();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
    
    func strongMultilineHasElementsAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanStrongMultilineElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func strongWithinEmMultilineHasElementsAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanStrongWithinEmMultilineElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasImage() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanImage();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasLinkAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanLink();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func strongEmWithinStrongAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanEmWithinStrong();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func strongHasElements() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanStrongElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func strongWithinEmHasElementsAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanStrongWithinEmElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasStrongWithinEmMultilineAhead() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanStrongWithinEmMultiline();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func emMultilineContentHasElementsAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanEmMultilineContentElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func emWithinStrongMultilineContentHasElementsAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanEmWithinStrongMultilineContent();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func emHasStrongWithinEm() -> Bool {
//    lookAhead = 2147483647;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanStrongWithinEm();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func emHasElements() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanEmElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func emWithinStrongHasElementsAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanEmWithinStrongElements();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
    
    func codeTextHasAnyTokenAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanCodeTextTokens();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func textHasTokensAhead() -> Bool {
//    lookAhead = 1;
//    lastPosition = scanPosition = token;
//    try {
//    return !scanText();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
   
    func scanLooseChar() -> Bool {
//    Token xsp = scanPosition;
//    if (scanToken(ASTERISK)) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    if (scanToken(LBRACK)) {
//    scanPosition = xsp;
//    return scanToken(UNDERSCORE);
//    }
//    }
//    }
        return false
    }

    func scanText() -> Bool {
//    Token xsp = scanPosition;
//    if (scanToken(BACKSLASH)) {
//    scanPosition = xsp;
//    if (scanToken(CHAR_SEQUENCE)) {
//    scanPosition = xsp;
//    if (scanToken(COLON)) {
//    scanPosition = xsp;
//    if (scanToken(DASH)) {
//    scanPosition = xsp;
//    if (scanToken(DIGITS)) {
//    scanPosition = xsp;
//    if (scanToken(DOT)) {
//    scanPosition = xsp;
//    if (scanToken(EQ)) {
//    scanPosition = xsp;
//    if (scanToken(ESCAPED_CHAR)) {
//    scanPosition = xsp;
//    if (scanToken(GT)) {
//    scanPosition = xsp;
//    if (scanToken(IMAGE_LABEL)) {
//    scanPosition = xsp;
//    if (scanToken(LPAREN)) {
//    scanPosition = xsp;
//    if (scanToken(LT)) {
//    scanPosition = xsp;
//    if (scanToken(RBRACK)) {
//    scanPosition = xsp;
//    if (scanToken(RPAREN)) {
//    scanPosition = xsp;
//    lookingAhead = true;
//    semanticLookAhead = !nextAfterSpace(EOL, EOF);
//    lookingAhead = false;
//    return (!semanticLookAhead || scanWhitspaceToken());
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanTextTokens() -> Bool {
//    if (scanText()) {
//    return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanText()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
        return false
    }

    func scanCodeTextTokens() -> Bool {
//    Token xsp = scanPosition;
//    if (scanToken(ASTERISK)) {
//    scanPosition = xsp;
//    if (scanToken(BACKSLASH)) {
//    scanPosition = xsp;
//    if (scanToken(CHAR_SEQUENCE)) {
//    scanPosition = xsp;
//    if (scanToken(COLON)) {
//    scanPosition = xsp;
//    if (scanToken(DASH)) {
//    scanPosition = xsp;
//    if (scanToken(DIGITS)) {
//    scanPosition = xsp;
//    if (scanToken(DOT)) {
//    scanPosition = xsp;
//    if (scanToken(EQ)) {
//    scanPosition = xsp;
//    if (scanToken(ESCAPED_CHAR)) {
//    scanPosition = xsp;
//    if (scanToken(IMAGE_LABEL)) {
//    scanPosition = xsp;
//    if (scanToken(LT)) {
//    scanPosition = xsp;
//    if (scanToken(LBRACK)) {
//    scanPosition = xsp;
//    if (scanToken(RBRACK)) {
//    scanPosition = xsp;
//    if (scanToken(LPAREN)) {
//    scanPosition = xsp;
//    if (scanToken(GT)) {
//    scanPosition = xsp;
//    if (scanToken(RPAREN)) {
//    scanPosition = xsp;
//    if (scanToken(UNDERSCORE)) {
//    scanPosition = xsp;
//    lookingAhead = true;
//    semanticLookAhead = !nextAfterSpace(EOL,
//    EOF);
//    lookingAhead = false;
//    return (!semanticLookAhead
//    || scanWhitspaceToken());
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanCode() -> Bool {
//    return scanToken(BACKTICK) || scanCodeTextTokensAhead() || scanToken(BACKTICK);
    return false
    }

    func scanCodeMultiline() -> Bool {
//    if (scanToken(BACKTICK) || scanCodeTextTokensAhead()) {
        return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (hasCodeTextOnNextLineAhead()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    return scanToken(BACKTICK);
    }

    func scanCodeTextTokensAhead() -> Bool {
//    if (scanCodeTextTokens()) {
//    return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanCodeTextTokens()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
        return false
    }

    func hasCodeTextOnNextLineAhead() -> Bool {
//    if (scanWhitespaceTokenBeforeEol()) {
        return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanToken(GT)) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    return scanCodeTextTokensAhead();
    }

    func scanWhitspaceTokens() -> Bool{
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanWhitspaceToken()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
        return false
//    }
//    
//    private boolean scanWhitespaceTokenBeforeEol() {
//    return scanWhitspaceTokens() || scanToken(EOL);
    }

    func scanEmWithinStrongElements() -> Bool {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    if (scanCode()) {
//    scanPosition = xsp;
//    if (scanToken(ASTERISK)) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    return scanToken(LBRACK);
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanEmWithinStrong() -> Bool {
//    if (scanToken(UNDERSCORE) || scanEmWithinStrongElements()) {
        return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanEmWithinStrongElements()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    return scanToken(UNDERSCORE);
    }

    func scanEmElements() -> Bool {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    if (scanCode()) {
//    scanPosition = xsp;
//    if (scanStrongWithinEm()) {
//    scanPosition = xsp;
//    if (scanToken(ASTERISK)) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    return scanToken(LBRACK);
//    }
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanEm() -> Bool {
//    if (scanToken(UNDERSCORE) || scanEmElements()) {
        return true
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanEmElements()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    return scanToken(UNDERSCORE);
    }

    func scanEmWithinStrongMultilineContent() -> Bool {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    if (scanCode()) {
//    scanPosition = xsp;
//    if (scanToken(ASTERISK)) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    return scanToken(LBRACK);
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func hasNoEmWithinStrongMultilineContentAhead() -> Bool {
//    if (scanEmWithinStrongMultilineContent()) {
//    return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanEmWithinStrongMultilineContent()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
        return false
    }

    func scanEmWithinStrongMultiline() -> Bool {
//    if (scanToken(UNDERSCORE) || hasNoEmWithinStrongMultilineContentAhead()) {
        return true
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanWhitespaceTokenBeforeEol() || hasNoEmWithinStrongMultilineContentAhead()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    return scanToken(UNDERSCORE);
    }

    func scanEmMultilineContentElements() -> Bool {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    lookingAhead = true;
//    semanticLookAhead = multilineAhead(BACKTICK);
//    lookingAhead = false;
//    if (!semanticLookAhead || scanCodeMultiline()) {
//    scanPosition = xsp;
//    if (scanStrongWithinEmMultiline()) {
//    scanPosition = xsp;
//    if (scanToken(ASTERISK)) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    return scanToken(LBRACK);
//    }
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanStrongWithinEmElements() -> Bool {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    if (scanCode()) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    if (scanToken(LBRACK)) {
//    scanPosition = xsp;
//    return scanToken(UNDERSCORE);
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanStrongWithinEm() -> Bool {
//    if (scanToken(ASTERISK) || scanStrongWithinEmElements()) {
        return true
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanStrongWithinEmElements()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    return scanToken(ASTERISK);
    }

    func scanStrongElements() -> Bool {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    lookingAhead = true;
//    semanticLookAhead = multilineAhead(BACKTICK);
//    lookingAhead = false;
//    if (!semanticLookAhead || scanCodeMultiline()) {
//    scanPosition = xsp;
//    if (scanEmWithinStrong()) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    if (scanToken(LBRACK)) {
//    scanPosition = xsp;
//    return scanToken(UNDERSCORE);
//    }
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanStrong() -> Bool {
//    if (scanToken(ASTERISK) || scanStrongElements()) {
        return true
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanStrongElements()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    return scanToken(ASTERISK);
    }

    func scanStrongWithinEmMultilineElements() -> Bool {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    if (scanCode()) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    if (scanToken(LBRACK)) {
//    scanPosition = xsp;
//    return scanToken(UNDERSCORE);
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanForMoreStrongWithinEmMultilineElements() -> Bool {
//    if (scanStrongWithinEmMultilineElements()) {
//    return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanStrongWithinEmMultilineElements()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
        return false
    }

    func scanStrongWithinEmMultiline() -> Bool {
//    if (scanToken(ASTERISK) || scanForMoreStrongWithinEmMultilineElements()) {
        return true
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanWhitespaceTokenBeforeEol() || scanForMoreStrongWithinEmMultilineElements()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    return scanToken(ASTERISK);
    }

    func scanStrongMultilineElements() -> Bool {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    if (scanCode()) {
//    scanPosition = xsp;
//    if (scanEmWithinStrongMultiline()) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    if (scanToken(LBRACK)) {
//    scanPosition = xsp;
//    return scanToken(UNDERSCORE);
//    }
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanResourceTextElement() -> Bool {
//    Token xsp = scanPosition;
//    if (scanToken(ASTERISK)) {
//    scanPosition = xsp;
//    if (scanToken(BACKSLASH)) {
//    scanPosition = xsp;
//    if (scanToken(BACKTICK)) {
//    scanPosition = xsp;
//    if (scanToken(CHAR_SEQUENCE)) {
//    scanPosition = xsp;
//    if (scanToken(COLON)) {
//    scanPosition = xsp;
//    if (scanToken(DASH)) {
//    scanPosition = xsp;
//    if (scanToken(DIGITS)) {
//    scanPosition = xsp;
//    if (scanToken(DOT)) {
//    scanPosition = xsp;
//    if (scanToken(EQ)) {
//    scanPosition = xsp;
//    if (scanToken(ESCAPED_CHAR)) {
//    scanPosition = xsp;
//    if (scanToken(IMAGE_LABEL)) {
//    scanPosition = xsp;
//    if (scanToken(GT)) {
//    scanPosition = xsp;
//    if (scanToken(LBRACK)) {
//    scanPosition = xsp;
//    if (scanToken(LPAREN)) {
//    scanPosition = xsp;
//    if (scanToken(LT)) {
//    scanPosition = xsp;
//    if (scanToken(RBRACK)) {
//    scanPosition = xsp;
//    if (scanToken(UNDERSCORE)) {
//    scanPosition = xsp;
//    lookingAhead = true;
//    semanticLookAhead = !nextAfterSpace(RPAREN);
//    lookingAhead = false;
//    return (!semanticLookAhead
//    || scanWhitspaceToken());
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanImageElement() -> Bool {
//    Token xsp = scanPosition;
//    if (scanResourceElements()) {
//    scanPosition = xsp;
//    if (scanLooseChar()) {
//    return true;
//    }
//    }
        return false
    }

    func scanResourceTextElements() -> Bool {
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanResourceTextElement()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
        return false
    }

    func scanResourceUrl() -> Bool {
//    return scanToken(LPAREN) || scanWhitspaceTokens() || scanResourceTextElements() || scanWhitspaceTokens()
//    || scanToken(RPAREN);
        return false
    }

    func scanLinkElement() -> Bool {
//    Token xsp = scanPosition;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanStrong()) {
//    scanPosition = xsp;
//    if (scanEm()) {
//    scanPosition = xsp;
//    if (scanCode()) {
//    scanPosition = xsp;
//    if (scanResourceElements()) {
//    scanPosition = xsp;
//    return scanLooseChar();
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanResourceElement() -> Bool {
//    Token xsp = scanPosition;
//    if (scanToken(BACKSLASH)) {
//    scanPosition = xsp;
//    if (scanToken(COLON)) {
//    scanPosition = xsp;
//    if (scanToken(CHAR_SEQUENCE)) {
//    scanPosition = xsp;
//    if (scanToken(DASH)) {
//    scanPosition = xsp;
//    if (scanToken(DIGITS)) {
//    scanPosition = xsp;
//    if (scanToken(DOT)) {
//    scanPosition = xsp;
//    if (scanToken(EQ)) {
//    scanPosition = xsp;
//    if (scanToken(ESCAPED_CHAR)) {
//    scanPosition = xsp;
//    if (scanToken(IMAGE_LABEL)) {
//    scanPosition = xsp;
//    if (scanToken(GT)) {
//    scanPosition = xsp;
//    if (scanToken(LPAREN)) {
//    scanPosition = xsp;
//    if (scanToken(LT)) {
//    scanPosition = xsp;
//    if (scanToken(RPAREN)) {
//    scanPosition = xsp;
//    lookingAhead = true;
//    semanticLookAhead = !nextAfterSpace(RBRACK);
//    lookingAhead = false;
//    return (!semanticLookAhead || scanWhitspaceToken());
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanResourceElements() -> Bool {
//    if (scanResourceElement()) {
//    return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanResourceElement()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
        return false
    }

    func scanLink() -> Bool {
//    if (scanToken(LBRACK) || scanWhitspaceTokens() || scanLinkElement()) {
//    return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanLinkElement()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    if (scanWhitspaceTokens() || scanToken(RBRACK)) {
//    return true;
//    }
//    xsp = scanPosition;
//    if (scanResourceUrl()) {
//    scanPosition = xsp;
//    }
        return false
    }

    func scanImage() -> Bool {
//    if (scanToken(LBRACK) || scanWhitspaceTokens() || scanToken(IMAGE_LABEL) || scanImageElement()) {
//    return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanImageElement()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    if (scanWhitspaceTokens() || scanToken(RBRACK)) {
//    return true;
//    }
//    xsp = scanPosition;
//    if (scanResourceUrl()) {
//    scanPosition = xsp;
//    }
        return false
    }

    func scanInlineElement() -> Bool {
//    Token xsp = scanPosition;
//    if (scanTextTokens()) {
//    scanPosition = xsp;
//    if (scanImage()) {
//    scanPosition = xsp;
//    if (scanLink()) {
//    scanPosition = xsp;
//    lookingAhead = true;
//    semanticLookAhead = multilineAhead(ASTERISK);
//    lookingAhead = false;
//    if (!semanticLookAhead || scanToken(ASTERISK)) {
//    scanPosition = xsp;
//    lookingAhead = true;
//    semanticLookAhead = multilineAhead(UNDERSCORE);
//    lookingAhead = false;
//    if (!semanticLookAhead || scanToken(UNDERSCORE)) {
//    scanPosition = xsp;
//    lookingAhead = true;
//    semanticLookAhead = multilineAhead(BACKTICK);
//    lookingAhead = false;
//    if (!semanticLookAhead || scanCodeMultiline()) {
//    scanPosition = xsp;
//    return scanLooseChar();
//    }
//    }
//    }
//    }
//    }
//    }
        return false
    }

    func scanParagraph() -> Bool {
//    Token xsp;
//    if (scanInlineElement()) {
//    return true;
//    }
//    while (true) {
//    xsp = scanPosition;
//    if (scanInlineElement()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
        return false
    }

    func scanWhitspaceToken() -> Bool {
//    Token xsp = scanPosition;
//    if (scanToken(SPACE)) {
//    scanPosition = xsp;
//    if (scanToken(TAB)) {
//    return true;
//    }
//    }
        return false
    }

    func scanFencedCodeBlock() -> Bool {
//    return scanToken(BACKTICK) || scanToken(BACKTICK) || scanToken(BACKTICK);
        return false
}

    func scanBlockQuoteEmptyLines() -> Bool {
//    return scanBlockQuoteEmptyLine() || scanToken(EOL);
        return false
}

    func scanBlockQuoteEmptyLine() -> Bool {
//    if (scanToken(EOL) || scanWhitspaceTokens() || scanToken(GT) || scanWhitspaceTokens()) {
        return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanToken(GT) || scanWhitspaceTokens()) {
//    scanPosition = xsp;
//    break;
//    }
//    }
//    return false;
    }

    func scanForHeadersigns() -> Bool {
//    if (scanToken(EQ)) {
//    return true;
//    }
//    Token xsp;
//    while (true) {
//    xsp = scanPosition;
//    if (scanToken(EQ)) {
//    scanPosition = xsp;
//    break;
//    }
//    }
        return false
    }

    func scanMoreBlockElements() -> Bool {
//    Token xsp = scanPosition;
//    lookingAhead = true;
//    semanticLookAhead = headingAhead(1);
//    lookingAhead = false;
//    if (!semanticLookAhead || scanForHeadersigns()) {
//    scanPosition = xsp;
//    if (scanToken(GT)) {
//    scanPosition = xsp;
//    if (scanToken(DASH)) {
//    scanPosition = xsp;
//    if (scanToken(DIGITS) || scanToken(DOT)) {
//    scanPosition = xsp;
//    if (scanFencedCodeBlock()) {
//    scanPosition = xsp;
//    return scanParagraph();
//    }
//    }
//    }
//    }
//    }
        return false
    }
    
    func scanToken(kind : Int) -> Bool {
//    if (scanPosition == lastPosition) {
//    lookAhead--;
//    if (scanPosition.next == null) {
//    lastPosition = scanPosition = scanPosition.next = tm.getNextToken();
//    } else {
//    lastPosition = scanPosition = scanPosition.next;
//    }
//    } else {
//    scanPosition = scanPosition.next;
//    }
//    if (scanPosition.kind != kind) {
//    return true;
//    }
//    if (lookAhead == 0 && scanPosition == lastPosition) {
//    throw lookAheadSuccess;
//    }
        return false
    }

    func getNextTokenKind() -> Int {
//    if (nextTokenKind != -1) {
//    return nextTokenKind;
//    } else if ((nextToken = token.next) == null) {
//    token.next = tm.getNextToken();
//    return (nextTokenKind = token.next.kind);
//    }
//    return (nextTokenKind = nextToken.kind);
        return 0
    }
//    
    func consumeToken(kind : Int) -> Token {
        var old : Token = token;
//    if (token.next != null) {
//    token = token.next;
//    } else {
//    token = token.next = tm.getNextToken();
//    }
//    nextTokenKind = -1;
//    if (token.kind == kind) {
//    return token;
//    }
//    token = old;
//    return token;
        return token
    }
//    
//    private Token getToken(int index) {
//    Token t = lookingAhead ? scanPosition : token;
//    for (int i = 0; i < index; i++) {
//    if (t.next != null) {
//    t = t.next;
//    } else {
//    t = t.next = tm.getNextToken();
//    }
//    }
//    return t;
//    }
//    
//    public void setModules(String... modules) {
//    this.modules = Arrays.asList(modules);
//    }
    
}
