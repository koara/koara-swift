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
        var a = nodeArity()
        currentMark = marks.removeLast()
        a -= 1
        while(a > 0) {
            let c = popNode()
            c.parent = n;
            n.add(n: c, i: a);
            a -= 1
        }
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
