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
//    private int[] jjrounds = new int[8]
//    private int[] jjstateSet = new int[16]
    var curChar : Character?
//    private int[] jjnextStates = { 2, 3, 5, }
    var jjnewStateCnt : Int32 = 0
    var round : Int32 = 0
    var matchedPos : Int32 = 0
    var matchedKind : Int32 = 0
    
    init(stream : CharStream) {
        self.cs = stream
    }

    func getNextToken() -> Token? {
        do {
            var curPos : Int32 = 0
            while true {
                do {
                    curChar = try cs.beginToken()
                } catch {
                    matchedKind = 0
                    matchedPos = -1
                    return fillToken()
                }
                matchedKind = Int32.max
                matchedPos = 0
                curPos = try moveStringLiteralDfa0()
                if matchedKind != Int32.max {
                    if (matchedPos + 1 < curPos) {
                        cs.backup(curPos - matchedPos - 1)
                    }
                    return fillToken()
                }
            }
        } catch {
            return nil
        }
    }
    
    func fillToken() -> Token {
        return Token(matchedKind, cs.getBeginLine(), cs.getBeginColumn(), cs.getEndLine(), cs.getEndColumn(), cs.getImage())
    }
    
    func moveStringLiteralDfa0() throws -> Int32 {
        switch Int((String(describing: curChar!).unicodeScalars.first?.value)!) {
        case 9:
            return try startNfaWithStates(0, TokenManager.TAB, 8)
        case 32:
            return try startNfaWithStates(0, TokenManager.SPACE, 8)
        case 40:
            return stopAtPos(0, TokenManager.LPAREN)
        case 41:
            return stopAtPos(0, TokenManager.RPAREN)
        case 42 :
            return stopAtPos(0, TokenManager.ASTERISK)
        case 45:
            return stopAtPos(0, TokenManager.DASH)
        case 46:
            return stopAtPos(0, TokenManager.DOT)
        case 58:
            return stopAtPos(0, TokenManager.COLON)
        case 60:
            return stopAtPos(0, TokenManager.LT)
        case 61:
            return stopAtPos(0, TokenManager.EQ)
        case 62:
            return stopAtPos(0, TokenManager.GT)
        case 91:
            return stopAtPos(0, TokenManager.LBRACK)
        case 92:
            return try startNfaWithStates(0, TokenManager.BACKSLASH, 7)
        case 93:
            return stopAtPos(0, TokenManager.RBRACK)
        case 95:
            return stopAtPos(0, TokenManager.UNDERSCORE)
        case 96:
            return stopAtPos(0, TokenManager.BACKTICK)
        default:
            //return moveNfa(startState: 6, curPos: 0)
            return 0
        }
    }
  
    func startNfaWithStates(_ pos: Int32, _ kind: Int32, _ state: Int32) throws -> Int32 {
        matchedKind = kind
        matchedPos = pos
        do {
            curChar = try cs.readChar()
        } catch {
            return Int32(pos + 1)
        }
        let newPos : Int32 = pos + 1
        return 0
        //return moveNfa(startState: state, curPos: newPos)
    }
    
    func stopAtPos(_ pos: Int32, _ kind: Int32) -> Int32 {
        matchedKind = kind
        matchedPos = pos
        let newPos = pos + 1
        return newPos
    }
