class BlockQuote : BlockElement {
    
    override func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}
