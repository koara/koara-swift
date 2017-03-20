public class Strong : Node {
    
    public override func accept(renderer : Renderer) {
        renderer.visitStrong(node: self)
    }
    
}
