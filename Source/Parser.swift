public class Parser {
    
    var cs : CharStream!
    var token, nextToken, scanPosition, lastPosition : Token!
    var tm : TokenManager!
    var tree : TreeState!
    var currentBlockLevel : Int = 0
    var currentQuoteLevel : Int = 0
    var lookAhead : Int = 0
    var nextTokenKind : Int32 = 0
    var lookingAhead : Bool = false
    var semanticLookAhead : Bool = false
    public var modules : [String] = ["paragraphs", "headings", "lists", "links", "images", "formatting", "blockquotes", "code"]
    let lookAheadSuccess : KoaraError

    public init() {
        self.lookAheadSuccess = KoaraError.LookaheadSuccess()
    }
    
    public func parse(_ text: String) -> Document {
        return self.parseReader(StringReader(text: text))
    }
    
//    public func parseFile(_ file) throws -> Document {
//        if(!file.getName().toLowerCase().endsWith(".kd")) {
//            throw new IllegalArgumentException("Can only parse files with extension .kd")
//        }
//        return parseReader(new FileReader(file))
//    }
    
    func parseReader(_ reader: Reader) -> Document {
        cs = CharStream(reader: reader)
        tm = TokenManager(stream: cs)
        token = Token()
        tree = TreeState()
        nextTokenKind = -1
        let document = Document()
        tree.openScope()
        
        while getNextTokenKind() == TokenManager.EOL {
            consumeToken(TokenManager.EOL)
        }
        whiteSpace()
        if hasAnyBlockElementsAhead() {
            blockElement()
            while blockAhead(0) {
                while (getNextTokenKind() == TokenManager.EOL) {
                    consumeToken(TokenManager.EOL)
                    whiteSpace()
                }
                blockElement()
            }
            while (getNextTokenKind() == TokenManager.EOL) {
                consumeToken(TokenManager.EOL)
            }
            whiteSpace()
        }
        consumeToken(TokenManager.EOF)
        tree.closeScope(document)
        return document
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
        let heading = Heading()
        tree.openScope()
        var headingLevel : Int = 0
        while (getNextTokenKind() == TokenManager.EQ) {
            consumeToken(TokenManager.EQ)
            headingLevel += 1
        }
        whiteSpace()
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
        tree.closeScope(heading)
    }
 
    func blockQuote() {
        let blockQuote = BlockQuote()
        tree.openScope()
        currentQuoteLevel += 1
        consumeToken(TokenManager.GT)
        while blockQuoteHasEmptyLineAhead() {
            blockQuoteEmptyLine()
        }
        whiteSpace()
        if blockQuoteHasAnyBlockElementseAhead() {
            blockElement()
            while (blockAhead(0)) {
                while (getNextTokenKind() == TokenManager.EOL) {
                    consumeToken(TokenManager.EOL)
                    whiteSpace()
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
        var i : Int = 0
        repeat {
            consumeToken(TokenManager.GT)
            whiteSpace()
            i += 1
        } while i < currentQuoteLevel
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
        let list = ListBlock(ordered: false)
        tree.openScope()
        let listBeginColumn = unorderedListItem()
        while listItemAhead(listBeginColumn, ordered: false) {
            while getNextTokenKind() == TokenManager.EOL {
                consumeToken(TokenManager.EOL)
            }
            whiteSpace()
            if currentQuoteLevel > 0 {
                blockQuotePrefix()
            }
            unorderedListItem()
        }
        tree.closeScope(list)
    }

    @discardableResult func unorderedListItem() -> Int {
        let listItem = ListItem()
        tree.openScope()
        let t = consumeToken(TokenManager.DASH)
        whiteSpace()
        if listItemHasInlineElements() {
            blockElement()
            while blockAhead(t.beginColumn) {
                while getNextTokenKind() == TokenManager.EOL {
                    consumeToken(TokenManager.EOL)
                    whiteSpace()
                    if (currentQuoteLevel > 0) {
                        blockQuotePrefix()
                    }
                }
                blockElement()
            }
        }
        tree.closeScope(listItem)
        return t.beginColumn
    }

    func orderedList() {
        let list = ListBlock(ordered: true)
        tree.openScope()
        let listBeginColumn : Int = orderedListItem()
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

    @discardableResult func orderedListItem() -> Int {
        let listItem = ListItem()
        tree.openScope()
        let t = consumeToken(TokenManager.DIGITS)
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
        listItem.number = Int(t.image!)!
        tree.closeScope(listItem)
        return t.beginColumn
    }

    func fencedCodeBlock() {
        let codeBlock = CodeBlock()
        tree.openScope()
        var s = ""
        let beginColumn = consumeToken(TokenManager.BACKTICK).beginColumn
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
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image!
            case TokenManager.ASTERISK:
                s += consumeToken(TokenManager.ASTERISK).image!
            case TokenManager.BACKSLASH:
                s += consumeToken(TokenManager.BACKSLASH).image!
            case TokenManager.COLON:
                s += consumeToken(TokenManager.COLON).image!
            case TokenManager.DASH:
                s += consumeToken(TokenManager.DASH).image!
            case TokenManager.DIGITS:
                s += consumeToken(TokenManager.DIGITS).image!
            case TokenManager.DOT:
                s += consumeToken(TokenManager.DOT).image!
            case TokenManager.EQ:
                s += consumeToken(TokenManager.EQ).image!
            case TokenManager.ESCAPED_CHAR:
                s += consumeToken(TokenManager.ESCAPED_CHAR).image!
            case TokenManager.IMAGE_LABEL:
                s += consumeToken(TokenManager.IMAGE_LABEL).image!
            case TokenManager.LT:
                s += consumeToken(TokenManager.LT).image!
            case TokenManager.GT:
                s += consumeToken(TokenManager.GT).image!
            case TokenManager.LBRACK:
                s += consumeToken(TokenManager.LBRACK).image!
            case TokenManager.RBRACK:
                s += consumeToken(TokenManager.RBRACK).image!
            case TokenManager.LPAREN:
                s += consumeToken(TokenManager.LPAREN).image!
            case TokenManager.RPAREN:
                s += consumeToken(TokenManager.RPAREN).image!
            case TokenManager.UNDERSCORE:
                s += consumeToken(TokenManager.UNDERSCORE).image!
            case TokenManager.BACKTICK:
                s += consumeToken(TokenManager.BACKTICK).image!
            default:
                if !nextAfterSpace(TokenManager.EOL, TokenManager.EOF) {
                    switch kind {
                    case TokenManager.SPACE:
                        s += consumeToken(TokenManager.SPACE).image!
                    case TokenManager.TAB:
                        consumeToken(TokenManager.TAB)
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
        let paragraph = modules.contains("paragraphs") ? Paragraph() : BlockElement()
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
        let text = Text()
        tree.openScope()
        var s = ""
        while textHasTokensAhead() {
            switch getNextTokenKind() {
                case TokenManager.CHAR_SEQUENCE:
                    s += consumeToken(TokenManager.CHAR_SEQUENCE).image!
                case TokenManager.BACKSLASH:
                    s += consumeToken(TokenManager.BACKSLASH).image!
                case TokenManager.COLON:
                    s += consumeToken(TokenManager.COLON).image!
                case TokenManager.DASH:
                    s += consumeToken(TokenManager.DASH).image!
                case TokenManager.DIGITS:
                    s += consumeToken(TokenManager.DIGITS).image!
                case TokenManager.DOT:
                    s += consumeToken(TokenManager.DOT).image!
                case TokenManager.EQ:
                    s += consumeToken(TokenManager.EQ).image!
                case TokenManager.ESCAPED_CHAR:
                    let image = consumeToken(TokenManager.ESCAPED_CHAR).image!
                    s += image.substring(from: image.index(image.startIndex, offsetBy: 1))
                case TokenManager.GT:
                    s += consumeToken(TokenManager.GT).image!
                case TokenManager.IMAGE_LABEL:
                    s += consumeToken(TokenManager.IMAGE_LABEL).image!
                case TokenManager.LPAREN:
                    s += consumeToken(TokenManager.LPAREN).image!
                case TokenManager.LT:
                    s += consumeToken(TokenManager.LT).image!
                case TokenManager.RBRACK:
                    s += consumeToken(TokenManager.RBRACK).image!
                case TokenManager.RPAREN:
                    s += consumeToken(TokenManager.RPAREN).image!
                default:
                    if (!nextAfterSpace(TokenManager.EOL, TokenManager.EOF)) {
                        switch getNextTokenKind() {
                            case TokenManager.SPACE:
                                s += consumeToken(TokenManager.SPACE).image!
                        case TokenManager.TAB:
                            consumeToken(TokenManager.TAB)
                            s += "    "
                        default: break
                        }
                    }
                break
            }
        }
        text.value = s as AnyObject
        tree.closeScope(text)
    }
    
    func image() {
        let image = Image()
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
        tree.closeScope(image)
    }

    func link() {
        let link = Link()
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
        consumeToken(TokenManager.RBRACK)
        if hasResourceUrlAhead() {
            ref = resourceUrl()
        }
        link.value = ref as AnyObject
        tree.closeScope(link)
    }

    func strong() {
        let strong = Strong()
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
                emWithinStrong()
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
        consumeToken(TokenManager.ASTERISK)
        tree.closeScope(strong)
    }

    func em() {
        let em = Em()
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
        consumeToken(TokenManager.UNDERSCORE)
        tree.closeScope(em)
    }

    func code() {
        let code = Code()
        tree.openScope()
        consumeToken(TokenManager.BACKTICK)
        codeText()
        consumeToken(TokenManager.BACKTICK)
        tree.closeScope(code)
    }

    func codeText() {
        let text = Text()
        tree.openScope()
        var s = ""
        repeat {
            switch getNextTokenKind() {
                case TokenManager.CHAR_SEQUENCE:
                    s += consumeToken(TokenManager.CHAR_SEQUENCE).image!
                case TokenManager.ASTERISK:
                    s += consumeToken(TokenManager.ASTERISK).image!
                case TokenManager.BACKSLASH:
                    s += consumeToken(TokenManager.BACKSLASH).image!
                case TokenManager.COLON:
                    s += consumeToken(TokenManager.COLON).image!
                case TokenManager.DASH:
                    s += consumeToken(TokenManager.DASH).image!
                case TokenManager.DIGITS:
                    s += consumeToken(TokenManager.DIGITS).image!
                case TokenManager.DOT:
                    s += consumeToken(TokenManager.DOT).image!
                case TokenManager.EQ:
                    s += consumeToken(TokenManager.EQ).image!
                case TokenManager.ESCAPED_CHAR:
                    s += consumeToken(TokenManager.ESCAPED_CHAR).image!
                case TokenManager.IMAGE_LABEL:
                    s += consumeToken(TokenManager.IMAGE_LABEL).image!
                case TokenManager.LT:
                    s += consumeToken(TokenManager.LT).image!
                case TokenManager.LBRACK:
                    s += consumeToken(TokenManager.LBRACK).image!
                case TokenManager.RBRACK:
                    s += consumeToken(TokenManager.RBRACK).image!
                case TokenManager.LPAREN:
                    s += consumeToken(TokenManager.LPAREN).image!
                case TokenManager.GT:
                    s += consumeToken(TokenManager.GT).image!
                case TokenManager.RPAREN:
                    s += consumeToken(TokenManager.RPAREN).image!
                case TokenManager.UNDERSCORE:
                    s += consumeToken(TokenManager.UNDERSCORE).image!
                default:
                    if !nextAfterSpace(TokenManager.EOL, TokenManager.EOF) {
                        switch getNextTokenKind() {
                            case TokenManager.SPACE:
                                s += consumeToken(TokenManager.SPACE).image!
                            case TokenManager.TAB:
                                consumeToken(TokenManager.TAB)
                                s += "    "
                            default: break
                        }
                    }
                }
        }   while codeTextHasAnyTokenAhead()
            text.value = s as AnyObject
            tree.closeScope(text)
        }

    func looseChar() {
        let text = Text()
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
        let linebreak = LineBreak()
        tree.openScope()
        while getNextTokenKind() == TokenManager.SPACE || getNextTokenKind() == TokenManager.TAB {
            consumeToken(getNextTokenKind())
        }
        let t = consumeToken(TokenManager.EOL)
        linebreak.explicit = t.image!.hasPrefix("  ")
        tree.closeScope(linebreak)
    }

    func levelWhiteSpace(_ threshold : Int) {
        var currentPos : Int = 1
        while getNextTokenKind() == TokenManager.GT {
            consumeToken(getNextTokenKind())
        }
        while (getNextTokenKind() == TokenManager.SPACE || getNextTokenKind() == TokenManager.TAB) && currentPos < (threshold - 1) {
            currentPos = consumeToken(getNextTokenKind()).beginColumn
        }
    }

    func codeLanguage() -> String {
        var s = ""
        repeat {
            switch getNextTokenKind() {
                case TokenManager.CHAR_SEQUENCE:
                    s += consumeToken(TokenManager.CHAR_SEQUENCE).image!
                case TokenManager.ASTERISK:
                    s += consumeToken(TokenManager.ASTERISK).image!
                case TokenManager.BACKSLASH:
                    s += consumeToken(TokenManager.BACKSLASH).image!
                case TokenManager.BACKTICK:
                    s += consumeToken(TokenManager.BACKTICK).image!
                case TokenManager.COLON:
                    s += consumeToken(TokenManager.COLON).image!
                case TokenManager.DASH:
                    s += consumeToken(TokenManager.DASH).image!
                case TokenManager.DIGITS:
                    s += consumeToken(TokenManager.DIGITS).image!
                case TokenManager.DOT:
                    s += consumeToken(TokenManager.DOT).image!
                case TokenManager.EQ:
                    s += consumeToken(TokenManager.EQ).image!
                case TokenManager.ESCAPED_CHAR:
                    s += consumeToken(TokenManager.ESCAPED_CHAR).image!
                case TokenManager.IMAGE_LABEL:
                    s += consumeToken(TokenManager.IMAGE_LABEL).image!
                case TokenManager.LT:
                    s += consumeToken(TokenManager.LT).image!
                case TokenManager.GT:
                    s += consumeToken(TokenManager.GT).image!
                case TokenManager.LBRACK:
                    s += consumeToken(TokenManager.LBRACK).image!
                case TokenManager.RBRACK:
                    s += consumeToken(TokenManager.RBRACK).image!
                case TokenManager.LPAREN:
                    s += consumeToken(TokenManager.LPAREN).image!
                case TokenManager.RPAREN:
                    s += consumeToken(TokenManager.RPAREN).image!
                case TokenManager.UNDERSCORE:
                    s += consumeToken(TokenManager.UNDERSCORE).image!
                case TokenManager.SPACE:
                    s += consumeToken(TokenManager.SPACE).image!
                case TokenManager.TAB:
                    s += "    "
                default: break
            }
        } while getNextTokenKind() != TokenManager.EOL && getNextTokenKind() != TokenManager.EOF
        return s
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
        let text = Text()
        tree.openScope()
        var s = ""
        repeat {
            switch getNextTokenKind() {
                case TokenManager.CHAR_SEQUENCE:
                    s += consumeToken(TokenManager.CHAR_SEQUENCE).image!
                case TokenManager.BACKSLASH:
                    s += consumeToken(TokenManager.BACKSLASH).image!
                case TokenManager.COLON:
                    s += consumeToken(TokenManager.COLON).image!
                case TokenManager.DASH:
                    s += consumeToken(TokenManager.DASH).image!
                case TokenManager.DIGITS:
                    s += consumeToken(TokenManager.DIGITS).image!
                case TokenManager.DOT:
                    s += consumeToken(TokenManager.DOT).image!
                case TokenManager.EQ:
                    s += consumeToken(TokenManager.EQ).image!
                case TokenManager.ESCAPED_CHAR:
                    let image = consumeToken(TokenManager.ESCAPED_CHAR).image!
                    s += image.substring(from: image.index(image.startIndex, offsetBy: 1))
                case TokenManager.IMAGE_LABEL:
                    s += consumeToken(TokenManager.IMAGE_LABEL).image!
                case TokenManager.GT:
                    s += consumeToken(TokenManager.GT).image!
                case TokenManager.LPAREN:
                    s += consumeToken(TokenManager.LPAREN).image!
                case TokenManager.LT:
                    s += consumeToken(TokenManager.LT).image!
                case TokenManager.RPAREN:
                    s += consumeToken(TokenManager.RPAREN).image!
                default:
                    if !nextAfterSpace(TokenManager.RBRACK) {
                    switch getNextTokenKind() {
                        case TokenManager.SPACE:
                            s.append(consumeToken(TokenManager.SPACE).image!)
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
        return ref
    }

    func resourceUrlText() -> String {
        var s = ""
        while resourceTextHasElementsAhead() {
            switch getNextTokenKind() {
            case TokenManager.CHAR_SEQUENCE:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image!
            case TokenManager.ASTERISK:
                s += consumeToken(TokenManager.ASTERISK).image!
            case TokenManager.BACKSLASH:
                s += consumeToken(TokenManager.BACKSLASH).image!
            case TokenManager.BACKTICK:
                s += consumeToken(TokenManager.BACKTICK).image!
            case TokenManager.CHAR_SEQUENCE:
                s += consumeToken(TokenManager.CHAR_SEQUENCE).image!
            case TokenManager.COLON:
                s += consumeToken(TokenManager.COLON).image!
            case TokenManager.DASH:
                s += consumeToken(TokenManager.DASH).image!
            case TokenManager.DIGITS:
                s += consumeToken(TokenManager.DIGITS).image!
            case TokenManager.DOT:
                s += consumeToken(TokenManager.DOT).image!
            case TokenManager.EQ:
                s += consumeToken(TokenManager.EQ).image!
            case TokenManager.ESCAPED_CHAR:
                let image = consumeToken(TokenManager.ESCAPED_CHAR).image!
                s += image.substring(from: image.index(image.startIndex, offsetBy: 1))
            case TokenManager.IMAGE_LABEL:
                s += consumeToken(TokenManager.IMAGE_LABEL).image!
            case TokenManager.GT:
                s += consumeToken(TokenManager.GT).image!
            case TokenManager.LBRACK:
                s += consumeToken(TokenManager.LBRACK).image!
            case TokenManager.LPAREN:
                s += consumeToken(TokenManager.LPAREN).image!
            case TokenManager.LT:
                s += consumeToken(TokenManager.LT).image!
            case TokenManager.RBRACK:
                s += consumeToken(TokenManager.RBRACK).image!
            case TokenManager.UNDERSCORE:
                s += consumeToken(TokenManager.UNDERSCORE).image!
            default:
                if !nextAfterSpace(TokenManager.RPAREN) {
                    switch getNextTokenKind() {
                        case TokenManager.SPACE:
                            s += consumeToken(TokenManager.SPACE).image!
                        case TokenManager.TAB:
                            consumeToken(TokenManager.TAB)
                            s += "    "
                        default: break
                    }
                }
            }
        }
        return s
    }

    func strongMultiline() {
        let strong = Strong()
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
        let strong = Strong()
        tree.openScope()
        consumeToken(TokenManager.ASTERISK)
        strongWithinEmMultilineContent()
        while (textAhead()) {
            lineBreak()
            strongWithinEmMultilineContent()
        }
        consumeToken(TokenManager.ASTERISK)
        tree.closeScope(strong)
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
        let strong = Strong()
        tree.openScope()
        consumeToken(TokenManager.ASTERISK)
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
        } while strongWithinEmHasElementsAhead()
        consumeToken(TokenManager.ASTERISK)
        tree.closeScope(strong)
    }

    func emMultiline() {
        let em = Em()
        tree.openScope()
        consumeToken(TokenManager.UNDERSCORE)
        emMultilineContent()
        while (textAhead()) {
            lineBreak()
            whiteSpace()
            emMultilineContent()
        }
        consumeToken(TokenManager.UNDERSCORE)
        tree.closeScope(em)
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
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.BACKTICK))
                case TokenManager.LBRACK:
                    tree.addSingleValue(Text(), t: consumeToken(TokenManager.LBRACK))
                default: break
                }
            }
        } while emMultilineContentHasElementsAhead()
    }

    func emWithinStrongMultiline() {
        let em = Em()
        tree.openScope()
        consumeToken(TokenManager.UNDERSCORE)
        emWithinStrongMultilineContent()
        while (textAhead()) {
            lineBreak()
            emWithinStrongMultilineContent()
        }
        consumeToken(TokenManager.UNDERSCORE)
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
        let em = Em()
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
        consumeToken(TokenManager.UNDERSCORE)
        tree.closeScope(em)
    }

    func codeMultiline() {
        let code = Code()
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
        var quoteLevel : Int
        if (getNextTokenKind() == TokenManager.EOL) {
            var t : Token
            var i : Int = 2
            quoteLevel = 0
            repeat {
                quoteLevel = 0
                repeat {
                    t = getToken(i)
                    i += 1
                    if (t.kind == TokenManager.GT) {
                        if (t.beginColumn == 1 && currentBlockLevel > 0 && currentQuoteLevel == 0) {
                            return false
                        }
                        quoteLevel += 1
                    }
                } while (t.kind == TokenManager.GT || t.kind == TokenManager.SPACE || t.kind == TokenManager.TAB)
                if (quoteLevel > currentQuoteLevel) {
                    return true
                }
                if (quoteLevel < currentQuoteLevel) {
                    return false
                }
            } while (t.kind == TokenManager.EOL)
            return t.kind != TokenManager.EOF && (currentBlockLevel == 0 || t.beginColumn >= blockBeginColumn + 2)
        }
            return false
    }
    
    func multilineAhead(_ token : Int32) -> Bool {
        if (getNextTokenKind() == token && getToken(2).kind != token && getToken(2).kind != TokenManager.EOL) {
            var i = 2
            repeat {
                let t = getToken(i)
                if (t.kind == token) {
                    return true
                } else if (t.kind == TokenManager.EOL) {
                    i = skip(i + 1, tokens: [TokenManager.SPACE, TokenManager.TAB])
                    let quoteLevel = newQuoteLevel(offset: i)
                    if (quoteLevel == currentQuoteLevel) {
                        i = skip(i, tokens: [TokenManager.SPACE, TokenManager.TAB, TokenManager.GT])
                        if (getToken(i).kind == token || getToken(i).kind == TokenManager.EOL || getToken(i).kind == TokenManager.DASH
                            || (getToken(i).kind == TokenManager.DIGITS && getToken(i + 1).kind == TokenManager.DOT)
                            || (getToken(i).kind == TokenManager.BACKTICK && getToken(i + 1).kind == TokenManager.BACKTICK
                                && getToken(i + 2).kind == TokenManager.BACKTICK)
                            || headingAhead(i)) {
                            return false
                        }
                    } else {
                        return false
                    }
                } else if (t.kind == TokenManager.EOF) {
                    return false
                }
                i += 1
            } while(true)
        


        }
        return false
    }

    func fencesAhead() -> Bool {
        var i = skip(2, tokens: [TokenManager.SPACE, TokenManager.TAB, TokenManager.GT])
        if (getToken(i).kind == TokenManager.BACKTICK && getToken(i + 1).kind == TokenManager.BACKTICK && getToken(i + 2).kind == TokenManager.BACKTICK) {
            i = skip(i + 3, tokens: [TokenManager.SPACE, TokenManager.TAB])
            return getToken(i).kind == TokenManager.EOL || getToken(i).kind == TokenManager.EOF
        }
        return false
    }

    func headingAhead(_ offset : Int) -> Bool {
        if getToken(offset).kind == TokenManager.EQ {
            var heading : Int = 1
            var i = offset + 1
            
            repeat {
                if (getToken(i).kind != TokenManager.EQ) {
                    return true
                }
                heading+=1
                if (heading > 6) {
                    return false
                }
                i+=1
            } while(true)
        }
        return false
    }

    func listItemAhead(_ listBeginColumn : Int, ordered : Bool) -> Bool {
        if (getNextTokenKind() == TokenManager.EOL) {
            var i = 2
            var eol = 1
            repeat {
                let t = getToken(i);
                eol += 1
                if (t.kind == TokenManager.EOL && eol > 2) {
                    return false
                } else if (t.kind != TokenManager.SPACE && t.kind != TokenManager.TAB && t.kind != TokenManager.GT && t.kind != TokenManager.EOL) {
                    if (ordered) {
                        return (t.kind == TokenManager.DIGITS && getToken(i + 1).kind == TokenManager.DOT && t.beginColumn >= listBeginColumn)
                    }
                    return t.kind == TokenManager.DASH && t.beginColumn >= listBeginColumn
                }
                i += 1
            } while(true)
        }
        return false
    }

    func textAhead() -> Bool {
        if (getNextTokenKind() == TokenManager.EOL && getToken(2).kind != TokenManager.EOL) {
            var i = skip(2, tokens: [TokenManager.SPACE, TokenManager.TAB])
            let quoteLevel = newQuoteLevel(offset: i)
            if (quoteLevel == currentQuoteLevel || !modules.contains("blockquotes")) {
                i = skip(i, tokens: [TokenManager.SPACE, TokenManager.TAB, TokenManager.GT])
                let t = getToken(i)
                return getToken(i).kind != TokenManager.EOL && !(modules.contains("lists") && t.kind == TokenManager.DASH)
                    && !(modules.contains("lists") && t.kind == TokenManager.DIGITS && getToken(i + 1).kind == TokenManager.DOT)
                    && !(getToken(i).kind == TokenManager.BACKTICK && getToken(i + 1).kind == TokenManager.BACKTICK
                    && getToken(i + 2).kind == TokenManager.BACKTICK)
                    && !(modules.contains("headings") && headingAhead(i))
            }
        }
        return false
    }

    func nextAfterSpace(_ tokens : Int32...) -> Bool {
        let i : Int = skip(1, tokens: [TokenManager.SPACE, TokenManager.TAB])
        return tokens.contains(getToken(i).kind!)
    }
        
    func newQuoteLevel(offset : Int) -> Int {
        var quoteLevel = 0
        var i = offset
        repeat {
            let t = getToken(i)
            if (t.kind == TokenManager.GT) {
                quoteLevel += 1
            } else if (t.kind != TokenManager.SPACE && t.kind != TokenManager.TAB) {
                return quoteLevel
            }
            i += 1
        } while(true)
    }

    func skip(_ offset : Int, tokens : [Int32]) -> Int {
        var i = offset
        repeat {
            let t = getToken(i)
            if (!tokens.contains(t.kind!)) {
                return i
            }
            i += 1
        } while(true)
    }

    func hasOrderedListAhead() -> Bool {
        lookAhead = 2
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanToken(TokenManager.DIGITS) && !scanToken(TokenManager.DOT)
        } catch {
            return true
        }
    }

    func hasFencedCodeBlockAhead() -> Bool {
        lookAhead = 3
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanFencedCodeBlock()
        } catch {
            return true
        }
    }

    func headingHasInlineElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            let xsp = scanPosition
            if (try scanTextTokens()) {
                scanPosition = xsp
                if (try scanImage()) {
                    scanPosition = xsp
                    if (try scanLink()) {
                        scanPosition = xsp
                        if (try scanStrong()) {
                            scanPosition = xsp
                            if (try scanEm()) {
                                scanPosition = xsp
                                if (try scanCode()) {
                                    scanPosition = xsp
                                    if (try scanLooseChar()) {
                                        return false
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return true
        } catch {
            return true
        }
    }
  
    func hasTextAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanTextTokens()
        } catch {
            return true
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
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanEm()
        } catch {
            return true
        }
    }

    func hasCodeAhead() -> Bool {
        lookAhead = 2147483647
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
            return try !scanStrongMultilineElements()
        } catch {
            return true
        }
    }

    func strongWithinEmMultilineHasElementsAhead() -> Bool {
        lookAhead = 1
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanStrongWithinEmMultilineElements()
        } catch {
            return true
        }
    }

    func hasImage() -> Bool {
        lookAhead = 2147483647
        scanPosition = token
        lastPosition = scanPosition
        do {
            return try !scanImage()
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
            lookAhead = 2147483647
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
                return try !scanCodeTextTokens()
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
                            scanPosition = xsp
                            if try scanToken(TokenManager.DIGITS) {
                                scanPosition = xsp
                                if try scanToken(TokenManager.DOT) {
                                    scanPosition = xsp
                                    if try scanToken(TokenManager.EQ) {
                                        scanPosition = xsp
                                        if try scanToken(TokenManager.ESCAPED_CHAR) {
                                            scanPosition = xsp
                                            if try scanToken(TokenManager.GT) {
                                                scanPosition = xsp
                                                if try scanToken(TokenManager.IMAGE_LABEL) {
                                                    scanPosition = xsp
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
                                                                    lookingAhead = false
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
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanText() {
                    scanPosition = xsp
                    break
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
                        scanPosition = xsp
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
                                                                                semanticLookAhead = !nextAfterSpace(TokenManager.EOL, TokenManager.EOF)
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
            return try scanToken(TokenManager.BACKTICK) || scanCodeTextTokensAhead() || scanToken(TokenManager.BACKTICK)
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
            return try scanToken(TokenManager.BACKTICK)
        }

        func scanCodeTextTokensAhead() throws -> Bool {
            if try scanCodeTextTokens() {
                return true
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
            let xsp : Token = scanPosition
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
                return true
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
                    break
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
                    scanPosition = xsp
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

        func scanStrongWithinEmElements() throws -> Bool {
            let xsp : Token = scanPosition
            if try scanTextTokens() {
                scanPosition = xsp
                if try scanImage() {
                    scanPosition = xsp
                    if try scanLink() {
                        scanPosition = xsp
                        if try scanCode() {
                            scanPosition = xsp
                            if try scanToken(TokenManager.BACKTICK) {
                                scanPosition = xsp
                                if try scanToken(TokenManager.LBRACK) {
                                    scanPosition = xsp
                                    return try scanToken(TokenManager.UNDERSCORE)
                                }
                            }
                        }
                    }
                }
            }
            return false
        }

        func scanStrongWithinEm() throws -> Bool {
            if try scanToken(TokenManager.ASTERISK) || scanStrongWithinEmElements() {
                return true
            }
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanStrongWithinEmElements() {
                    scanPosition = xsp
                    break
                }
            }
            return try scanToken(TokenManager.ASTERISK)
        }

        func scanStrongElements() throws -> Bool {
            let xsp : Token = scanPosition
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
                            if try scanEmWithinStrong() {
                                scanPosition = xsp
                                if try scanToken(TokenManager.BACKTICK) {
                                    scanPosition = xsp
                                    if try scanToken(TokenManager.LBRACK) {
                                        scanPosition = xsp
                                        return try scanToken(TokenManager.UNDERSCORE)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return false
        }

        func scanStrong() throws -> Bool {
            if try scanToken(TokenManager.ASTERISK) || scanStrongElements() {
                return true
            }
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanStrongElements() {
                    scanPosition = xsp
                    break
                }
            }
            return try scanToken(TokenManager.ASTERISK)
        }

        func scanStrongWithinEmMultilineElements() throws -> Bool {
            let xsp : Token = scanPosition
            if try scanTextTokens() {
                scanPosition = xsp
                if try scanImage() {
                    scanPosition = xsp
                    if try scanLink() {
                        scanPosition = xsp
                        if try scanCode() {
                            scanPosition = xsp
                            if try scanToken(TokenManager.BACKTICK) {
                                scanPosition = xsp
                                if try scanToken(TokenManager.LBRACK) {
                                    scanPosition = xsp
                                    return try scanToken(TokenManager.UNDERSCORE)
                                }
                            }
                        }
                    }
                }
            }
            return false
        }

        func scanForMoreStrongWithinEmMultilineElements() throws -> Bool {
            if try scanStrongWithinEmMultilineElements() {
                return true
            }
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanStrongWithinEmMultilineElements() {
                    scanPosition = xsp
                    break
                }
            }
            return false
        }

        func scanStrongWithinEmMultiline() throws -> Bool {
            if try scanToken(TokenManager.ASTERISK) || scanForMoreStrongWithinEmMultilineElements() {
                return true
            }
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanWhitespaceTokenBeforeEol() || scanForMoreStrongWithinEmMultilineElements() {
                    scanPosition = xsp
                    break
                }
            }
            return try scanToken(TokenManager.ASTERISK)
        }

        func scanStrongMultilineElements() throws -> Bool {
            let xsp : Token = scanPosition
            if try scanTextTokens() {
                scanPosition = xsp
                if try scanImage() {
                    scanPosition = xsp
                    if try scanLink() {
                        scanPosition = xsp
                        if try scanCode() {
                            scanPosition = xsp
                            if try scanEmWithinStrongMultiline() {
                                scanPosition = xsp
                                if try scanToken(TokenManager.BACKTICK) {
                                    scanPosition = xsp
                                    if try scanToken(TokenManager.LBRACK) {
                                        scanPosition = xsp
                                        return try scanToken(TokenManager.UNDERSCORE)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return false
        }

        func scanResourceTextElement() throws -> Bool {
            let xsp = scanPosition
            if try scanToken(TokenManager.ASTERISK) {
                scanPosition = xsp
                if try scanToken(TokenManager.BACKSLASH) {
                    scanPosition = xsp
                    if try scanToken(TokenManager.BACKTICK) {
                        scanPosition = xsp
                        if try scanToken(TokenManager.CHAR_SEQUENCE) {
                            scanPosition = xsp
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
                                                            if try scanToken(TokenManager.GT) {
                                                                scanPosition = xsp
                                                                if try scanToken(TokenManager.LBRACK) {
                                                                    scanPosition = xsp
                                                                    if try scanToken(TokenManager.LPAREN) {
                                                                        scanPosition = xsp
                                                                        if try scanToken(TokenManager.LT) {
                                                                            scanPosition = xsp
                                                                            if try scanToken(TokenManager.RBRACK) {
                                                                                scanPosition = xsp
                                                                                if try scanToken(TokenManager.UNDERSCORE) {
                                                                                    scanPosition = xsp
                                                                                    lookingAhead = true
                                                                                    semanticLookAhead = !nextAfterSpace(TokenManager.RPAREN)
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

        func scanImageElement() throws -> Bool {
            let xsp = scanPosition
            if try scanResourceElements() {
                scanPosition = xsp
                if try scanLooseChar() {
                    return true
                }
            }
            return false
        }

        func scanResourceTextElements() throws -> Bool {
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanResourceTextElement() {
                    scanPosition = xsp
                    break
                }
            }
            return false
        }

        func scanResourceUrl() throws -> Bool {
            return try scanToken(TokenManager.LPAREN) || scanWhitspaceTokens() || scanResourceTextElements() || scanWhitspaceTokens() || scanToken(TokenManager.RPAREN)
        }

        func scanLinkElement() throws -> Bool {
            let xsp = scanPosition
            if try scanImage() {
                scanPosition = xsp
                if try scanStrong() {
                    scanPosition = xsp
                    if try scanEm() {
                        scanPosition = xsp
                        if try scanCode() {
                            scanPosition = xsp
                            if try scanResourceElements() {
                                scanPosition = xsp
                                return try scanLooseChar()
                            }
                        }
                    }
                }
            }
            return false
        }

        func scanResourceElement() throws -> Bool {
            let xsp = scanPosition
            if try scanToken(TokenManager.BACKSLASH) {
                scanPosition = xsp
                if try scanToken(TokenManager.COLON) {
                    scanPosition = xsp
                    if try scanToken(TokenManager.CHAR_SEQUENCE) {
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
                                                if try scanToken(TokenManager.GT) {
                                                    scanPosition = xsp
                                                    if try scanToken(TokenManager.LPAREN) {
                                                        scanPosition = xsp
                                                        if try scanToken(TokenManager.LT) {
                                                            scanPosition = xsp
                                                            if try scanToken(TokenManager.RPAREN) {
                                                                scanPosition = xsp
                                                                lookingAhead = true
                                                                semanticLookAhead = !nextAfterSpace(TokenManager.RBRACK)
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
            return false
        }

        func scanResourceElements() throws -> Bool {
            if try scanResourceElement() {
                return true
            }
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanResourceElement() {
                    scanPosition = xsp
                    break
                }
            }
            return false
        }

        func scanLink() throws -> Bool {
            if try scanToken(TokenManager.LBRACK) || scanWhitspaceTokens() || scanLinkElement() {
                return true
            }
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanLinkElement() {
                    scanPosition = xsp
                    break
                }
            }
            if try scanWhitspaceTokens() || scanToken(TokenManager.RBRACK) {
                return true
            }
            xsp = scanPosition
            if try scanResourceUrl() {
                scanPosition = xsp
            }
            return false
        }

        func scanImage() throws -> Bool {
            if (try scanToken(TokenManager.LBRACK) || scanWhitspaceTokens() || scanToken(TokenManager.IMAGE_LABEL) || scanImageElement()) {
                return true
            }
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanImageElement() {
                    scanPosition = xsp
                    break
                }
            }
            if try scanWhitspaceTokens() || scanToken(TokenManager.RBRACK) {
                return true
            }
            xsp = scanPosition
            if try scanResourceUrl() {
                scanPosition = xsp
            }
            return false
        }

        func scanInlineElement() throws -> Bool {
            let xsp = scanPosition
            if try scanTextTokens() {
                scanPosition = xsp
                if try scanImage() {
                    scanPosition = xsp
                    if try scanLink() {
                        scanPosition = xsp
                        lookingAhead = true
                        semanticLookAhead = multilineAhead(TokenManager.ASTERISK)
                        lookingAhead = false
                        if try !semanticLookAhead || scanToken(TokenManager.ASTERISK) {
                            scanPosition = xsp
                            lookingAhead = true
                            semanticLookAhead = multilineAhead(TokenManager.UNDERSCORE)
                            lookingAhead = false
                            if try !semanticLookAhead || scanToken(TokenManager.UNDERSCORE) {
                                scanPosition = xsp
                                lookingAhead = true
                                semanticLookAhead = multilineAhead(TokenManager.BACKTICK)
                                lookingAhead = false
                                if try !semanticLookAhead || scanCodeMultiline() {
                                    scanPosition = xsp
                                    return try scanLooseChar()
                                }
                            }
                        }
                    }
                }
            }
            return false
        }

        func scanParagraph() throws -> Bool {
            var xsp : Token
            if try scanInlineElement() {
                return true
            }
            while true {
                xsp = scanPosition
                if try scanInlineElement() {
                    scanPosition = xsp
                    break
                }
            }
            return false
        }
        
        func scanWhitspaceToken() throws -> Bool {
            let xsp = scanPosition
            if try scanToken(TokenManager.SPACE) {
                scanPosition = xsp
                if try scanToken(TokenManager.TAB) {
                    return true
                }
            }
            return false
        }
        
        func scanFencedCodeBlock() throws -> Bool {
            return try scanToken(TokenManager.BACKTICK) || scanToken(TokenManager.BACKTICK) || scanToken(TokenManager.BACKTICK)
        }
        
        func scanBlockQuoteEmptyLines() throws -> Bool {
            return try (scanBlockQuoteEmptyLine() || scanToken(TokenManager.EOL))
        }
        
        func scanBlockQuoteEmptyLine() throws -> Bool {
            if try scanToken(TokenManager.EOL) || scanWhitspaceTokens() || scanToken(TokenManager.GT) || scanWhitspaceTokens() {
                return true
            }
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanToken(TokenManager.GT) || scanWhitspaceTokens() {
                    scanPosition = xsp
                    break
                }
            }
            return false
        }
        
        func scanForHeadersigns() throws -> Bool {
            if try scanToken(TokenManager.EQ) {
                return true
            }
            var xsp : Token
            while true {
                xsp = scanPosition
                if try scanToken(TokenManager.EQ) {
                    scanPosition = xsp
                    break
                }
            }
            return false
        }
        
        func scanMoreBlockElements() throws -> Bool {
            let xsp = scanPosition
            lookingAhead = true
            semanticLookAhead = headingAhead(1)
            lookingAhead = false
            if try !semanticLookAhead || scanForHeadersigns() {
                scanPosition = xsp
                if try scanToken(TokenManager.GT) {
                    scanPosition = xsp
                    if try scanToken(TokenManager.DASH) {
                        scanPosition = xsp
                        if try scanToken(TokenManager.DIGITS) || scanToken(TokenManager.DOT) {
                            scanPosition = xsp
                            if try scanFencedCodeBlock() {
                                scanPosition = xsp
                                return try scanParagraph()
                            }
                        }
                    }
                }
            }
            return false
        }
        
        func scanToken(_ kind : Int32) throws -> Bool {
            if (scanPosition === lastPosition) {
                lookAhead -= 1
                if scanPosition.next == nil {
                    scanPosition.next = tm.getNextToken()
                    scanPosition = scanPosition.next
                    lastPosition = scanPosition
                } else {
                    scanPosition = scanPosition.next
                    lastPosition = scanPosition
                }
            } else {
                scanPosition = scanPosition.next
            }
            if (scanPosition.kind != kind) {
                return true
            }
            if (lookAhead == 0 && (scanPosition === lastPosition)) {
                throw lookAheadSuccess
            }
            return false
        }
        
        func getNextTokenKind() -> Int32 {
            if (nextTokenKind != -1) {
                return nextTokenKind
            } else {
                nextToken = token.next
                if(nextToken == nil) {
                    token.next = tm.getNextToken()
                    nextTokenKind = token.next!.kind!
                    return nextTokenKind

                }
            }
            nextTokenKind = nextToken.kind!
            return nextTokenKind
        }
        
        @discardableResult func consumeToken(_ kind : Int32) -> Token {
            let old = token
            if token.next != nil {
                token = token.next
            } else {
                token.next = tm.getNextToken()
                token = token.next
            }
            nextTokenKind = -1
            if token.kind == kind {
                return token
            }
            token = old
            return token
        }
        
        func getToken(_ index : Int) -> Token {
            var t = lookingAhead ? scanPosition! : token!;
            for _ in 0..<index {
                if (t.next != nil) {
                    t = t.next!
                } else {
                    t.next = tm.getNextToken()
                    t = t.next!
                }
            }
            return t
        }
    
}
