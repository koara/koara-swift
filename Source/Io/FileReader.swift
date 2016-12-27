import Foundation

class FileReader {
   
    var index: Int
    var file: URL
    
    init(file: URL) {
        self.file = file
        self.index = 0
    }
    
    func read(_ buffer: inout [Character], offset: Int, length: Int) -> Int {
        var charactersRead = 0
        do {
            let handle: FileHandle? = try FileHandle(forReadingFrom: file)
            if let handle = handle {
                handle.seek(toFileOffset: UInt64(index))
                let fileContent = String(data: handle.readData(ofLength: length), encoding: .utf8)!
            
                if fileContent != "" {
                    for (i, c) in fileContent.characters.enumerated() {
                        buffer.insert(c, at: offset + i)
                        charactersRead += 1
                        index += 1
                    }
                    return charactersRead
                }
                handle.closeFile()
            }
        } catch {
            return -1
        }
        return -1
    }
    
}
