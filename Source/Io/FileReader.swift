import Foundation

public class FileReader {
   
    var index: Int
    var file: URL
    
    public init(file: URL) {
        self.file = file
        self.index = 0
    }
    
    public func read(_ buffer: inout [Character], offset: Int, length: Int) -> Int {
        var charactersRead = 0
        do {
            let handle: FileHandle? = try FileHandle(forReadingFrom: file)
            if let handle = handle {
                print("Index: \(index)")
                handle.seek(toFileOffset: UInt64(index))
                let fileContent = String(data: handle.readData(ofLength: length * 4), encoding: .utf8)!
            
                if fileContent != "" {
                    for (i, c) in fileContent.characters.enumerated() {
                        
                        print("--\(c)--")
                        buffer.insert(c, at: offset + i)
                        charactersRead += 1
                        index += 1
                        if(charactersRead >= length) {
                            return charactersRead
                        }
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
