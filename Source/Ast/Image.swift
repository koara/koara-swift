public class Image : Node {
    
    public override func accept(renderer : Renderer) {
        renderer.visitImage(node: self)
    }
    
}
