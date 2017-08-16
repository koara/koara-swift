public class BlockElement : Node {
    
    override public func accept(renderer : Renderer) {
        renderer.visitBlockElement(node: self)
    }
    
    func hasChildren() -> Bool {
        return children.count > 0
    }

    func isFirstChild() -> Bool {
        return parent?.children.first! === self
    }

    func isLastChild() -> Bool {
        return parent?.children.last! === self
    }

    public func isNested() -> Bool {
        return !(parent is Document)
    }
 
    public func isSingleChild() -> Bool {
        return parent?.children.count == 1
    }

    func next() -> AnyObject? {
        for i in 0 ..< (parent?.children.count)! - 1 {
            if(parent?.children[i] === self) {
                return parent?.children[i + 1]
            }
        }
        return nil;
    }
    
}
