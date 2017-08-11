public class CodeBlock : BlockElement {
    
    public var language : String!
    
    public override func accept(renderer : Renderer) {
        renderer.visitCodeBlock(node: self)
    }
    
}
