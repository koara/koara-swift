class Document : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visit(self)
    }
    
}
