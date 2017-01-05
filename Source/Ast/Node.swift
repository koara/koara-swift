public class Node {
    
    public var parent : Node?
    var children: [Node] = []
    public var value : AnyObject = "" as AnyObject
    
    func add(n: Node, i: Int) {
        print("I \(i)")
       // children.insert(n, at: i)
    }

    public func childrenAccept(renderer: Renderer) {
      //  for c in children {
      //      c.accept(renderer);
      //  }
    }
    
    //public abstract void accept(Renderer renderer)
    
}
