public class Heading : BlockElement {
    
    override public func accept(renderer : Renderer) {
        renderer.visitHeading(node: self)
    }
    
    //var level : Int {
    //    get {
    //        return getValue().text.toInt()
    //    }
    //}

}
