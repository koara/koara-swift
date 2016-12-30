public class Paragraph : BlockElement {
    
    override func accept(_ renderer : Renderer) {
        renderer.visitParagraph(node: self)
    }
    
}
