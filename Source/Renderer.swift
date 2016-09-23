protocol Renderer {
    
    func visit(_ node: Document)
    
    func visit(_ node: Heading)
    
    func visit(_ node: BlockQuote)
    
    func visit(_ node: ListBlock)
    
    func visit(_ node: ListItem)
    
    func visit(_ node: CodeBlock)
    
    func visit(_ node: Paragraph)
    
    func visit(_ node: BlockElement)
    
    func visit(_ node: Image)
    
    func visit(_ node: Link)
    
    func visit(_ node: Text)
    
    func visit(_ node: Strong)
    
    func visit(_ node: Em)
    
    func visit(_ node: Code)
    
    func visit(_ node: LineBreak)
    
}
