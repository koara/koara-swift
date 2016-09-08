class ListItem : BlockElement {
    
    var number : Int {
        get {
            return self.number
        }
        set {
            self.number = newValue
        }
    }
    
    override func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
    func getParent() -> ListBlock {
        return self.getParent()
    }

}
