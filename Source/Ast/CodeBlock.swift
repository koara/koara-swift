class CodeBlock : BlockElement {
    
    var language : String!
    
    override func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}
