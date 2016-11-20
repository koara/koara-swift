class TokenManager {
    
    static let EOF : Int32 = 0
    static let ASTERISK : Int32  = 1
    static let BACKSLASH : Int32  = 2
    static let BACKTICK : Int32  = 3
    static let CHAR_SEQUENCE : Int32  = 4
    static let COLON : Int32  = 5
    static let DASH : Int32  = 6
    static let DIGITS : Int32  = 7
    static let DOT : Int32  = 8
    static let EOL : Int32  = 9
    static let EQ : Int32  = 10
    static let ESCAPED_CHAR : Int32  = 11
    static let GT : Int32  = 12
    static let IMAGE_LABEL : Int32  = 13
    static let LBRACK : Int32  = 14
    static let LPAREN : Int32  = 15
    static let LT : Int32  = 16
    static let RBRACK : Int32  = 17
    static let RPAREN : Int32  = 18
    static let SPACE : Int32  = 19
    static let TAB : Int32  = 20
    static let UNDERSCORE : Int32  = 21

    let cs : CharStream
//    private int[] jjrounds = new int[8];
//    private int[] jjstateSet = new int[16];
    var curChar : Character
//    private int[] jjnextStates = { 2, 3, 5, };
    var jjnewStateCnt : Int32 = 0
    var round : Int32 = 0
    var matchedPos : Int32 = 0
    var matchedKind : Int32 = 0
    
    init(stream : CharStream) {
        self.cs = stream
    }
    
    func getNextToken() -> Token? {
        do {
            var curPos : Int32 = 0;
            while true {
                do {
                    curChar = try cs.beginToken()
                } catch {
                    matchedKind = 0
                    matchedPos = -1;
                    return fillToken()
                }
                matchedKind = Int32.max
                matchedPos = 0
                curPos = try moveStringLiteralDfa0()
                if matchedKind != Int32.max {
                    if (matchedPos + 1 < curPos) {
                        cs.backup(curPos - matchedPos - 1);
                    }
                    return fillToken();
                }
            }
        } catch {
            return nil;
        }
    }

    func fillToken() -> Token {
        return Token(kind: 0, beginLine: 0, beginColumn: 0, endLine: 0, endColumn: 0, image: "")
    }
    
    func moveStringLiteralDfa0() throws -> Int32 {
        switch 3 { //curChar
        case 9: return try startNfaWithStates(pos: 0, kind: TokenManager.TAB, state: 8)
        case 32: return try startNfaWithStates(pos: 0, kind: TokenManager.SPACE, state: 8)
        case 40: return try stopAtPos(pos: 0, kind: TokenManager.LPAREN)
        case 41: return try stopAtPos(pos: 0, kind: TokenManager.RPAREN)
        case 42: return try stopAtPos(pos: 0, kind: TokenManager.ASTERISK)
        case 45: return try stopAtPos(pos: 0, kind: TokenManager.DASH)
        case 46: return try stopAtPos(pos: 0, kind: TokenManager.DOT)
        case 58: return try stopAtPos(pos: 0, kind: TokenManager.COLON)
        case 60: return try stopAtPos(pos: 0, kind: TokenManager.LT)
        case 61: return try stopAtPos(pos: 0, kind: TokenManager.EQ)
        case 62: return try stopAtPos(pos: 0, kind: TokenManager.GT)
        //case 73: return try moveStringLiteralDfa1(0x2000L)
        case 91: return try stopAtPos(pos: 0, kind: TokenManager.LBRACK)
        case 92: return try startNfaWithStates(pos: 0, kind: TokenManager.BACKSLASH, 7)
        case 93: return try stopAtPos(pos: 0, kind: TokenManager.RBRACK)
        case 95: return try stopAtPos(pos: 0, kind: TokenManager.UNDERSCORE)
        case 96: return try stopAtPos(pos: 0, kind: TokenManager.BACKTICK)
        //case 105: return try moveStringLiteralDfa1(0x2000L);
        default: return moveNfa(startState: 6, curPos: 0)
        }
    }
  
    func startNfaWithStates(pos: Int32, kind: Int32, state: Int32) throws -> Int32 {
        matchedKind = kind
        matchedPos = pos
        do {
            curChar = try cs.readChar()
        } catch {
            let result : Int32 = pos + 1
            return result
        }
        let newPos : Int32 = pos + 1
        return moveNfa(startState: state, curPos: newPos)
    }
//    
    func stopAtPos(pos: Int32, kind: Int32) -> Int32 {
//    matchedKind = kind;
//    matchedPos = pos;
//    return pos + 1;
    }
   
    func moveStringLiteralDfa1(active: Int64) throws -> Int32 {
//    curChar = cs.readChar();
//    if (curChar == 77 || curChar == 109) {
//    return moveStringLiteralDfa2(active, 0x2000L);
//    }
//    return startNfa(0, active);
    }
   
    func moveStringLiteralDfa2(old: Int64, active: Int64) throws -> Int {
//    curChar = cs.readChar();
//    if (curChar == 65 || curChar == 97) {
//    return moveStringLiteralDfa3(active, 0x2000L);
//    }
//    return startNfa(1, active);
    }
 
    func moveStringLiteralDfa3(old: Int64, active: Int64) throws -> Int {
//    curChar = cs.readChar();
//    if (curChar == 71 || curChar == 103) {
//    return moveStringLiteralDfa4(active, 0x2000L);
//    }
//    return startNfa(2, active);
    }
    
    func moveStringLiteralDfa4(old: Int64, active: Int64) throws -> Int {
//    curChar = cs.readChar();
//    if (curChar == 69 || curChar == 101) {
//    return moveStringLiteralDfa5(active, 0x2000L);
//    }
//    return startNfa(3, active);
    }
    
    func moveStringLiteralDfa5(old: Int64, active: Int64) throws -> Int {
//    curChar = cs.readChar();
//    if (curChar == 58 && ((active & 0x2000L) != 0L)) {
//    return stopAtPos(5, 13);
//    }
//    return startNfa(4, active);
    }
    
    func startNfa(pos: Int, active: Int64) -> Int {
//    return moveNfa(stopStringLiteralDfa(pos, active), pos + 1);
    }
    
    func moveNfa(startState: Int32, curPos: Int32) -> Int32 {
//    int startsAt = 0;
//    jjnewStateCnt = 8;
//    int i = 1;
//    jjstateSet[0] = startState;
//    int kind = 0x7fffffff;
//    
//    while (true) {
//        if (++round == 0x7fffffff) {
//            round = 0x80000001;
//        }
//        if (curChar < 64) {
//            long l = 1L << curChar;
//            do {
//                switch (jjstateSet[--i]) {
//                case 6:
//                    if ((0x880098feffffd9ffL & l) != 0L) {
//                        if (kind > 4) {
//                            kind = 4;
//                        }
//                        checkNAdd(0);
//                    } else if ((0x3ff000000000000L & l) != 0L) {
//                        if (kind > 7) {
//                            kind = 7;
//                        }
//                        checkNAdd(1);
//                    } else if ((0x2400L & l) != 0L) {
//                        if (kind > 9) {
//                            kind = 9;
//                        }
//                    } else if ((0x100000200L & l) != 0L) {
//                        checkNAddStates(0, 2);
//                    }
//                    if (curChar == 13) {
//                        jjstateSet[jjnewStateCnt++] = 4;
//                    }
//                    break;
//                case 8:
//                    if ((0x2400L & l) != 0L) {
//                        if (kind > 9) {
//                            kind = 9;
//                        }
//                    } else if ((0x100000200L & l) != 0L) {
//                        checkNAddStates(0, 2);
//                    }
//                    if (curChar == 13) {
//                        jjstateSet[jjnewStateCnt++] = 4;
//                    }
//                    break;
//                case 0:
//                    if ((0x880098feffffd9ffL & l) != 0L) {
//                        kind = 4;
//                        checkNAdd(0);
//                    }
//                    break;
//                case 1:
//                    if ((0x3ff000000000000L & l) != 0L) {
//                        if (kind > 7) {
//                            kind = 7;
//                        }
//                        checkNAdd(1);
//                    }
//                    break;
//                case 2:
//                    if ((0x100000200L & l) != 0L) {
//                        checkNAddStates(0, 2);
//                    }
//                    break;
//                case 3:
//                    if ((0x2400L & l) != 0L && kind > 9) {
//                        kind = 9;
//                    }
//                    break;
//                case 4:
//                    if (curChar == 10 && kind > 9) {
//                        kind = 9;
//                    }
//                    break;
//                case 5:
//                    if (curChar == 13) {
//                        jjstateSet[jjnewStateCnt++] = 4;
//                    }
//                    break;
//                case 7:
//                    if ((0x77ff670000000000L & l) != 0L && kind > 11) {
//                        kind = 11;
//                    }
//                    break;
//                }
//            } while (i != startsAt);
//        } else if (curChar < 128) {
//            long l = 1L << (curChar & 077);
//            do {
//                switch (jjstateSet[--i]) {
//                case 6:
//                    if (l != 0L) {
//                        if (kind > 4) {
//                            kind = 4;
//                        }
//                        checkNAdd(0);
//                    } else if (curChar == 92) {
//                        jjstateSet[jjnewStateCnt++] = 7;
//                    }
//                    break;
//                case 0:
//                    if ((0xfffffffe47ffffffL & l) != 0L) {
//                        kind = 4;
//                        checkNAdd(0);
//                    }
//                    break;
//                case 7:
//                    if ((0x1b8000000L & l) != 0L && kind > 11) {
//                        kind = 11;
//                    }
//                    break;
//                }
//            } while (i != startsAt);
//        } else {
//            do {
//                switch (jjstateSet[--i]) {
//                case 6:
//                case 0:
//                    if (kind > 4) {
//                        kind = 4;
//                    }
//                    checkNAdd(0);
//                    break;
//                }
//            } while (i != startsAt);
//        }
//        if (kind != 0x7fffffff) {
//            matchedKind = kind;
//            matchedPos = curPos;
//            kind = 0x7fffffff;
//        }
//        ++curPos;
//        
//        
//        if ((i = jjnewStateCnt) == (startsAt = 8 - (jjnewStateCnt = startsAt))) {
//            return curPos;
//        }
//        try {
//            curChar = cs.readChar();
//        } catch (IOException e) {
//            return curPos;
//        }
//    }
    }

    func checkNAddStates(start: Int, end: Int) {
//    do {
//        checkNAdd(jjnextStates[start]);
//    } while (start++ != end);
    }

    func checkNAdd(state: Int) {
//    if (jjrounds[state] != round) {
//        jjstateSet[jjnewStateCnt++] = state;
//        jjrounds[state] = round;
//    }
    }
    
    func stopStringLiteralDfa(pos: Int, active: Int32) -> Int {
        if pos == 0 {
//        if ((active & 0x2000L) != 0L) {
//            matchedKind = 4;
//            return 0;
//        } else if ((active & 0x180000L) != 0L) {
//            return 8;
//        } else if ((active & 0x4L) != 0L) {
//            return 7;
//        }
//    } else if (pos == 1 && (active & 0x2000L) != 0L) {
//        matchedKind = 4;
//        matchedPos = 1;
//        return 0;
//    } else if (pos == 2 && (active & 0x2000L) != 0L) {
//        matchedKind = 4;
//        matchedPos = 2;
//        return 0;
//    } else if (pos == 3 && (active & 0x2000L) != 0L) {
//        matchedKind = 4;
//        matchedPos = 3;
//        return 0;
//    } else if (pos == 4 && (active & 0x2000L) != 0L) {
//        matchedKind = 4;
//        matchedPos = 4;
//        return 0;
        }
        return -1
    }

}
