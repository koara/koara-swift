class Strong : Node {
    
    func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}
