public class Link : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visitLink(node: self)
    }
    
}
