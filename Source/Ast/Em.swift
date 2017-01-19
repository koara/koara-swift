public class Em : Node {
    
    override func accept(renderer : Renderer) {
        renderer.visitEm(node: self)
    }
    
}
