public class BlockElement : Node {
    
    func hasChildren() -> Bool {
//        return getChildren() != null && getChildren().length > 0;
        return false
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
 
//    public boolean isSingleChild() {
//        return ((Node) this.getParent()).getChildren().length == 1;
//    }
//    
//    public Object next() {
//        for(int i = 0; i < getParent().getChildren().length - 1; i++) {
//            if(getParent().getChildren()[i] == this) {
//                return getParent().getChildren()[i + 1];
//            }
//        }
//        return null;
//    }
//    
    override public func accept(renderer: Renderer) {
        preconditionFailure("This method must be overriden")
    }
    
}
