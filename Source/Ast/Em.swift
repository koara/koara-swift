class Em : Node {
    
    func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}
