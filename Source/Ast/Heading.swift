class Heading : BlockElement {
    
    override func accept(_ renderer : Renderer) {
        renderer.visitHeading(node: self)
    }
    
    //var level : Int {
    //    get {
    //        return getValue().text.toInt()
    //    }
    //}

}
