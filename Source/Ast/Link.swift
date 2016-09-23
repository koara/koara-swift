class Link : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visit(self)
    }
    
}
