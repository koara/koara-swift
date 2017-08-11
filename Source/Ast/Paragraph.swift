public class Paragraph : BlockElement {
    
    override public func accept(renderer: Renderer) {
        renderer.visitParagraph(node: self)
    }
    
}
