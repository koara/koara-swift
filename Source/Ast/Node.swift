public class Node {
    
    var parent : Node?
    var children: [Node] = []
    public var value : AnyObject = "" as AnyObject
    
    func add(n: Node, i: Int) {
        children.insert(n, at: i)
    }

    public func childrenAccept(renderer: Renderer) {
    //    if children != nil {
    //    for (int i = 0; i < children.length; ++i) {
    //    children[i].accept(renderer);
    //    }
    //    }
    }
    
}
