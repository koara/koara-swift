public class ListItem : BlockElement {
    
    public var number : Int = 0
    
    override public func accept(renderer : Renderer) {
        renderer.visitListItem(node: self)
    }
    
    func getParent() -> ListBlock {
        return super.parent as! ListBlock
    }

}
