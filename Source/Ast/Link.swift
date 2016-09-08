class Link : Node {
    
    func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}
