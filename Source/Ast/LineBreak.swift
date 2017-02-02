public class LineBreak : Node {
    
    public var explicit : Bool?
    
    override public func accept(renderer : Renderer) {
        renderer.visitLineBreak(node: self)
    }
    
}
