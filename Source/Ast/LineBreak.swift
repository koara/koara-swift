class LineBreak : Node {
    
    //var explicit : Bool
    
    func accept(renderer : Renderer) {
        renderer.visitLineBreak(node: self)
    }
    
}
