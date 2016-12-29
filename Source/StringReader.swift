import Foundation

public class StringReader {
    
    var index: Int
    var text: String
    
    public init(text: String) {
        self.index = 0
        self.text = text
    }
    
    public func read(_ buffer: inout [Character], offset: Int, length: Int) -> Int {
        if((self.index < text.characters.count) && text.substring(from: text.characters.index(text.startIndex, offsetBy: index)).characters.count > 0) {
            var charactersRead = 0
            for i in 0..<length {
                if((self.index + i) < text.characters.count) {
                    let c = text[text.characters.index(text.startIndex, offsetBy: self.index + i)]
                    buffer.insert(c, at: offset + i)
                    charactersRead += 1
                }
            }
            index += length;
            return charactersRead;
        }
        return -1;
    }
    
}
