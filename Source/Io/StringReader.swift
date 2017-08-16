import Foundation

public class StringReader : Reader {
    
    var index: Int
    var text: Array<Character>
    
    public init(text: String) {
        self.index = 0
        self.text = Array(text.characters)
    }
    
    public func read(_ buffer: inout [Character], offset: Int, length: Int) -> Int {
        if (index < text.count) {
            var charactersRead = 0;
            for i in 0..<length {
                let start = index + i
                if(start < text.count) {
                    let c = text[start]
                    if((offset + i) < buffer.count) {
                        buffer[offset + i] = c
                    } else {
                        buffer.insert(c, at: offset + i)
                    }
                    charactersRead += 1
                }
            }
            index += length;
            return charactersRead;
        }
        return -1;
    }
    
}
