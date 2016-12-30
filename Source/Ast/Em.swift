public class Em : Node {
    
    func accept(renderer : Renderer) {
        renderer.visitEm(node: self)
    }
    
}
