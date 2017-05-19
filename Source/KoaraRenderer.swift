public class KoaraRenderer : Renderer {
    
    
    var out: String
    //var Stack<String> left;
    var hardWrap : Bool = false
    
    public func visitDocument(node: Document) {
        out = ""
    	//left = Stack<String>();
    	node.childrenAccept(renderer: self);
    }
    
    func visitHeading(node: Heading) {
    }
    
    func visitBlockQuote(node: BlockQuote) {
    }
    
    func visitListBlock(node: ListBlock) {
        
    }
    
    func visitListItem(node: ListItem) {
        
    }
    
    func visitCodeBlock(node: CodeBlock) {
        
    }
    
    func visitParagraph(node: Paragraph) {
    }
    
    func visitBlockElement(node: BlockElement) {
    }
    
    func visitImage(node: Image) {
    }
    
    func visitLink(node: Link) {
        
    }
    
    func visitStrong(node: Strong) {
    
    }
    
    func visitEm(node: Em) {

    }
    
    func visitCode(node: Code) {
    }
    
    func visitText(node: Text) {

    }
    
    func escape(text: String) -> String {

    }
    
    func visitLineBreak(node: LineBreak) {

    }
    
  
}
