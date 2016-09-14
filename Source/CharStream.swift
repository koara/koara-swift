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
    //    this.reader = reader;
     var buffer = [Character]()
    var maxNextCharInd = 0
    var inBuf = 0
    var tabSize = 4

    init(reader: Reader) {
        //self.reader = reader
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
//        if (++this.bufpos >= this.maxNextCharInd) {
//            this.fillBuff();
//        }
//        
//        var c = this.buffer[this.bufpos];
//        
//        this.updateLineColumn(c);
//        return c;
        return "e".characters.first!
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
//        var i = 0
//        
//        try {
//            if ((i = this.reader.read(this.buffer, this.maxNextCharInd, this.available - this.maxNextCharInd)) === -1) {
//                throw new Error("IOException");
//            } else {
//                this.maxNextCharInd += i;
//            }
//        } catch (e) {
//            --this.bufpos;
//            this.backup(0);
//            if (this.tokenBegin === -1) {
//                this.tokenBegin = this.bufpos;
//            }
//            throw e;
//        }
    }
    
    func backup(amount : Int) {
        inBuf += amount
        bufpos -= amount
        if (bufpos < 0) {
            bufpos += bufsize;
        }
    }
    
    func updateLineColumn(c : String) {
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
    
    func getEndColumn() {
//        return this.tokenBegin in this.bufcolumn ? this.bufcolumn[this.bufpos] : 0;
    }
    
    func getEndLine() {
//        return this.tokenBegin in this.bufline ? this.bufline[this.bufpos] : 0;
    }
    
    func getBeginColumn() {
//        return this.bufpos in this.bufcolumn ? this.bufcolumn[this.tokenBegin] : 0;
    }
    
    func getBeginLine() {
//        return this.bufpos in this.bufline ? this.bufline[this.tokenBegin] : 0;
    }

}
