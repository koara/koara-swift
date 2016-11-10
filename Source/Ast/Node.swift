class Node {
    
    var children : [Node] { get { return self.children } }
    //var parent : Node { get set }
    var value : AnyObject {
        set (newVal) { self.value = newVal }
        get { return self.value }
    }
    
    func add(n: Node, i: Int) {
    //if (children == null) {
    //    children = new Node[i + 1];
    //    }
    //    children[i] = n;
    }

    func childrenAccept(renderer: Renderer) {
    //    if children != nil {
    //    for (int i = 0; i < children.length; ++i) {
    //    children[i].accept(renderer);
    //    }
    //    }
    }
    
}
