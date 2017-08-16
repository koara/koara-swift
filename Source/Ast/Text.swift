public class Text : Node {
    
    override public func accept(renderer : Renderer) {
        renderer.visitText(node: self)
    }
    
}
