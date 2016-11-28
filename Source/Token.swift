class Token {
 
    var kind: Int32?
    var beginLine: Int?
    var beginColumn: Int?
    var endLine: Int?
    var endColumn: Int?
    var image: String?
    var next : Token?
    
    init() {
    }
    
    init(kind: Int32, beginLine: Int, beginColumn: Int, endLine: Int, endColumn: Int, image: String) {
        self.kind = kind
        self.beginLine = beginLine
        self.beginColumn = beginColumn
        self.endLine = endLine
        self.endColumn = endColumn
        self.image = image
    }

}
