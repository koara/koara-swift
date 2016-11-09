class ListItem : BlockElement {
    
    var number : Int {
        get { return self.number }
        set { self.number = newValue }
    }
    
    override func accept(_ renderer : Renderer) {
        renderer.visitListItem(node: self)
    }
    
    func getParent() -> ListBlock {
        return self.getParent()
    }

}
