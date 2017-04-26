public class TokenManager {
    
    public static let EOF : Int32 = 0
    public static let ASTERISK : Int32  = 1
    public static let BACKSLASH : Int32  = 2
    public static let BACKTICK : Int32  = 3
    public static let CHAR_SEQUENCE : Int32  = 4
    public static let COLON : Int32  = 5
    public static let DASH : Int32  = 6
    public static let DIGITS : Int32  = 7
    public static let DOT : Int32  = 8
    public static let EOL : Int32  = 9
    public static let EQ : Int32  = 10
    public static let ESCAPED_CHAR : Int32  = 11
    public static let GT : Int32  = 12
    public static let IMAGE_LABEL : Int32  = 13
    public static let LBRACK : Int32  = 14
    public static let LPAREN : Int32  = 15
    public static let LT : Int32  = 16
    public static let RBRACK : Int32  = 17
    public static let RPAREN : Int32  = 18
    public static let SPACE : Int32  = 19
    public static let TAB : Int32  = 20
    public static let UNDERSCORE : Int32  = 21

    let cs : CharStream
    var jjrounds = Array<Int64>(repeating: 0, count: 8)
    var jjstateSet = Array<Int32>(repeating: 0, count: 16)

    var curChar : Character?
    var jjnextStates = Array<Int>(arrayLiteral: 2, 3, 5)
    var jjnewStateCnt : Int = 0
    var round : Int64 = 0
    var matchedPos : Int32 = 0
    var matchedKind : Int32 = 0
    
    public init(stream : CharStream) {
        self.cs = stream
    }

    public func getNextToken() -> Token? {
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
                        cs.backup(Int(curPos - matchedPos - 1))
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
            return stopAtPos(pos: 0, kind: TokenManager.LPAREN)
        case 41:
            return stopAtPos(pos: 0, kind: TokenManager.RPAREN)
        case 42 :
            return stopAtPos(pos: 0, kind: TokenManager.ASTERISK)
        case 45:
            return stopAtPos(pos: 0, kind: TokenManager.DASH)
        case 46:
            return stopAtPos(pos: 0, kind: TokenManager.DOT)
        case 58:
            return stopAtPos(pos: 0, kind: TokenManager.COLON)
        case 60:
            return stopAtPos(pos: 0, kind: TokenManager.LT)
        case 61:
            return stopAtPos(pos: 0, kind: TokenManager.EQ)
        case 62:
            return stopAtPos(pos: 0, kind: TokenManager.GT)
        case 73:
            return try moveStringLiteralDfa1(active: 0x2000)
        case 91:
            return stopAtPos(pos: 0, kind: TokenManager.LBRACK)
        case 92:
            return try startNfaWithStates(0, TokenManager.BACKSLASH, 7)
        case 93:
            return stopAtPos(pos: 0, kind: TokenManager.RBRACK)
        case 95:
            return stopAtPos(pos: 0, kind: TokenManager.UNDERSCORE)
        case 96:
            return stopAtPos(pos: 0, kind: TokenManager.BACKTICK)
        case 105:
            return try moveStringLiteralDfa1(active: 0x2000);
        default:
            return moveNfa(startState: 6, curPos: 0)
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
        return moveNfa(startState: state, curPos: newPos)
    }
    
    func stopAtPos(pos: Int32, kind: Int32) -> Int32 {
        matchedKind = kind
        matchedPos = pos
        let newPos = pos + 1
        return newPos
    }

    func moveStringLiteralDfa1(active: Int64) throws -> Int32 {
        curChar = try cs.readChar()
        if (curChar?.intValue == 77 || curChar?.intValue == 109) {
            return try moveStringLiteralDfa2(old: active, active: 0x2000)
        }
        return startNfa(pos: 0, active: active)
    }

    func moveStringLiteralDfa2(old: Int64, active: Int64) throws -> Int32 {
        curChar = try cs.readChar()
        if (curChar?.intValue == 65 || curChar?.intValue == 97) {
            return try moveStringLiteralDfa3(old: active, active: 0x2000)
        }
        return startNfa(pos: 1, active: active)
    }
    
    func moveStringLiteralDfa3(old: Int64, active: Int64) throws -> Int32 {
        curChar = try cs.readChar()
        if (curChar?.intValue == 71 || curChar?.intValue == 103) {
            return try moveStringLiteralDfa4(old: active, active: 0x2000)
        }
        return startNfa(pos: 2, active: active)
    }

    func moveStringLiteralDfa4(old: Int64, active: Int64) throws -> Int32 {
        curChar = try cs.readChar()
        if (curChar?.intValue == 69 || curChar?.intValue == 101) {
            return try moveStringLiteralDfa5(old: active, active: 0x2000)
        }
        return startNfa(pos: 3, active: active)
    }

    func moveStringLiteralDfa5(old: Int64, active: Int64) throws -> Int32 {
        curChar = try cs.readChar()
        if (curChar?.intValue == 58 && ((active & 0x2000) != 0)) {
            return stopAtPos(pos: 5, kind: 13)
        }
        return startNfa(pos: 4, active: active)
    }

    func startNfa(pos: Int, active: Int64) -> Int32 {
        return moveNfa(startState: Int32(stopStringLiteralDfa(pos: pos, active: Int64(active))), curPos: Int32(pos + 1))
    }
  
    func moveNfa(startState: Int32, curPos: Int32) -> Int32 {
        var curPos = curPos
        var startsAt : Int = 0
        jjnewStateCnt = 8
        var i : Int = 1
        jjstateSet[0] = startState
        var kind = 0x7fffffff

        while true {
            
            round += 1
            if round == 0x7fffffff {
                round = 0x80000001
            }
            if ((curChar?.intValue!)! < 64) {
                let l : Int64 = Int64(1) << Int64(curChar!.intValue!)
                repeat {
                    i -= 1
                    switch jjstateSet[i] {
                    case 6:
                        if (-8646743063567279617 & l) != 0 {
                            if kind > 4 {
                                kind = 4
                            }
                            checkNAdd(state: 0)
                        } else if (0x3ff000000000000 & l) != 0 {
                            if (kind > 7) {
                                kind = 7
                            }
                            checkNAdd(state: 1)
                        } else if (0x2400 & l) != 0 {
                            if (kind > 9) {
                                kind = 9
                            }
                        } else if (0x100000200 & l) != 0 {
                            checkNAddStates(start: 0, end: 2)
                        }
                        if (curChar?.intValue == 13) {
                            jjnewStateCnt += 1
                            jjstateSet[jjnewStateCnt] = 4
                        }
                    case 8:
                        if (0x2400 & l) != 0 {
                            if (kind > 9) {
                                kind = 9
                            }
                        } else if (0x100000200 & l) != 0 {
                            checkNAddStates(start: 0, end: 2)
                        }
                        if (curChar?.intValue == 13) {
                            jjnewStateCnt += 1
                            jjstateSet[jjnewStateCnt] = 4
                        }
                    case 0:
                        if ((-8646743063567279617 & l) != 0) {
                            kind = 4
                            checkNAdd(state: 0)
                        }
                    case 1:
                        if (0x3ff000000000000 & l) != 0 {
                            if (kind > 7) {
                                kind = 7
                            }
                            checkNAdd(state: 1)
                        }
                    case 2:
                        if (0x100000200 & l) != 0 {
                            checkNAddStates(start: 0, end: 2)
                        }
                    case 3:
                        if (0x2400 & l) != 0 && kind > 9 {
                            kind = 9
                        }
                    case 4:
                        if (curChar?.intValue == 10 && kind > 9) {
                            kind = 9
                        }
                    case 5:
                        if (curChar?.intValue == 13) {
                            jjnewStateCnt += 1
                            jjstateSet[jjnewStateCnt] = 4
                        }
                    case 7:
                        if ((0x77ff670000000000 & l) != 0 && kind > 11) {
                            kind = 11
                        }
                    default: break
                    }
                } while i != startsAt
            } else if (curChar?.intValue)! < 128 {
                let l = Int64(1) << Int64((curChar?.intValue)! & 0o77)
                repeat {
                    i -= 1

                    switch jjstateSet[i] {
                    case 6:
                        if l != 0 {
                            if kind > 4 {
                                kind = 4
                            }
                            checkNAdd(state: 0)
                        } else if (curChar?.intValue == 92) {
                            jjnewStateCnt += 1
                            jjstateSet[jjnewStateCnt] = 7
                        }
                   case 0:
                        if ((0xfffffffe47ffffff as UInt64) & UInt64(l)) != 0 {
                            kind = 4
                            checkNAdd(state: 0)
                        }
                    case 7:
                        if ((0x1b8000000 & l) != 0 && kind > 11) {
                            kind = 11
                        }
                    default:
                        break;
                    }
                } while (i != startsAt)
                
                
            } else {
                repeat {
                    i-=1
                    switch (jjstateSet[i]) {
                    case 6:
                        fallthrough
                    case 0:
                        if (kind > 4) {
                            kind = 4
                        }
                        checkNAdd(state: 0)
                    default: break
                    }
                } while (i != startsAt)
            }
            if (kind != 0x7fffffff) {
                matchedKind = Int32(kind)
                matchedPos = curPos
                kind = 0x7fffffff
            }
            curPos += 1
            i = jjnewStateCnt
            jjnewStateCnt = startsAt
            startsAt = 8 - jjnewStateCnt
            if i == startsAt {
                return curPos
            }
            do {
                curChar = try cs.readChar()
            } catch {
                return curPos
            }
        }
    }

    func checkNAddStates(start: Int, end: Int) {
        var start = start
        repeat {
            checkNAdd(state: jjnextStates[start])
            start += 1
        } while (start <= end)
    }

    func checkNAdd(state: Int) {
        if (jjrounds[state] != round) {
            jjstateSet[jjnewStateCnt] = Int32(state)
            jjnewStateCnt += 1

            jjrounds[state] = round
        }
    }

    func stopStringLiteralDfa(pos: Int, active: Int64) -> Int {
        if pos == 0 {
            if (active & 0x2000) != 0 {
                matchedKind = 4
                return 0
            } else if ((active & 0x180000) != 0) {
                return 8
            } else if ((active & 0x4) != 0) {
                return 7
            }
        } else if (pos == 1 && (active & 0x2000) != 0) {
            matchedKind = 4
            matchedPos = 1
            return 0
        } else if (pos == 2 && (active & 0x2000) != 0) {
            matchedKind = 4
            matchedPos = 2
            return 0
        } else if (pos == 3 && (active & 0x2000) != 0) {
            matchedKind = 4
            matchedPos = 3
            return 0
        } else if (pos == 4 && (active & 0x2000) != 0) {
            matchedKind = 4
            matchedPos = 4
            return 0
        }
        return -1
    }
    
}
