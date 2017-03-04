class TreeState {

    var nodes = [Node]()
    var marks = [Int]()
    var nodesOnStack : Int = 0;
    var currentMark : Int = 0;

    func openScope() {
        marks.append(currentMark)
        currentMark = nodesOnStack
    }
    
    func closeScope(_ n : Node) {
        let a = nodeArity()
        currentMark = marks.removeLast()
        var children = Array<Node>()
        for _ in 0..<a {
            let c = popNode()
            c.parent = n
            children.append(c)
        }
        n.children = children.reversed()
        pushNode(n);
    }
    
    func addSingleValue(_ n : Node, t : Token) {
        openScope()
        n.value = t.image as AnyObject
        closeScope(n)
    }
    
    func nodeArity() -> Int {
        return (nodesOnStack - currentMark)
    }
    
    func popNode() -> Node {
        nodesOnStack -= 1
        return nodes.removeLast()
    }
    
    func pushNode(_ n : Node) {
        nodes.append(n)
        nodesOnStack += 1
    }
    
}
