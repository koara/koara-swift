public class LineBreak : Node {
    
    //var explicit : Bool
    
    override public func accept(renderer : Renderer) {
        renderer.visitLineBreak(node: self)
    }
    
}
