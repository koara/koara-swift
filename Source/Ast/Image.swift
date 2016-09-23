class Image : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visit(self)
    }
    
}
