public class Code : Node {
    
    public override func accept(renderer : Renderer) {
        renderer.visitCode(node: self)
    }
    
}
