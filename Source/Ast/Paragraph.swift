class Paragraph : BlockElement {
    
    override func accept(_ renderer : Renderer) {
        renderer.visit(self)
    }
    
}
