class Paragraph : BlockElement {
    
    override func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}
