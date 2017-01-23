public class Em : Node {
    
    override public func accept(renderer : Renderer) {
        renderer.visitEm(node: self)
    }
    
}
