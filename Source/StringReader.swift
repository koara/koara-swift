import Foundation

class StringReader {
    
    var index: Int
    var text: String
    
    init(text: String) {
        self.index = 0
        self.text = text
    }
    
    func read(buffer: [Character], offset: Int, length: Int) -> Int {
//        if(text.substringFromIndex(text.startIndex.advancedBy(index)).characters.count > 0) {
            var charactersRead = 0
            for i in 0...(length - 1) {
            
//                var start = index + i;
                
//                var c = this.text.toString().substring(start, start + 1);
//                
//                if (c !== "") {
//                    buffer[0] = "a"
                    charactersRead += 1
//                }
            }
            index += length;
            return charactersRead;
//        }
        
//        return -1;
    }
    
}