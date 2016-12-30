public class BlockQuote : BlockElement {
    
    override func accept(_ renderer : Renderer) {
        renderer.visitBlockQuote(node: self)
    }
    
}