//   
//    func moveStringLiteralDfa1(active: Int64) throws -> Int32 {
//        curChar = try cs.readChar()
//        let s = String(curChar).unicodeScalars
//        if (s[s.startIndex].value == 77 || s[s.startIndex].value == 109) {
//            return try moveStringLiteralDfa2(old: active, active: 0x2000)
//        }
//        return startNfa(pos: 0, active: active)
//    }
//   
//    func moveStringLiteralDfa2(old: Int64, active: Int64) throws -> Int32 {
//        curChar = try cs.readChar()
//        let s = String(curChar).unicodeScalars
//        if (s[s.startIndex].value == 65 || s[s.startIndex].value == 97) {
//            return moveStringLiteralDfa3(active, 0x2000)
//        }
//        return startNfa(pos: 1, active: active)
//    }
// 
//    func moveStringLiteralDfa3(old: Int64, active: Int64) throws -> Int32 {
//        curChar = try cs.readChar()
//        let s = String(curChar).unicodeScalars
//        if (s[s.startIndex].value == 71 || s[s.startIndex].value == 103) {
//            return moveStringLiteralDfa4(old: active, active: 0x2000)
//        }
//        return startNfa(pos: 2, active: active)
//    }
//    
//    func moveStringLiteralDfa4(old: Int64, active: Int64) throws -> Int32 {
//        curChar = try cs.readChar()
//        let s = String(curChar).unicodeScalars
//        if (s[s.startIndex].value == 69 || s[s.startIndex].value == 101) {
//            return try moveStringLiteralDfa5(old: active, active: 0x2000)
//        }
//        return startNfa(pos: 3, active: active)
//    }
//    
//    func moveStringLiteralDfa5(old: Int64, active: Int64) throws -> Int32 {
//        curChar = try cs.readChar()
//        let s = String(curChar).unicodeScalars
//        if (s[s.startIndex].value == 58 && ((active & 0x2000) != 0)) {
//            return stopAtPos(pos: 5, kind: 13)
//        }
//        return startNfa(pos: 4, active: active)
//    }
//    
//    func startNfa(pos: Int, active: Int64) -> Int32 {
//        return moveNfa(startState: Int32(stopStringLiteralDfa(pos: pos, active: Int32(active))), curPos: pos + 1)
//    }
//    
//    func moveNfa(startState: Int32, curPos: Int32) -> Int32 {
//        var curPos = curPos
//        var startsAt : Int = 0
//        var jjnewStateCnt : Int = 8
//        var i : Int = 1
//        //jjstateSet[0] = startState
//        var kind = 0x7fffffff
//
//        while true {
//            round += 1
//            if (round == 0x7fffffff) {
//                round = 0x80000001
//            }
//            let s = String(curChar).unicodeScalars
//            if (s[s.startIndex].value < 64) {
//                var l : Int64 = 1 << s[s.startIndex].value
//                repeat {
//                    i -= 1
//                    switch jjstateSet[i] {
////                    case 6:
////                    if ((0x880098feffffd9ffL & l) != 0L) {
////                        if (kind > 4) {
////                            kind = 4
////                        }
////                        checkNAdd(0)
////                    } else if ((0x3ff000000000000L & l) != 0L) {
////                        if (kind > 7) {
////                            kind = 7
////                        }
////                        checkNAdd(1)
////                    } else if ((0x2400L & l) != 0L) {
////                        if (kind > 9) {
////                            kind = 9
////                        }
////                    } else if ((0x100000200L & l) != 0L) {
////                        checkNAddStates(0, 2)
////                    }
////                    if (curChar == 13) {
////                        jjstateSet[jjnewStateCnt++] = 4
////                    }
////                    break
////                case 8:
////                    if ((0x2400L & l) != 0L) {
////                        if (kind > 9) {
////                            kind = 9
////                        }
////                    } else if ((0x100000200L & l) != 0L) {
////                        checkNAddStates(0, 2)
////                    }
////                    if (curChar == 13) {
////                        jjstateSet[jjnewStateCnt++] = 4
////                    }
////                    break
////                case 0:
////                    if ((0x880098feffffd9ffL & l) != 0L) {
////                        kind = 4
////                        checkNAdd(0)
////                    }
////                    break
////                case 1:
////                    if ((0x3ff000000000000L & l) != 0L) {
////                        if (kind > 7) {
////                            kind = 7
////                        }
////                        checkNAdd(1)
////                    }
////                    break
////                case 2:
////                    if ((0x100000200L & l) != 0L) {
////                        checkNAddStates(0, 2)
////                    }
////                    break
////                case 3:
////                    if ((0x2400L & l) != 0L && kind > 9) {
////                        kind = 9
////                    }
////                    break
////                case 4:
////                    if (curChar == 10 && kind > 9) {
////                        kind = 9
////                    }
////                    break
////                case 5:
////                    if (curChar == 13) {
////                        jjstateSet[jjnewStateCnt++] = 4
////                    }
////                    break
////                case 7:
////                    if ((0x77ff670000000000L & l) != 0L && kind > 11) {
////                        kind = 11
////                    }
////                    break
////                }
//                } while i != startsAt
//        } else if s[s.startIndex].value < 128 {
////            long l = 1L << (curChar & 077)
////            do {
////                switch (jjstateSet[--i]) {
////                case 6:
////                    if (l != 0L) {
////                        if (kind > 4) {
////                            kind = 4
////                        }
////                        checkNAdd(0)
////                    } else if (curChar == 92) {
////                        jjstateSet[jjnewStateCnt++] = 7
////                    }
////                    break
////                case 0:
////                    if ((0xfffffffe47ffffffL & l) != 0L) {
////                        kind = 4
////                        checkNAdd(0)
////                    }
////                    break
////                case 7:
////                    if ((0x1b8000000L & l) != 0L && kind > 11) {
////                        kind = 11
////                    }
////                    break
////                }
////            } while (i != startsAt)
//            } else {
////            do {
////                switch (jjstateSet[--i]) {
////                case 6:
////                case 0:
////                    if (kind > 4) {
////                        kind = 4
////                    }
////                    checkNAdd(0)
////                    break
////                }
////            } while (i != startsAt)
//            }
//            if (kind != 0x7fffffff) {
//                matchedKind = Int32(kind)
//                matchedPos = curPos
//                kind = 0x7fffffff
//            }
//            curPos += 1
//
////        if ((i = jjnewStateCnt) == (startsAt = 8 - (jjnewStateCnt = startsAt))) {
////            return curPos
////        }
////        try {
////            curChar = cs.readChar()
////        } catch (IOException e) {
////            return curPos
////        }
//        }
//    }
//
//    func checkNAddStates(start: Int, end: Int) {
////    do {
////        checkNAdd(jjnextStates[start])
////    } while (start++ != end)
//    }
//
//    func checkNAdd(state: Int) {
////    if (jjrounds[state] != round) {
////        jjstateSet[jjnewStateCnt++] = state
////        jjrounds[state] = round
////    }
//    }
//    
//    func stopStringLiteralDfa(pos: Int, active: Int32) -> Int {
//        if pos == 0 {
////        if ((active & 0x2000L) != 0L) {
////            matchedKind = 4
////            return 0
////        } else if ((active & 0x180000L) != 0L) {
////            return 8
////        } else if ((active & 0x4L) != 0L) {
////            return 7
////        }
////    } else if (pos == 1 && (active & 0x2000L) != 0L) {
////        matchedKind = 4
////        matchedPos = 1
////        return 0
////    } else if (pos == 2 && (active & 0x2000L) != 0L) {
////        matchedKind = 4
////        matchedPos = 2
////        return 0
////    } else if (pos == 3 && (active & 0x2000L) != 0L) {
////        matchedKind = 4
////        matchedPos = 3
////        return 0
////    } else if (pos == 4 && (active & 0x2000L) != 0L) {
////        matchedKind = 4
////        matchedPos = 4
////        return 0
//        }
//        return -1
//    }
//
}
