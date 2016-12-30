public class CodeBlock : BlockElement {
    
    public var language : String!
    
    override func accept(_ renderer : Renderer) {
        renderer.visitCodeBlock(node: self)
    }
    
}
