class LineBreak : Node {
    
    //var explicit : Bool
    
    func accept(_ renderer : Renderer) {
        renderer.visit(self)
    }
    
}
