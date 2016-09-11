class CharStream {

//"use strict";
//
//function CharStream(reader) {
//    this.available = 4096;
//    this.bufsize = 4096;
//    this.tokenBegin = 0;
//    this.bufcolumn = [];
//    this.bufpos = -1;
//    this.bufline = [];
//    this.column = 0;
//    this.line = 1;
//    this.prevCharIsLF = false;
//    this.reader = reader;
//    this.buffer = [];
//    this.maxNextCharInd = 0;
//    this.inBuf = 0;
//    this.tabSize = 4;
//}
//
//CharStream.prototype = {
//    constructor: CharStream,
//    
//    beginToken: function() {
//        this.tokenBegin = -1;
//        var c = this.readChar();
//        
//        this.tokenBegin = this.bufpos;
//        return c;
//    },
//    
//    readChar: function() {
//        if (this.inBuf > 0) {
//            --this.inBuf;
//            if (++this.bufpos === this.bufsize) {
//                this.bufpos = 0;
//            }
//            return this.buffer[this.bufpos];
//        }
//        if (++this.bufpos >= this.maxNextCharInd) {
//            this.fillBuff();
//        }
//        
//        var c = this.buffer[this.bufpos];
//        
//        this.updateLineColumn(c);
//        return c;
//    },
//    
//    fillBuff: function() {
//        if (this.maxNextCharInd === this.available) {
//            if (this.available === this.bufsize) {
//                this.bufpos = 0;
//                this.maxNextCharInd = 0;
//                if (this.tokenBegin > 2048) {
//                    this.available = this.tokenBegin;
//                }
//            } else {
//                this.available = this.bufsize;
//            }
//        }
//        var i = 0;
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
//    },
//    
//    backup: function(amount) {
//        this.inBuf += amount;
//        if ((this.bufpos -= amount) < 0) {
//            this.bufpos += this.bufsize;
//        }
//    },
//    
//    updateLineColumn: function(c) {
//        this.column++;
//        if (this.prevCharIsLF) {
//            this.prevCharIsLF = false;
//            this.column = 1;
//            this.line += this.column;
//        }
//        
//        switch (c) {
//        case "\n":
//            this.prevCharIsLF = true;
//            break;
//        case "\t":
//            this.column--;
//            this.column += this.tabSize - this.column % this.tabSize;
//            break;
//        default:
//            break;
//        }
//        this.bufline[this.bufpos] = this.line;
//        this.bufcolumn[this.bufpos] = this.column;
//    },
//    
//    getImage: function() {
//        if (this.bufpos >= this.tokenBegin) {
//            return this.buffer.slice(this.tokenBegin, this.bufpos + 1).join("");
//        }
//        return this.buffer.slice(this.tokenBegin, this.bufsize).join("") +
//            this.buffer.slice(0, this.bufpos + 1).join("");
//    },
//    
//    getEndColumn: function() {
//        return this.tokenBegin in this.bufcolumn ? this.bufcolumn[this.bufpos] : 0;
//    },
//    
//    getEndLine: function() {
//        return this.tokenBegin in this.bufline ? this.bufline[this.bufpos] : 0;
//    },
//    
//    getBeginColumn: function() {
//        return this.bufpos in this.bufcolumn ? this.bufcolumn[this.tokenBegin] : 0;
//    },
//    
//    getBeginLine: function() {
//        return this.bufpos in this.bufline ? this.bufline[this.tokenBegin] : 0;
//    }
//    
//};
//
}
