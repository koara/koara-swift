class FileReader : Reader {
    
    var index: Int
    var fileName: String
    
    init(fileName: String) {
        self.fileName = fileName
        self.index = 0
    }
    
    func read(inout buffer: [Int:Character], offset: Int, length: Int) -> Int {
        return -1
    }
    
}