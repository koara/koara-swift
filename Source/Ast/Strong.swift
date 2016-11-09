class Strong : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visitStrong(node: self)
    }
    
}
