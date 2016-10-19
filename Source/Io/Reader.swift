protocol Reader {
    
    func read(_ buffer: inout [Int:Character], offset: Int, length: Int) -> Int
    
}
