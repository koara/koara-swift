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
                let c = text[index + 1]
                buffer.insert(c, at: offset + i)
                charactersRead += 1
            }
            
            /*for (var i = 0; i < length; i++) {
                var start = this.index + i;
                var c = this.text.toString().substring(start, start + 1);
                
                if (c !== "") {
                    buffer[offset + i] = c;
                    charactersRead++;
                }
            }*/
            index += length;
            return charactersRead;
        }
        return -1;
    }
    
}
