public class Document : Node {
    
    public func accept(_ renderer : Renderer) {
        renderer.visitDocument(node: self)
    }
    
}
