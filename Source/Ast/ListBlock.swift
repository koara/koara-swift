public class ListBlock : BlockElement {
    
    public var ordered : Bool!
    
    init(ordered: Bool) {
        super.init()
        self.ordered = ordered
    }
        
    override public func accept(renderer : Renderer) {
        renderer.visitListBlock(node: self)
    }
    
}
