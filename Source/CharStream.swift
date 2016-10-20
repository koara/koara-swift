class CharStream {

    var available = 4096
    var bufsize = 4096
    var tokenBegin = 0
    var bufcolumn = [Int]()
    var bufpos = -1
    var bufline = [Int]()
    var column = 0
    var line = 1
    var prevCharIsLF = false
    var reader : Reader
    var buffer = [Int:Character]()
    var maxNextCharInd = 0
    var inBuf = 0
    var tabSize = 4

    init(reader: Reader) {
        self.reader = reader
    }
    
    func beginToken() -> Character {
        tokenBegin = -1
        let c = readChar()
        tokenBegin = bufpos;
        return c
    }
    
    
    func readChar() -> Character {
        if inBuf > 0 {
            inBuf -= 1;
//            if ((bufpos += 1) == bufsize) {
//                bufpos = 0;
//            }
//            return this.buffer[this.bufpos];
        }
        bufpos += 1
        if (bufpos >= maxNextCharInd) {
            fillBuff()
        }
        
        print("///// \(buffer)")
//        
//        var c = this.buffer[this.bufpos];
//        
//        this.updateLineColumn(c);
//        return c;
        return "a".characters.first!
    }
    
    func fillBuff() {
        if maxNextCharInd == available {
            if available == bufsize {
                bufpos = 0
                maxNextCharInd = 0
                if tokenBegin > 2048 {
                    available = tokenBegin
                }
            } else {
                available = bufsize
            }
        }
        var i = 0
 
        do {
            i = reader.read(&buffer, offset: maxNextCharInd, length: (available - maxNextCharInd))
            if (i == -1) {
                //throw Error
            } else {
                maxNextCharInd += i;
            }
        } catch {
            bufpos -= 1
//            this.backup(0);
//            if (this.tokenBegin === -1) {
//                this.tokenBegin = this.bufpos;
//            }
//            throw e;
        }
    }
    
    func backup(_ amount : Int) {
        inBuf += amount
        bufpos -= amount
        if (bufpos < 0) {
            bufpos += bufsize;
        }
    }
    
    func updateLineColumn(_ c : String) {
        column += 1
        if prevCharIsLF {
            prevCharIsLF = false
            column = 1;
            line += column;
        }
    
//        switch c {
//          case "\n":
//            this.prevCharIsLF = true;
//            break;
//          case "\t":
//            this.column--;
//            this.column += this.tabSize - this.column % this.tabSize;
//            break;
//           default:
//            break;
//          }
        bufline[bufpos] = line;
        bufcolumn[bufpos] = column;
    }
    
    func getImage() {
//        if (this.bufpos >= this.tokenBegin) {
//            return this.buffer.slice(this.tokenBegin, this.bufpos + 1).join("");
//        }
//        return this.buffer.slice(this.tokenBegin, this.bufsize).join("") +
//            this.buffer.slice(0, this.bufpos + 1).join("");
    }
    
    func getEndColumn() -> Int {
        return 1
//        return this.tokenBegin in this.bufcolumn ? this.bufcolumn[this.bufpos] : 0;
    }
    
    func getEndLine() -> Int {
        return 1
//        return this.tokenBegin in this.bufline ? this.bufline[this.bufpos] : 0;
    }
    
    func getBeginColumn() -> Int {
        return 1
//        return this.bufpos in this.bufcolumn ? this.bufcolumn[this.tokenBegin] : 0;
    }
    
    func getBeginLine() -> Int {
        return 1
//        return this.bufpos in this.bufline ? this.bufline[this.tokenBegin] : 0;
    }

}
