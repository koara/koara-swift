protocol Renderer {
    
    func visit(node: Document)
    
    func visit(node: Heading)
    
    func visit(node: BlockQuote)
    
    func visit(node: ListBlock)
    
    func visit(node: ListItem)
    
    func visit(node: CodeBlock)
    
    func visit(node: Paragraph)
    
    func visit(node: BlockElement)
    
    func visit(node: Image)
    
    func visit(node: Link)
    
    func visit(node: Text)
    
    func visit(node: Strong)
    
    func visit(node: Em)
    
    func visit(node: Code)
    
    func visit(node: LineBreak)
    
}