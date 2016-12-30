public class Document : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visitDocument(node: self)
    }
    
}
