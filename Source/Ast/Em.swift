public class Em : Node {
    
    public override func accept(renderer : Renderer) {
        renderer.visitEm(node: self)
    }
    
}
