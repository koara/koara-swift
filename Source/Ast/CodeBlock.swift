class CodeBlock : BlockElement {
    
    var language : String!
    
    override func accept(_ renderer : Renderer) {
        renderer.visit(self)
    }
    
}
