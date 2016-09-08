class Document : Node {
    
    func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}
