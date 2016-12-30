public class Code : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visitCode(node: self)
    }
    
}
