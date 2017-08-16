public protocol Reader {
    
    func read(_ buffer: inout [Character], offset: Int, length: Int) -> Int
    
}
