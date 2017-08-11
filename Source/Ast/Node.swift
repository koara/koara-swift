public class Node {
    
    public var parent : Node?
    public var children: [Node] = []
    public var value : AnyObject = "" as AnyObject
    
    func add(n: Node, i: Int) {
        children.insert(n, at: i)
    }

    public func childrenAccept(renderer: Renderer) {
        for c in children {
            c.accept(renderer: renderer)
        }
    }
    
    public func accept(renderer: Renderer) {
    }
    
}
