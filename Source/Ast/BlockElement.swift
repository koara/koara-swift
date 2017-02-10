public class BlockElement : Node {
    
    func hasChildren() -> Bool {
        return children.count > 0
    }

    func isFirstChild() -> Bool {
        return parent?.children.first === self
    }

    func isLastChild() -> Bool {
        return parent?.children.last === self
    }

    public func isNested() -> Bool {
        return parent is Document
    }
 
    func isSingleChild() -> Bool {
        return parent?.children.count == 1
    }

    func next() -> AnyObject? {
        for (i, child) in (parent?.children.enumerated())! {
            if(child === self) {
                return parent?.children[i + 1]
            }
        }
        return nil;
    }

    override public func accept(renderer: Renderer) {
        preconditionFailure("This method must be overriden")
    }
    
}
