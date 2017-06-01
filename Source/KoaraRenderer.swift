public class KoaraRenderer : Renderer {
    
    var out: String = ""
    var left = Array<String>();
    var hardWrap : Bool = false
    
    public func visitDocument(node: Document) {
        out = ""
    	left = Array<String>();
    	node.childrenAccept(renderer: self);
    }
    
    public func visitHeading(node: Heading) {
        if !node.isFirstChild() {
            indent();
        }
        for _ in 0..<node.level {
            out += "="
        }
        if(node.hasChildren()) {
            out += " "
            node.childrenAccept(renderer: self);
        }
        out += "\n";
        if(!node.isLastChild()) {
            indent()
            out += "\n"
        }
    }
    
    public func visitBlockQuote(node: BlockQuote) {
        if !node.isFirstChild() {
            indent()
        }
  
        if node.hasChildren() {
            out += "> ";
            left.append("> ")
            node.childrenAccept(renderer: self);
            _ = left.popLast()
        } else {
            out += ">\n";
        }
        if(!node.isNested()) {
            out += "\n";
        }
    }
    
    public func visitListBlock(node: ListBlock) {
        node.childrenAccept(renderer: self);
        if(!node.isLastChild()) {
            indent()
            out += "\n";
            //next = node.next()
            //if(next is ListBlock && ((ListBlock) next).isOrdered() == node.isOrdered() ) {
                out += "\n";
            //}
        }
        
    }
    
    public func visitListItem(node: ListItem) {
        if(!node.getParent().isNested() || !node.isFirstChild() || !node.getParent().isFirstChild()) {
            indent();
        }
        left.append("  ")
        if(node.number > 0) {
            out += String(node.number) + ".";
        } else {
            out += "-";
        }
        if(node.hasChildren()) {
            out += " ";
            node.childrenAccept(renderer: self);
        } else {
            out += "\n";
        }
        _ = left.popLast()
        
    }
    
    public func visitCodeBlock(node: CodeBlock) {
        var indent = "";
        for s in left {
            indent += s
        }
  
        out += "```";
        if(node.language != nil) {
            out += node.language
        }
        out += "\n";

        //out += node.value.replaceAll("(?m)^", indent.toString());
        out += "\n";
        indent();
        out += "```";
        out += "\n";

        if(!node.isLastChild()) {
            indent();
            out += "\n";
        }
        
    }
    
    public func visitParagraph(node: Paragraph) {
        if(!node.isFirstChild()) {
            indent();
        }
        node.childrenAccept(renderer: self);
        out += "\n";
//        if(!node.isNested() || (node.getParent() instanceof ListItem && (node.next() instanceof Paragraph) && !node.isLastChild())) {
//            out.append("\n");
//        } else if(node.getParent() instanceof BlockQuote && (node.next() instanceof Paragraph)) {
            indent()
            out += "\n";
//        }
    }
    
    public func visitBlockElement(node: BlockElement) {
        if(!node.isFirstChild()) {
            indent();
        }
        node.childrenAccept(renderer: self);
        out += "\n";
        if(!node.isNested() || (node.parent is ListItem && (node.next() is Paragraph) && !node.isLastChild())) {
            out.append("\n");
        } else if(node.parent is BlockQuote && (node.next() is Paragraph)) {
            indent();
            out += "\n";
        }
    }
    
    public func visitImage(node: Image) {
        out += "[image: ";
        node.childrenAccept(renderer: self);
        out += "]";
//        if(node.value && node.value.trim().length() > 0) {
            out += "(";
            out += escapeUrl(text: node.value as! String);
            out += ")";
//        }
    }
    
    public func visitLink(node: Link) {
        out += "[";
        node.childrenAccept(renderer: self);
        out += "]";
//        if(node.getValue() != null && node.getValue().toString().trim().length() > 0) {
            out += "(";
            out += escapeUrl(text: node.value as! String);
            out += ")";
//        }
        
    }
    
    public func visitStrong(node: Strong) {
        out += "*";
        node.childrenAccept(renderer: self);
        out += "*";
    }
    
    public func visitEm(node: Em) {
        out += "_";
        node.childrenAccept(renderer: self);
        out += "_";
    }
    
    public func visitCode(node: Code) {
        out += "`";
        node.childrenAccept(renderer: self);
        out += "`";
    }
    
    public func visitText(node: Text) {
        if(node.parent is Code) {
          out += node.value as! String;
        } else {
          out += escape(text: node.value as! String);
        }
    }
    

    public func visitLineBreak(node: LineBreak) {
        if(hardWrap || node.explicit!) {
            out += "  "
        }
        out += "\n"
        indent()
    }
    
    private func indent() {
        for s in left {
            out += s;
        }
    }
    
    private func escape(text: String) -> String {
        return text.replacingOccurrences(of: "\\[", with: "\\\\[")
            .replacingOccurrences(of: "\\]", with: "\\\\]")
            .replacingOccurrences(of: "\\*", with: "\\\\*")
            .replacingOccurrences(of: "\\_", with: "\\\\_")
            .replacingOccurrences(of: "\\`", with: "\\\\`") // first
            .replacingOccurrences(of: "\\=", with: "\\\\=") // first
            .replacingOccurrences(of: "\\>", with: "\\\\>") // first
            .replacingOccurrences(of: "\\-", with: "\\\\-") // first
            .replacingOccurrences(of: "(\\d+)", with: "\\\\$1.") // first
    }
    
    private func escapeUrl(text: String) -> String {
        return text.replacingOccurrences(of: "\\(", with: "\\\\(")
            .replacingOccurrences(of: "\\)", with: "\\\\)")
    }
  
}
