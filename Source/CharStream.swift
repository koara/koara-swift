public class CharStream {

    var available = 4096
    var bufSize = 4096
    var tokenBegin = 0
    var bufColumn = Array(repeating: 0, count: 4096)
    var bufPos = -1
    var bufLine = Array(repeating: 0, count: 4096)
    var column = 0
    var line = 1
    var prevCharIsLF = false
    var reader : Reader
    var buffer = [Character](repeating: Character(" "), count: 4096)
    var maxNextCharInd = 0
    var inBuf = 0
    var tabSize = 4

    public init(reader: Reader) {
        self.reader = reader
    }
    
    public func beginToken() throws -> Character {
        tokenBegin = -1
        let c = try readChar()
        tokenBegin = bufPos
        return c
    }
    
    @discardableResult public func readChar() throws -> Character {
        if (inBuf > 0) {
            inBuf -= 1
            bufPos += 1
            if (bufPos == bufSize) {
                bufPos = 0
            }
            return buffer[bufPos]
        }
        bufPos += 1
        if bufPos >= maxNextCharInd {
            try fillBuff()
        }
        let c = buffer[bufPos]
        updateLineColumn(c: c)
        return c
    }
    
    func fillBuff() throws {
        if (maxNextCharInd == available) {
            if (available == bufSize) {
                bufPos = 0;
                maxNextCharInd = 0;
                if (tokenBegin > 2048) {
                    available = tokenBegin;
                }
            } else {
                available = bufSize;
            }
        }
        var i = 0
        do {
            i = reader.read(&buffer, offset: maxNextCharInd, length: (available - maxNextCharInd))
            if (i == -1) {
                throw KoaraError.IOException()
            } else {
                maxNextCharInd += i;
            }
        } catch let e as KoaraError {
            bufPos -= 1
            backup(0)
            if tokenBegin == -1 {
                tokenBegin = bufPos
            }
            throw e
        }
    }
    
    func backup(_ amount : Int) {
        inBuf += amount
        bufPos -= amount
        if (bufPos < 0) {
            bufPos += bufSize;
        }
    }
    
    func updateLineColumn(c : Character) {
        column += 1
        if prevCharIsLF {
            prevCharIsLF = false
            column = 1;
            line += column;
        }
        switch c {
        case "\n":
            prevCharIsLF = true
        case "\t":
            column -= 1
            column += tabSize - column % tabSize
        default:
            break
        }
        bufLine[bufPos] = line;
        bufColumn[bufPos] = column;
    }
    
    public func getImage() -> String {
        if (bufPos >= tokenBegin) {
            return String(buffer[tokenBegin..<(bufPos + 1)])
        }
        return String(buffer[tokenBegin..<(tokenBegin + (bufSize - tokenBegin))]) + String(buffer[0..<(bufPos+1)])
    }
    
    public func getEndColumn() -> Int {
        return bufColumn[bufPos]
    }
    
    public func getEndLine() -> Int {
        return bufLine[bufPos]
    }
    
    public func getBeginColumn() -> Int {
        return bufColumn[tokenBegin]
    }
    
    public func getBeginLine() -> Int {
        return bufLine[tokenBegin]
    }

}
