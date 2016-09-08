class Image : Node {
    
    func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}