class Heading : BlockElement {
    
    func accept(renderer : Renderer) {
        renderer.visit(self)
    }
    
    var level : Int {
        get {
            return getValue().text.toInt()
        }
    }

}
