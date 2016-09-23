class Heading : BlockElement {
    
    override func accept(_ renderer : Renderer) {
        renderer.visit(self)
    }
    
    //var level : Int {
    //    get {
    //        return getValue().text.toInt()
    //    }
    //}

}
