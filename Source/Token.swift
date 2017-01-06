public class Token {
 
    public var kind: Int32?
    var beginLine: Int = 0
    var beginColumn: Int = 0
    var endLine: Int = 0
    var endColumn: Int = 0
    public var image: String?
    var next : Token?
    
    init() {
    }
    
    init(_ kind: Int32, _ beginLine: Int, _ beginColumn: Int, _ endLine: Int, _ endColumn: Int, _ image: String) {
        self.kind = kind
        self.beginLine = beginLine
        self.beginColumn = beginColumn
        self.endLine = endLine
        self.endColumn = endColumn
        self.image = image
    }

}
