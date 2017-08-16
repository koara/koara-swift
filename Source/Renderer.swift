public protocol Renderer {
    
    func visitDocument(node: Document)
    
    func visitHeading(node: Heading)
    
    func visitBlockQuote(node: BlockQuote)
    
    func visitListBlock(node: ListBlock)
    
    func visitListItem(node: ListItem)
    
    func visitCodeBlock(node: CodeBlock)
    
    func visitParagraph(node: Paragraph)
    
    func visitBlockElement(node: BlockElement)
    
    func visitImage(node: Image)
    
    func visitLink(node: Link)
    
    func visitText(node: Text)
    
    func visitStrong(node: Strong)
    
    func visitEm(node: Em)
    
    func visitCode(node: Code)
    
    func visitLineBreak(node: LineBreak)
    
}
