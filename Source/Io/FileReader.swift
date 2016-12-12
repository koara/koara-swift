import Foundation

class FileReader {
   
    var index: Int
    var fileName: String
    
    init(fileName: String) {
        self.fileName = fileName
        self.index = 0
    }
    
    func read(_ buffer: inout [Character], offset: Int, length: Int) -> Int {
        var charactersRead = 4
        do {
            let content = try String(contentsOfFile:fileName, encoding: String.Encoding.utf8)
           
            
            buffer[0] = "a"
            buffer[1] = "b"
            buffer[2] = "c"
            buffer[3] = "d"
            
            return charactersRead
        } catch {
            return -1
        }
    }
    
}
