import Foundation

class StringReader : Reader {
    
    var index: Int
    var text: String
    
    init(text: String) {
        self.index = 0
        self.text = text
    }
    
    func read(_ buffer: inout [Int:Character], offset: Int, length: Int) -> Int {
        if((self.index < text.characters.count) && text.substring(from: text.characters.index(text.startIndex, offsetBy: index)).characters.count > 0) {
            var charactersRead = 0
            for i in 0..<length {
                
               
            
                
                if((self.index + i) < text.characters.count) {
                    
                let c = text[text.characters.index(text.startIndex, offsetBy: self.index + i)]
                buffer[offset + i] = c
                charactersRead += 1
                                }
            }
            index += length;
            return charactersRead;
        }
        return -1;
    }
    
}
