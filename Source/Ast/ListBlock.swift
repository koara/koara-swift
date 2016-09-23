class ListBlock : BlockElement {
    
    var ordered : Bool!
    
    init(ordered: Bool) {
        super.init()
        self.ordered = ordered
    }
        
    override func accept(_ renderer : Renderer) {
        renderer.visit(self)
    }
    
}
