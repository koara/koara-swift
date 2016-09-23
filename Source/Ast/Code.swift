class Code : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visit(self)
    }
    
}
