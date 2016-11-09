class Text : Node {
    
    func accept(_ renderer : Renderer) {
        renderer.visitText(node: self)
    }
    
}
