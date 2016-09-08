class Code : Node {
    
    func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}
