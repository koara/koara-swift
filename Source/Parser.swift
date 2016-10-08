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
    
    func parse(_ text: String) -> Document {
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
    func parseReader(_ reader: Reader) -> Document {
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
        heading.value = headingLevel as AnyObject
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
        repeat {
            consumeToken(TokenManager.GT)
            whiteSpace();
        } while (i + 1) < currentQuoteLevel
    }

    func blockQuoteEmptyLine() {
        consumeToken(TokenManager.EOL)
        whiteSpace()
        repeat {
            consumeToken(TokenManager.GT)
            whiteSpace()
        } while (getNextTokenKind() == TokenManager.GT)
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
        var codeBlock = CodeBlock()
        tree.openScope()
        var s = ""
        var beginColumn = consumeToken(TokenManager.BACKTICK).beginColumn
        repeat {
            consumeToken(TokenManager.BACKTICK)
        } while (getNextTokenKind() == TokenManager.BACKTICK)
        whiteSpace()
        if getNextTokenKind() == TokenManager.CHAR_SEQUENCE {
            codeBlock.language = codeLanguage()
        }
        if (getNextTokenKind() != TokenManager.EOF && !fencesAhead()) {
            consumeToken(TokenManager.EOL)
            levelWhiteSpace(beginColumn)
        }
        var kind = getNextTokenKind()
        while kind != TokenManager.EOF && ((kind != TokenManager.EOL && kind != TokenManager.BACKTICK) || !fencesAhead()) {
            switch kind {
            case TokenManager.CHAR_SEQUENCE:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.ASTERISK:
                s += consumeToken(TokenManager.ASTERISK).image
            case TokenManager.BACKSLASH:
                s += consumeToken(TokenManager.BACKSLASH).image
            case TokenManager.COLON:
                s += consumeToken(TokenManager.COLON).image
            case TokenManager.DASH:
                s += consumeToken(TokenManager.DASH).image
            case TokenManager.DIGITS:
                s += consumeToken(TokenManager.DIGITS).image
            case TokenManager.DOT:
                s += consumeToken(TokenManager.DOT).image
            case TokenManager.EQ:
                s += consumeToken(TokenManager.EQ).image
            case TokenManager.ESCAPED_CHAR:
                s += consumeToken(TokenManager.ESCAPED_CHAR).image
            case TokenManager.IMAGE_LABEL:
                s += consumeToken(TokenManager.IMAGE_LABEL).image
            case TokenManager.LT:
                s += consumeToken(TokenManager.LT).image
            case TokenManager.GT:
                s += consumeToken(TokenManager.GT).image
            case TokenManager.LBRACK:
                s += consumeToken(TokenManager.LBRACK).image
            case TokenManager.RBRACK:
                s += consumeToken(TokenManager.RBRACK).image
            case TokenManager.LPAREN:
                s += consumeToken(TokenManager.LPAREN).image
            case TokenManager.RPAREN:
                s += consumeToken(TokenManager.RPAREN).image
            case TokenManager.UNDERSCORE:
                s += consumeToken(TokenManager.UNDERSCORE).image
            case TokenManager.BACKTICK:
                s += consumeToken(TokenManager.BACKTICK).image
            default:
                if !nextAfterSpace(TokenManager.EOL, TokenManager.EOF) {
                    switch kind {
                    case TokenManager.SPACE:
                        s += consumeToken(TokenManager.SPACE).image
                    case TokenManager.TAB:
                        consumeToken(TokenManager.TAB);
                        s += "    "
                    default: break
                    }
                } else if !fencesAhead() {
                    consumeToken(TokenManager.EOL)
                    s += "\n"
                    levelWhiteSpace(beginColumn)
                }
            }
            kind = getNextTokenKind()
        }
        if fencesAhead() {
            consumeToken(TokenManager.EOL)
            blockQuotePrefix()
            whiteSpace()
            while (getNextTokenKind() == TokenManager.BACKTICK) {
                consumeToken(TokenManager.BACKTICK)
            }
        }
        codeBlock.value = s as AnyObject
        tree.closeScope(codeBlock)
    }
    
    func paragraph() {
        var paragraph = modules.contains("paragraphs") ? Paragraph() : BlockElement()
        tree.openScope()
        inline()
        while textAhead() {
            lineBreak()
            whiteSpace()
            if modules.contains("blockquotes") {
                while (getNextTokenKind() == TokenManager.GT) {
                    consumeToken(TokenManager.GT)
                    whiteSpace()
                }
            }
            inline()
        }
        tree.closeScope(paragraph)
    }
   
    func text() {
        var text = Text()
        tree.openScope()
        var s = ""
        while textHasTokensAhead() {
            switch getNextTokenKind() {
            case TokenManager.CHAR_SEQUENCE:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.BACKSLASH:
                s += consumeToken(TokenManager.BACKSLASH).image
            case TokenManager.COLON:
                s += consumeToken(TokenManager.COLON).image
            case TokenManager.DASH:
                s += consumeToken(TokenManager.DASH).image
            case TokenManager.DIGITS:
                s += consumeToken(TokenManager.DIGITS).image
            case TokenManager.DOT:
                s += consumeToken(TokenManager.DOT).image
            case TokenManager.EQ:
                s += consumeToken(TokenManager.EQ).image
            case TokenManager.ESCAPED_CHAR:
                s += consumeToken(TokenManager.ESCAPED_CHAR).image
            case TokenManager.GT:
                s += consumeToken(TokenManager.GT).image
            case TokenManager.IMAGE_LABEL:
                s += consumeToken(TokenManager.IMAGE_LABEL).image
            case TokenManager.LPAREN:
                s += consumeToken(TokenManager.LPAREN).image
            case TokenManager.LT:
                s += consumeToken(TokenManager.LT).image
            case TokenManager.RBRACK:
                s += consumeToken(TokenManager.RBRACK).image
            case TokenManager.RPAREN:
                s += consumeToken(TokenManager.RPAREN).image
            default:
                if (!nextAfterSpace(TokenManager.EOL, TokenManager.EOF)) {
                    switch getNextTokenKind() {
                    case TokenManager.SPACE:
                        s += consumeToken(TokenManager.SPACE).image
                    case TokenManager.TAB:
                        consumeToken(TokenManager.TAB)
                        s += "    "
                    default: break
                    }
                }
            }
        }
        text.value = s as AnyObject
        tree.closeScope(text)
    }
  
    func image() {
        var image = Image()
        tree.openScope()
        var ref = ""
        consumeToken(TokenManager.LBRACK)
        whiteSpace()
        consumeToken(TokenManager.IMAGE_LABEL)
        whiteSpace()
        while imageHasAnyElements() {
            if hasTextAhead() {
                resourceText()
            } else {
                looseChar()
            }
        }
        whiteSpace()
        consumeToken(TokenManager.RBRACK)
        if hasResourceUrlAhead() {
            ref = resourceUrl()
        }
        image.value = ref as AnyObject
        tree.closeScope(image);
    }
    
    func link() {
        var link = Link()
        tree.openScope()
        var ref = ""
        consumeToken(TokenManager.LBRACK)
        whiteSpace()
        while linkHasAnyElements() {
            if modules.contains("images") && hasImageAhead() {
                image()
            } else if modules.contains("formatting") && hasStrongAhead() {
                strong()
            } else if modules.contains("formatting") && hasEmAhead() {
                em()
            } else if (modules.contains("code") && hasCodeAhead()) {
                code()
            } else if (hasResourceTextAhead()) {
                resourceText()
            } else {
                looseChar()
            }
        }
        whiteSpace()
        consumeToken(TokenManager.RBRACK);
        if hasResourceUrlAhead() {
            ref = resourceUrl()
        }
        link.value = ref as AnyObject
        tree.closeScope(link)
    }
    
    func strong() {
        var strong = Strong()
        tree.openScope()
        consumeToken(TokenManager.ASTERISK)
        while strongHasElements() {
            if hasTextAhead() {
                text()
            } else if modules.contains("images") && hasImage() {
                image()
            } else if modules.contains("links") && hasLinkAhead() {
                link()
            } else if modules.contains("code") && multilineAhead(TokenManager.BACKTICK) {
                codeMultiline()
            } else if strongEmWithinStrongAhead() {
                emWithinStrong();
            } else {
                switch getNextTokenKind() {
                case TokenManager.BACKTICK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.BACKTICK))
                case TokenManager.LBRACK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.LBRACK))
                case TokenManager.UNDERSCORE:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.UNDERSCORE))
                default: break
                }
            }
        }
        consumeToken(TokenManager.ASTERISK);
        tree.closeScope(strong);
    }
  
    func em() {
        var em = Em()
        tree.openScope()
        consumeToken(TokenManager.UNDERSCORE)
        while emHasElements() {
            if hasTextAhead() {
                text()
            } else if modules.contains("images") && hasImage() {
                image()
            } else if modules.contains("links") && hasLinkAhead() {
                link()
            } else if modules.contains("code") && hasCodeAhead() {
                code()
            } else if emHasStrongWithinEm() {
                strongWithinEm()
            } else {
                switch getNextTokenKind() {
                case TokenManager.ASTERISK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.ASTERISK))
                case TokenManager.BACKTICK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.BACKTICK))
                case TokenManager.LBRACK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.LBRACK))
                default: break
                }
            }
        }
        consumeToken(TokenManager.UNDERSCORE);
        tree.closeScope(em);
    }

    func code() {
        var code = Code()
        tree.openScope()
        consumeToken(TokenManager.BACKTICK)
        codeText()
        consumeToken(TokenManager.BACKTICK)
        tree.closeScope(code)
    }

    func codeText() {
        var text = Text()
        tree.openScope()
        var s = ""
        repeat {
            switch getNextTokenKind() {
            case TokenManager.CHAR_SEQUENCE:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.ASTERISK:
                s += consumeToken(TokenManager.ASTERISK).image
            case TokenManager.BACKSLASH:
                s += consumeToken(TokenManager.BACKSLASH).image
            case TokenManager.COLON:
                s += consumeToken(TokenManager.COLON).image
            case TokenManager.DASH:
                s += consumeToken(TokenManager.DASH).image
            case TokenManager.DIGITS:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.DOT:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.EQ:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.ESCAPED_CHAR:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.IMAGE_LABEL:
                s += consumeToken(TokenManager.IMAGE_LABEL).image
            case TokenManager.LT:
                s += consumeToken(TokenManager.LT).image
            case TokenManager.LBRACK:
                s += consumeToken(TokenManager.LBRACK).image
            case TokenManager.RBRACK:
                s += consumeToken(TokenManager.RBRACK).image
            case TokenManager.LPAREN:
                s += consumeToken(TokenManager.LPAREN).image
            case TokenManager.GT:
                s += consumeToken(TokenManager.GT).image
            case TokenManager.RPAREN:
                s += consumeToken(TokenManager.RPAREN).image
            case TokenManager.UNDERSCORE:
                s += consumeToken(TokenManager.UNDERSCORE).image
            default:
                if !nextAfterSpace(TokenManager.EOL, TokenManager.EOF) {
                    switch getNextTokenKind() {
                    case TokenManager.SPACE:
                        s += consumeToken(TokenManager.SPACE).image
                    case TokenManager.TAB:
                        consumeToken(TokenManager.TAB)
                        s += "    "
                    default: break
                }
            }
            }
        } while codeTextHasAnyTokenAhead()
        text.value = s as AnyObject
        tree.closeScope(text)
    }

    func looseChar() {
        var text = Text()
        tree.openScope()
        switch (getNextTokenKind()) {
        case TokenManager.ASTERISK:
            text.value = consumeToken(TokenManager.ASTERISK).image as AnyObject
        case TokenManager.BACKTICK:
            text.value = consumeToken(TokenManager.BACKTICK).image as AnyObject
        case TokenManager.LBRACK:
            text.value = consumeToken(TokenManager.LBRACK).image as AnyObject
        case TokenManager.UNDERSCORE:
            text.value = consumeToken(TokenManager.UNDERSCORE).image as AnyObject
        default: break
        }
        tree.closeScope(text)
    }

    func lineBreak() {
        var linebreak = LineBreak()
        tree.openScope()
        while getNextTokenKind() == TokenManager.SPACE || getNextTokenKind() == TokenManager.TAB {
            consumeToken(getNextTokenKind())
        }
        var t = consumeToken(TokenManager.EOL);
//    linebreak.setExplicit(t.image.startsWith("  "));
        tree.closeScope(linebreak)
    }
  
    func levelWhiteSpace(_ threshold : Int) {
        var currentPos : Int = 1;
        while getNextTokenKind() == TokenManager.GT {
            consumeToken(getNextTokenKind());
        }
        while (getNextTokenKind() == TokenManager.SPACE || getNextTokenKind() == TokenManager.TAB) && currentPos < (threshold - 1) {
            currentPos = consumeToken(getNextTokenKind()).beginColumn;
        }
    }

    func codeLanguage() -> String {
        var s = ""
        repeat {
            switch getNextTokenKind() {
            case TokenManager.CHAR_SEQUENCE:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.ASTERISK:
                s += consumeToken(TokenManager.ASTERISK).image
            case TokenManager.BACKSLASH:
                s += consumeToken(TokenManager.BACKSLASH).image
            case TokenManager.BACKTICK:
                s += consumeToken(TokenManager.BACKTICK).image
            case TokenManager.COLON:
                s += consumeToken(TokenManager.COLON).image
            case TokenManager.DASH:
                s += consumeToken(TokenManager.DASH).image
            case TokenManager.DIGITS:
                s += consumeToken(TokenManager.DIGITS).image
            case TokenManager.DOT:
                s += consumeToken(TokenManager.DOT).image
            case TokenManager.EQ:
                s += consumeToken(TokenManager.EQ).image
            case TokenManager.ESCAPED_CHAR:
                s += consumeToken(TokenManager.ESCAPED_CHAR).image
            case TokenManager.IMAGE_LABEL:
                s += consumeToken(TokenManager.IMAGE_LABEL).image
            case TokenManager.LT:
                s += consumeToken(TokenManager.LT).image
            case TokenManager.GT:
                s += consumeToken(TokenManager.GT).image
            case TokenManager.LBRACK:
                s += consumeToken(TokenManager.LBRACK).image
            case TokenManager.RBRACK:
                s += consumeToken(TokenManager.RBRACK).image
            case TokenManager.LPAREN:
                s += consumeToken(TokenManager.LPAREN).image
            case TokenManager.RPAREN:
                s += consumeToken(TokenManager.RPAREN).image
            case TokenManager.UNDERSCORE:
                s += consumeToken(TokenManager.UNDERSCORE).image
            case TokenManager.SPACE:
                s += consumeToken(TokenManager.SPACE).image
            case TokenManager.TAB:
                s += "    "
            default: break
            }
        } while getNextTokenKind() != TokenManager.EOL && getNextTokenKind() != TokenManager.EOF
        return ""
    }
  
    func inline() {
        repeat {
            if hasInlineTextAhead() {
                text()
            } else if modules.contains("images") && hasImageAhead() {
                image()
            } else if modules.contains("links") && hasLinkAhead() {
                link()
            } else if modules.contains("formatting") && multilineAhead(TokenManager.ASTERISK) {
                strongMultiline()
            } else if modules.contains("formatting") && multilineAhead(TokenManager.UNDERSCORE) {
                emMultiline()
            } else if modules.contains("code") && multilineAhead(TokenManager.BACKTICK) {
                codeMultiline()
            } else {
                looseChar()
            }
        } while hasInlineElementAhead()
    }
   
    func resourceText() {
        var text = Text()
        tree.openScope()
        var s = ""
        repeat {
            switch getNextTokenKind() {
            case TokenManager.CHAR_SEQUENCE:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.BACKSLASH:
                s += consumeToken(TokenManager.BACKSLASH).image
            case TokenManager.COLON:
                s += consumeToken(TokenManager.COLON).image
            case TokenManager.DASH:
                s += consumeToken(TokenManager.DASH).image
            case TokenManager.DIGITS:
                s += consumeToken(TokenManager.DIGITS).image
            case TokenManager.DOT:
                s += consumeToken(TokenManager.DOT).image
            case TokenManager.EQ:
                s += consumeToken(TokenManager.EQ).image
            case TokenManager.ESCAPED_CHAR:
                s += consumeToken(TokenManager.ESCAPED_CHAR).image // substring - 1
            case TokenManager.IMAGE_LABEL:
                s += consumeToken(TokenManager.IMAGE_LABEL).image
            case TokenManager.GT:
                s += consumeToken(TokenManager.GT).image
            case TokenManager.LPAREN:
                s += consumeToken(TokenManager.LPAREN).image
            case TokenManager.LT:
                s += consumeToken(TokenManager.LT).image
            case TokenManager.RPAREN:
                s += consumeToken(TokenManager.RPAREN).image
            default:
                if !nextAfterSpace(TokenManager.RBRACK) {
                    switch getNextTokenKind() {
                    case TokenManager.SPACE:
                        s.append(consumeToken(TokenManager.SPACE).image)
                    case TokenManager.TAB:
                        consumeToken(TokenManager.TAB)
                        s += "    "
                    default: break
                    }
                }
            }
        } while resourceHasElementAhead()
        text.value = s as AnyObject
        tree.closeScope(text)
    }
   
    func resourceUrl() -> String {
        consumeToken(TokenManager.LPAREN)
        whiteSpace()
        let ref = resourceUrlText()
        whiteSpace()
        consumeToken(TokenManager.RPAREN)
        return ref;
    }
    
    func resourceUrlText() -> String {
        var s = ""
        while resourceTextHasElementsAhead() {
            switch getNextTokenKind() {
            case TokenManager.CHAR_SEQUENCE:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.ASTERISK:
                s += consumeToken(TokenManager.ASTERISK).image
            case TokenManager.BACKSLASH:
                s += consumeToken(TokenManager.BACKSLASH).image
            case TokenManager.CHAR_SEQUENCE:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image
            case TokenManager.COLON:
                s += consumeToken(TokenManager.COLON).image
            case TokenManager.DASH:
                s += consumeToken(TokenManager.DASH).image
            case TokenManager.DIGITS:
                s += consumeToken(TokenManager.DIGITS).image
            case TokenManager.DOT:
                s += consumeToken(TokenManager.DOT).image
            case TokenManager.EQ:
                s += consumeToken(TokenManager.EQ).image
            case TokenManager.ESCAPED_CHAR:
                s += consumeToken(TokenManager.ESCAPED_CHAR).image // substring - 1
            case TokenManager.IMAGE_LABEL:
                s += consumeToken(TokenManager.IMAGE_LABEL).image
            case TokenManager.GT:
                s += consumeToken(TokenManager.GT).image
            case TokenManager.LBRACK:
                s += consumeToken(TokenManager.LBRACK).image
            case TokenManager.LPAREN:
                s += consumeToken(TokenManager.LPAREN).image
            case TokenManager.LT:
                s += consumeToken(TokenManager.LT).image
            case TokenManager.RBRACK:
                s += consumeToken(TokenManager.RBRACK).image
            case TokenManager.UNDERSCORE:
                s += consumeToken(TokenManager.UNDERSCORE).image
            default:
                if !nextAfterSpace(TokenManager.RPAREN) {
                    switch getNextTokenKind() {
                    case TokenManager.SPACE:
                        s += consumeToken(TokenManager.SPACE).image
                    case TokenManager.TAB:
                        consumeToken(TokenManager.TAB);
                        s += "    "
                    default: break
                    }
                }
            }
        }
        return s
    }
    
    func strongMultiline() {
        var strong = Strong()
        tree.openScope()
        consumeToken(TokenManager.ASTERISK)
        strongMultilineContent()
        while textAhead() {
            lineBreak()
            whiteSpace()
            strongMultilineContent()
        }
        consumeToken(TokenManager.ASTERISK)
        tree.closeScope(strong)
    }

    func strongMultilineContent() {
        repeat {
            if hasTextAhead() {
                text()
            } else if modules.contains("images") && hasImageAhead() {
                image()
            } else if modules.contains("links") && hasLinkAhead() {
                link()
            } else if modules.contains("code") && hasCodeAhead() {
                code()
            } else if hasEmWithinStrongMultiline() {
                emWithinStrongMultiline()
            } else {
                switch getNextTokenKind() {
                case TokenManager.BACKTICK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.BACKTICK))
                case TokenManager.LBRACK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.LBRACK))
                case TokenManager.UNDERSCORE:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.UNDERSCORE))
                default: break
                }
            }
        } while strongMultilineHasElementsAhead()
    }
    
    func strongWithinEmMultiline() {
        var strong = Strong()
        tree.openScope()
        consumeToken(TokenManager.ASTERISK)
        strongWithinEmMultilineContent()
        while (textAhead()) {
            lineBreak()
            strongWithinEmMultilineContent()
        }
        consumeToken(TokenManager.ASTERISK)
        tree.closeScope(strong);
    }

    func strongWithinEmMultilineContent() {
        repeat {
            if hasTextAhead() {
                text()
            } else if modules.contains("images") && hasImageAhead() {
                image()
            } else if modules.contains("links") && hasLinkAhead() {
                link()
            } else if modules.contains("code") && hasCodeAhead() {
                code()
            } else {
                switch getNextTokenKind() {
                case TokenManager.BACKTICK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.BACKTICK))
                case TokenManager.LBRACK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.LBRACK))
                case TokenManager.UNDERSCORE:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.UNDERSCORE))
                default: break
            }
            }
        } while strongWithinEmMultilineHasElementsAhead()
    }
    
    func strongWithinEm() {
        var strong = Strong()
        tree.openScope()
        consumeToken(TokenManager.ASTERISK);
        repeat {
            if hasTextAhead() {
                text()
            } else if modules.contains("images") && hasImageAhead() {
                image()
            } else if modules.contains("links") && hasLinkAhead() {
                link()
            } else if modules.contains("code") && hasCodeAhead() {
                code()
            } else {
                switch getNextTokenKind() {
                case TokenManager.BACKTICK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.BACKTICK))
                case TokenManager.LBRACK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.LBRACK));
                case TokenManager.UNDERSCORE:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.UNDERSCORE));
                default: break
                }
            }
        } while strongWithinEmHasElementsAhead()
        consumeToken(TokenManager.ASTERISK);
        tree.closeScope(strong);
    }
   
    func emMultiline() {
        var em = Em()
        tree.openScope()
        consumeToken(TokenManager.UNDERSCORE)
        emMultilineContent()
        while (textAhead()) {
            lineBreak()
            whiteSpace()
            emMultilineContent()
        }
        consumeToken(TokenManager.UNDERSCORE);
        tree.closeScope(em);
    }
    
    func emMultilineContent() {
        repeat {
            if hasTextAhead() {
                text()
            } else if modules.contains("images") && hasImageAhead() {
                image()
            } else if modules.contains("links") && hasLinkAhead() {
                link()
            } else if modules.contains("code") && multilineAhead(TokenManager.BACKTICK) {
                codeMultiline()
            } else if hasStrongWithinEmMultilineAhead() {
                strongWithinEmMultiline()
            } else {
                switch getNextTokenKind() {
                case TokenManager.ASTERISK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.ASTERISK))
                case TokenManager.BACKTICK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.BACKTICK));
                case TokenManager.LBRACK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.LBRACK));
                default: break
                }
            }
        } while emMultilineContentHasElementsAhead()
    }
    
    func emWithinStrongMultiline() {
        var em = Em()
        tree.openScope()
        consumeToken(TokenManager.UNDERSCORE)
        emWithinStrongMultilineContent()
        while (textAhead()) {
            lineBreak()
            emWithinStrongMultilineContent()
        }
        consumeToken(TokenManager.UNDERSCORE);
        tree.closeScope(em)
    }
    
    func emWithinStrongMultilineContent() {
        repeat {
            if hasTextAhead() {
                text()
            } else if modules.contains("images") && hasImageAhead() {
                image()
            } else if modules.contains("links") && hasLinkAhead() {
                link()
            } else if modules.contains("code") && hasCodeAhead() {
                code()
            } else {
                switch getNextTokenKind() {
                case TokenManager.ASTERISK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.ASTERISK))
                case TokenManager.BACKTICK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.BACKTICK))
                case TokenManager.LBRACK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.LBRACK))
                default: break
                }
            }
        } while emWithinStrongMultilineContentHasElementsAhead()
    }
    
    func emWithinStrong() {
        var em = Em()
        tree.openScope()
        consumeToken(TokenManager.UNDERSCORE)
        repeat {
            if hasTextAhead() {
                text()
            } else if modules.contains("images") && hasImageAhead() {
                image()
            } else if modules.contains("links") && hasLinkAhead() {
                link()
            } else if modules.contains("code") && hasCodeAhead() {
                code()
            } else {
                switch getNextTokenKind() {
                case TokenManager.ASTERISK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.ASTERISK))
                case TokenManager.BACKTICK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.BACKTICK))
                case TokenManager.LBRACK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.LBRACK))
                default: break
                }
            }
        } while emWithinStrongHasElementsAhead()
        consumeToken(TokenManager.UNDERSCORE);
        tree.closeScope(em);
    }
   
    func codeMultiline() {
        var code = Code()
        tree.openScope()
        consumeToken(TokenManager.BACKTICK)
        codeText()
        while textAhead() {
            lineBreak()
            whiteSpace()
            while getNextTokenKind() == TokenManager.GT {
                consumeToken(TokenManager.GT)
                whiteSpace()
            }
            codeText()
        }
        consumeToken(TokenManager.BACKTICK)
        tree.closeScope(code)
    }
    
    func whiteSpace() {
        while getNextTokenKind() == TokenManager.SPACE || getNextTokenKind() == TokenManager.TAB {
            consumeToken(getNextTokenKind())
        }
    }
    
    func hasAnyBlockElementsAhead() -> Bool {
        do {
            lookAhead = 1
            scanPosition = token
            lastPosition = scanPosition
            return try !scanMoreBlockElements()
        } catch {
            return true
        }
    }
    
    func blockAhead(_ blockBeginColumn : Int) -> Bool {
//    int quoteLevel;
//    
//    if (getNextTokenKind() == EOL) {
        var t : Token
        var i : Int = 2
//    quoteLevel = 0;
        repeat {
//    quoteLevel = 0;
            repeat {
                i += 1
                t = getToken(i)
//    if (t.kind == GT) {
//    if (t.beginColumn == 1 && currentBlockLevel > 0 && currentQuoteLevel == 0) {
//    return false;
//    }
//    quoteLevel++;
//    }
            } while (t.kind == TokenManager.GT || t.kind == TokenManager.SPACE || t.kind == TokenManager.TAB);
//    if (quoteLevel > currentQuoteLevel) {
//    return true;
//    }
//    if (quoteLevel < currentQuoteLevel) {
//    return false;
//    }
        } while (t.kind == TokenManager.EOL);
//    return t.kind != EOF && (currentBlockLevel == 0 || t.beginColumn >= blockBeginColumn + 2);
//    }
        return false;
    }
    
    func multilineAhead(_ token : Int) -> Bool {
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

    func headingAhead(_ offset : Int) -> Bool {
        if getToken(offset).kind == TokenManager.EQ {
            var heading : Int = 1
//    for (int i = (offset + 1);; i++) {
//    if (getToken(i).kind != EQ) {
//    return true;
//    }
//    if (++heading > 6) {
//    return false;
//    }
//    }
        }
        return false
    }

    func listItemAhead(_ listBeginColumn : Int, ordered : Bool) -> Bool {
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

    func nextAfterSpace(_ tokens : Int...) -> Bool {
        let i : Int = skip(1, tokens: [TokenManager.SPACE, TokenManager.TAB])
        return tokens.contains(getToken(i).kind)
    }

    func newQuoteLevel(_ offset : Int) -> Int {
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
    
    func skip(_ offset : Int, tokens : [Int]) -> Int {
//    List<Integer> tokenList = Arrays.asList(tokens);
//    for (int i = offset;; i++) {
//    Token t = getToken(i);
//    if (!tokenList.contains(t.kind)) {
        return 0 //    return i;
//    }
//    }
    }
    
    func hasOrderedListAhead() -> Bool {
        lookAhead = 2
        scanPosition = token
        lastPosition = scanPosition
        //    try {
//    return !scanToken(DIGITS) && !scanToken(DOT);
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }

    func hasFencedCodeBlockAhead() -> Bool {
        lookAhead = 3;
        scanPosition = token
        lastPosition = scanPosition
//    try {
//    return !scanFencedCodeBlock();
//    } catch (LookaheadSuccess ls) {
        return true
//    }
    }
  
    func headingHasInlineElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
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
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanTextTokens()
        } catch {
            return true;
        }
    }

    func hasImageAhead() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanImage()
        } catch {
            return true
        }
    }
    
    func blockQuoteHasEmptyLineAhead() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanBlockQuoteEmptyLine()
        } catch {
            return true
        }
    }

    func hasStrongAhead() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanStrong()
        } catch {
            return true
        }
    }
 
    func hasEmAhead() -> Bool {
        lookAhead = 2147483647;
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanEm()
        } catch {
            return true
        }
    }

    func hasCodeAhead() -> Bool {
        lookAhead = 2147483647;
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanCode()
        } catch {
            return true
        }
    }
    
    func blockQuoteHasAnyBlockElementseAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanMoreBlockElements()
        } catch {
            return true
        }
    }

    func hasBlockQuoteEmptyLinesAhead() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanBlockQuoteEmptyLines()
        } catch {
            return true
        }
    }

    func listItemHasInlineElements() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanMoreBlockElements()
        } catch {
            return true
        }
    }
  
    func hasInlineTextAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanTextTokens()
        } catch {
            return true
        }
    }

    func hasInlineElementAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanInlineElement()
        } catch {
            return true
        }
    }

    func imageHasAnyElements() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanImageElement()
        } catch {
            return true
        }
    }
 
    func hasResourceTextAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanResourceElements()
        } catch {
            return true
        }
    }

    func linkHasAnyElements() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanLinkElement()
        } catch {
            return true
        }
    }

    func hasResourceUrlAhead() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanResourceUrl()
        } catch {
            return true
        }
    }

    func resourceHasElementAhead() -> Bool {
        lookAhead = 2
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanResourceElement()
        } catch {
            return true
        }
    }
   
    func resourceTextHasElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanResourceTextElement()
        } catch {
            return true
        }
    }

    func hasEmWithinStrongMultiline() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanEmWithinStrongMultiline()
        } catch {
            return true
        }
    }
    
    func strongMultilineHasElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanStrongMultilineElements();
        } catch {
            return true
        }
    }

    func strongWithinEmMultilineHasElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanStrongWithinEmMultilineElements();
        } catch {
            return true
        }
    }

    func hasImage() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanImage();
        } catch {
            return true
        }
    }

    func hasLinkAhead() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanLink()
        } catch  {
            return true
        }
    }

    func strongEmWithinStrongAhead() -> Bool {
        lookAhead = 2147483647;
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanEmWithinStrong()
        } catch {
            return true
        }
    }

    func strongHasElements() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanStrongElements()
        } catch  {
            return true
        }
    }

    func strongWithinEmHasElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanStrongWithinEmElements()
        } catch {
            return true
        }
    }

    func hasStrongWithinEmMultilineAhead() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanStrongWithinEmMultiline()
        } catch {
            return true
        }
    }

    func emMultilineContentHasElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanEmMultilineContentElements()
        } catch {
            return true
        }
    }

    func emWithinStrongMultilineContentHasElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanEmWithinStrongMultilineContent()
        } catch {
            return true
        }
    }

    func emHasStrongWithinEm() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanStrongWithinEm()
        } catch {
            return true
        }
    }

    func emHasElements() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanEmElements()
        } catch {
            return true
        }
    }

    func emWithinStrongHasElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanEmWithinStrongElements()
        } catch {
            return true
        }
    }
    
    func codeTextHasAnyTokenAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanCodeTextTokens();
        } catch {
            return true
        }
    }

    func textHasTokensAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanText()
        } catch {
            return true
        }
    }
   
    func scanLooseChar() throws -> Bool {
        let xsp : Token = scanPosition
        if try scanToken(TokenManager.ASTERISK) {
            scanPosition = xsp
            if try scanToken(TokenManager.BACKTICK) {
                scanPosition = xsp
                if try scanToken(TokenManager.LBRACK) {
                    scanPosition = xsp
                    return try scanToken(TokenManager.UNDERSCORE)
                }
            }
        }
        return false
    }

    func scanText() throws -> Bool {
        let xsp : Token = scanPosition
        if try scanToken(TokenManager.BACKSLASH) {
            scanPosition = xsp
            if try scanToken(TokenManager.CHAR_SEQUENCE) {
                scanPosition = xsp
                if try scanToken(TokenManager.COLON) {
                    scanPosition = xsp
                    if try scanToken(TokenManager.DASH) {
                        scanPosition = xsp;
                        if try scanToken(TokenManager.DIGITS) {
                            scanPosition = xsp;
                            if try scanToken(TokenManager.DOT) {
                                scanPosition = xsp
                                if try scanToken(TokenManager.EQ) {
                                    scanPosition = xsp
                                    if try scanToken(TokenManager.ESCAPED_CHAR) {
                                        scanPosition = xsp
                                        if try scanToken(TokenManager.GT) {
                                            scanPosition = xsp
                                            if try scanToken(TokenManager.IMAGE_LABEL) {
                                                scanPosition = xsp;
                                                if try scanToken(TokenManager.LPAREN) {
                                                    scanPosition = xsp
                                                    if try scanToken(TokenManager.LT) {
                                                        scanPosition = xsp
                                                        if try scanToken(TokenManager.RBRACK) {
                                                            scanPosition = xsp
                                                            if try scanToken(TokenManager.RPAREN) {
                                                                scanPosition = xsp
                                                                lookingAhead = true
                                                                semanticLookAhead = !nextAfterSpace(TokenManager.EOL, TokenManager.EOF)
                                                                lookingAhead = false;
                                                                return try !semanticLookAhead || scanWhitspaceToken()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        return false
    }

    func scanTextTokens() throws -> Bool {
        if try scanText() {
            return true
        }
        var xsp : Token;
        while true {
            xsp = scanPosition
            if try scanText() {
                scanPosition = xsp;
                break;
            }
        }
        return false
    }

    func scanCodeTextTokens() throws -> Bool {
        let xsp : Token = scanPosition
        if try scanToken(TokenManager.ASTERISK) {
            scanPosition = xsp
            if try scanToken(TokenManager.BACKSLASH) {
                scanPosition = xsp
                if try scanToken(TokenManager.CHAR_SEQUENCE) {
                    scanPosition = xsp;
                    if try scanToken(TokenManager.COLON) {
                        scanPosition = xsp
                        if try scanToken(TokenManager.DASH) {
                            scanPosition = xsp
                            if try scanToken(TokenManager.DIGITS) {
                                scanPosition = xsp
                                if try scanToken(TokenManager.DOT) {
                                    scanPosition = xsp
                                    if try scanToken(TokenManager.EQ) {
                                        scanPosition = xsp
                                        if try scanToken(TokenManager.ESCAPED_CHAR) {
                                            scanPosition = xsp
                                            if try scanToken(TokenManager.IMAGE_LABEL) {
                                                scanPosition = xsp
                                                if try scanToken(TokenManager.LT) {
                                                    scanPosition = xsp
                                                    if try scanToken(TokenManager.LBRACK) {
                                                        scanPosition = xsp
                                                        if try scanToken(TokenManager.RBRACK) {
                                                            scanPosition = xsp
                                                            if try scanToken(TokenManager.LPAREN) {
                                                                scanPosition = xsp
                                                                if try scanToken(TokenManager.GT) {
                                                                    scanPosition = xsp
                                                                    if try scanToken(TokenManager.RPAREN) {
                                                                        scanPosition = xsp
                                                                        if try scanToken(TokenManager.UNDERSCORE) {
                                                                            scanPosition = xsp
                                                                            lookingAhead = true
                                                                            semanticLookAhead = !nextAfterSpace(TokenManager.EOL, TokenManager.EOF);
                                                                            lookingAhead = false
                                                                            return try (!semanticLookAhead || scanWhitspaceToken())
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }

    func scanCode() throws -> Bool {
        return try scanToken(TokenManager.BACKTICK) || scanCodeTextTokensAhead() || scanToken(TokenManager.BACKTICK);
    }

    func scanCodeMultiline() throws -> Bool {
        if try scanToken(TokenManager.BACKTICK) || scanCodeTextTokensAhead() {
            return true
        }
        var xsp : Token
        while true {
            xsp = scanPosition
            if try hasCodeTextOnNextLineAhead() {
                scanPosition = xsp
                break
            }
        }
        return try scanToken(TokenManager.BACKTICK);
    }

    func scanCodeTextTokensAhead() throws -> Bool {
        if try scanCodeTextTokens() {
            return true;
        }
        var xsp : Token
        while true {
            xsp = scanPosition
            if try scanCodeTextTokens() {
                scanPosition = xsp
                break
            }
        }
        return false
    }

    func hasCodeTextOnNextLineAhead() throws -> Bool {
        if try scanWhitespaceTokenBeforeEol() {
            return true
        }
        var xsp : Token
        while true {
            xsp = scanPosition
            if try scanToken(TokenManager.GT) {
                scanPosition = xsp
                break
            }
        }
        return try scanCodeTextTokensAhead()
    }

    func scanWhitspaceTokens() throws -> Bool{
        var xsp : Token
        while true {
            xsp = scanPosition
            if try scanWhitspaceToken() {
                scanPosition = xsp
                break
            }
        }
        return false
    }
    
    func scanWhitespaceTokenBeforeEol() throws -> Bool {
        return try (scanWhitspaceTokens() || scanToken(TokenManager.EOL))
    }

    func scanEmWithinStrongElements() throws -> Bool {
        let xsp : Token = scanPosition;
        if try scanTextTokens() {
            scanPosition = xsp
            if try scanImage() {
                scanPosition = xsp
                if try scanLink() {
                    scanPosition = xsp
                    if try scanCode() {
                        scanPosition = xsp
                        if try scanToken(TokenManager.ASTERISK) {
                            scanPosition = xsp
                            if try scanToken(TokenManager.BACKTICK) {
                                scanPosition = xsp
                                return try scanToken(TokenManager.LBRACK)
                            }
                        }
                    }
                }
            }
        }
        return false
    }

    func scanEmWithinStrong() throws -> Bool {
        if try scanToken(TokenManager.UNDERSCORE) || scanEmWithinStrongElements() {
            return true;
        }
        var xsp : Token
        while true {
            xsp = scanPosition
            if try scanEmWithinStrongElements() {
                scanPosition = xsp
                break
            }
        }
        return try scanToken(TokenManager.UNDERSCORE)
    }

    func scanEmElements() throws -> Bool {
        let xsp : Token = scanPosition
        if try scanTextTokens() {
            scanPosition = xsp
            if try scanImage() {
                scanPosition = xsp
                if try scanLink() {
                    scanPosition = xsp
                    if try scanCode() {
                        scanPosition = xsp
                        if try scanStrongWithinEm() {
                            scanPosition = xsp
                            if try scanToken(TokenManager.ASTERISK) {
                                scanPosition = xsp
                                if try scanToken(TokenManager.BACKTICK) {
                                    scanPosition = xsp
                                    return try scanToken(TokenManager.LBRACK)
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }

    func scanEm() throws -> Bool {
        if try scanToken(TokenManager.UNDERSCORE) || scanEmElements() {
            return true
        }
        var xsp : Token
        while true {
            xsp = scanPosition
            if try scanEmElements() {
                scanPosition = xsp
                break;
            }
        }
        return try scanToken(TokenManager.UNDERSCORE)
    }

    func scanEmWithinStrongMultilineContent() throws -> Bool {
        let xsp = scanPosition
        if try scanTextTokens() {
            scanPosition = xsp
            if try scanImage() {
                scanPosition = xsp
                if try scanLink() {
                    scanPosition = xsp
                    if try scanCode() {
                        scanPosition = xsp
                        if try scanToken(TokenManager.ASTERISK) {
                            scanPosition = xsp
                            if try scanToken(TokenManager.BACKTICK) {
                                scanPosition = xsp
                                return try scanToken(TokenManager.LBRACK)
                            }
                        }
                    }
                }
            }
        }
        return false
    }

    func hasNoEmWithinStrongMultilineContentAhead() throws -> Bool {
        if try scanEmWithinStrongMultilineContent() {
            return true
        }
        var xsp : Token
        while true {
            xsp = scanPosition
            if try scanEmWithinStrongMultilineContent() {
                scanPosition = xsp
                break
            }
        }
        return false
    }

    func scanEmWithinStrongMultiline() throws -> Bool {
        if try scanToken(TokenManager.UNDERSCORE) || hasNoEmWithinStrongMultilineContentAhead() {
            return true
        }
        var xsp : Token
        while true {
            xsp = scanPosition
            if try scanWhitespaceTokenBeforeEol() || hasNoEmWithinStrongMultilineContentAhead() {
                scanPosition = xsp;
                break
            }
        }
        return try scanToken(TokenManager.UNDERSCORE)
    }

    func scanEmMultilineContentElements() throws -> Bool {
        let xsp = scanPosition
        if try scanTextTokens() {
            scanPosition = xsp
            if try scanImage() {
                scanPosition = xsp
                if try scanLink() {
                    scanPosition = xsp
                    lookingAhead = true
                    semanticLookAhead = multilineAhead(TokenManager.BACKTICK)
                    lookingAhead = false
                    if try !semanticLookAhead || scanCodeMultiline() {
                        scanPosition = xsp
                        if try scanStrongWithinEmMultiline() {
                            scanPosition = xsp
                            if try scanToken(TokenManager.ASTERISK) {
                                scanPosition = xsp
                                if try scanToken(TokenManager.BACKTICK) {
                                    scanPosition = xsp
                                    return try scanToken(TokenManager.LBRACK)
                                }
                            }
                        }
                    }
                }
            }
        }
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

    func scanStrong() throws -> Bool {
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

    func scanImageElement() throws -> Bool {
//    Token xsp = scanPosition;
//    if (scanResourceElements()) {
//    scanPosition = xsp;
//    if (scanLooseChar()) {
//    return true;
//    }
//    }
        return false
    }

    func scanResourceTextElements() throws -> Bool {
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

    func scanResourceUrl() throws -> Bool {
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

    func scanResourceElements() throws -> Bool {
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

    func scanLink() throws -> Bool {
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

    func scanImage() throws -> Bool {
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

    func scanInlineElement() throws -> Bool {
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

    func scanParagraph() throws -> Bool {
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

    func scanWhitspaceToken() throws -> Bool {
//    Token xsp = scanPosition;
//    if (scanToken(SPACE)) {
//    scanPosition = xsp;
//    if (scanToken(TAB)) {
//    return true;
//    }
//    }
        return false
    }

    func scanFencedCodeBlock() throws -> Bool {
//    return scanToken(BACKTICK) || scanToken(BACKTICK) || scanToken(BACKTICK);
        return false
}

    func scanBlockQuoteEmptyLines() throws -> Bool {
        return try (scanBlockQuoteEmptyLine() || scanToken(TokenManager.EOL))
}

    func scanBlockQuoteEmptyLine() throws -> Bool {
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

    func scanForHeadersigns() throws -> Bool {
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

    func scanMoreBlockElements() throws -> Bool {
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
    
    func scanToken(_ kind : Int) throws -> Bool {
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
//        if (lookAhead == 0 && (scanPosition == lastPosition)) {
            throw lookAheadSuccess
//        }
//        return false
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
    func consumeToken(_ kind : Int) -> Token {
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

    func getToken(_ index : Int) -> Token {
        let t = lookingAhead ? scanPosition : token;
//    for (int i = 0; i < index; i++) {
//    if (t.next != null) {
//    t = t.next;
//    } else {
//    t = t.next = tm.getNextToken();
//    }
//    }
        return t!
    }
//    
//    public void setModules(String... modules) {
//    this.modules = Arrays.asList(modules);
//    }
    
}
