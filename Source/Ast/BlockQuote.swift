public class BlockQuote : BlockElement {
    
    override public func accept(renderer : Renderer) {
        renderer.visitBlockQuote(node: self)
    }
    
}
