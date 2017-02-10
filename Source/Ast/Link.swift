public class Link : Node {
    
    override public func accept(renderer : Renderer) {
        renderer.visitLink(node: self)
    }
    
}
