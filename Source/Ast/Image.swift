class Image : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visitImage(node: self)
    }
    
}
