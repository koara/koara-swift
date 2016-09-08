class BlockElement : Node {
    
//    public boolean hasChildren() {
//        return getChildren() != null && getChildren().length > 0;
//    }
//    
//    public boolean isFirstChild() {
//        return getParent().getChildren()[0] == this;
//    }
//    
//    public boolean isLastChild() {
//        Node[] children = getParent().getChildren();
//        return children[children.length - 1] == this;
//    }
//    
//    public boolean isNested() {
//        return !(getParent() instanceof Document);
//    }
//    
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
    func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
}
