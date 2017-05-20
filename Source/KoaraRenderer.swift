public class KoaraRenderer : Renderer {
    
    
    var out: String
    //var Stack<String> left;
    var hardWrap : Bool = false
    
    public func visitDocument(node: Document) {
        out = ""
    	//left = Stack<String>();
    	node.childrenAccept(renderer: self);
    }
    
    public func visitHeading(node: Heading) {
    }
    
    public func visitBlockQuote(node: BlockQuote) {
    }
    
    public func visitListBlock(node: ListBlock) {
        
    }
    
    public func visitListItem(node: ListItem) {
        
    }
    
    public func visitCodeBlock(node: CodeBlock) {
        
    }
    
    public func visitParagraph(node: Paragraph) {
    }
    
    public func visitBlockElement(node: BlockElement) {
    }
    
    public func visitImage(node: Image) {
    }
    
    public func visitLink(node: Link) {
        
    }
    
    public func visitStrong(node: Strong) {
    
    }
    
    public func visitEm(node: Em) {

    }
    
    public func visitCode(node: Code) {
    }
    
    public func visitText(node: Text) {

    }
    
    public func escape(text: String) -> String {

    }
    
    public func visitLineBreak(node: LineBreak) {

    }
    
  
}
