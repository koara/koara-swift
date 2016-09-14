class TreeState {

    var nodes = [Node]()
    var marks = [Int]()
    var nodesOnStack : Int = 0;
    var currentMark : Int = 0;

    
    func openScope() {
        marks.append(currentMark)
        currentMark = nodesOnStack
    }
    
    func closeScope(n : Node) {
//        var a = nodeArity()
        currentMark = marks.removeLast()
//        while (a-=1) > 0 {
//        var c = popNode()
//    c.setParent(n);
//    n.add(c, a);
//        }
//    pushNode(n);
    }
//    
    func addSingleValue(n : Node, t : Token) {
        openScope();
//    n.setValue(t.image);
        closeScope(n);
    }
    
    func nodeArity() -> Int {
        return (nodesOnStack - currentMark)
    }
    
    func popNode() -> Node {
        nodesOnStack -= 1
        return nodes.removeLast()
    }
    
    func pushNode(n : Node) {
        nodes.append(n)
        nodesOnStack += 1
    }
    
}