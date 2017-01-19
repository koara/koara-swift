public class LineBreak : Node {
    
    //var explicit : Bool
    
    override func accept(renderer : Renderer) {
        renderer.visitLineBreak(node: self)
    }
    
}
