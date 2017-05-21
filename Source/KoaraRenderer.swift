public class KoaraRenderer : Renderer {
    
    
    var out: String
    //var Stack<String> left;
    var hardWrap : Bool = false
    
    public func visitDocument(node: Document) {
        out = ""
    	//left = Stack<String>();
    	node.childrenAccept(renderer: self);
    }
    
    public func visitHeading(node: Heading) {
//        if(!node.isFirstChild()) {
//            indent();
//        }
//        for(int i=0; i<node.getLevel(); i++) {
//            out.append("=");
//        }
//        if(node.hasChildren()) {
//            out.append(" ");
//            node.childrenAccept(this);
//        }
//        out.append("\n");
//        if(!node.isLastChild()) {
//            indent();
//            out.append("\n");
//        }
    }
    
    public func visitBlockQuote(node: BlockQuote) {
//        if(!node.isFirstChild()) {
//            indent();
//        }
//        
//        if(node.hasChildren()) {
//            out.append("> ");
//            left.push("> ");
//            node.childrenAccept(this);
//            left.pop();
//        } else {
//            out.append(">\n");
//        }
//        if(!node.isNested()) {
//            out.append("\n");
//        }
    }
    
    public func visitListBlock(node: ListBlock) {
//        node.childrenAccept(this);
//        if(!node.isLastChild()) {
//            indent();
//            out.append("\n");
//            Object next = node.next();
//            if(next instanceof ListBlock && ((ListBlock) next).isOrdered() == node.isOrdered() ) {
//                out.append("\n");
//            }
//        }
        
    }
    
    public func visitListItem(node: ListItem) {
//        if(!node.getParent().isNested() || !node.isFirstChild() || !node.getParent().isFirstChild()) {
//            indent();
//        }
//        left.push("  ");
//        if(node.getNumber() != null) {
//            out.append(node.getNumber() + ".");
//        } else {
//            out.append("-");
//        }
//        if(node.hasChildren()) {
//            out.append(" ");
//            node.childrenAccept(this);
//        } else {
//            out.append("\n");
//        }
//        left.pop();
        
    }
    
    public func visitCodeBlock(node: CodeBlock) {
//        StringBuilder indent = new StringBuilder();
//        for(String s : left) {
//            indent.append(s);
//        }
//        
//        out.append("```");
//        if(node.getLanguage() != null) {
//            out.append(node.getLanguage());
//        }
//        out.append("\n");
//        
//        
//        
//        out.append(node.getValue().toString().replaceAll("(?m)^", indent.toString()));
//        out.append("\n");
//        indent();
//        out.append("```");
//        out.append("\n");
//        
//        if(!node.isLastChild()) {
//            indent();
//            out.append("\n");
//        }
        
    }
    
    public func visitParagraph(node: Paragraph) {
//        if(!node.isFirstChild()) {
//            indent();
//        }
//        node.childrenAccept(this);
//        out.append("\n");
//        if(!node.isNested() || (node.getParent() instanceof ListItem && (node.next() instanceof Paragraph) && !node.isLastChild())) {
//            out.append("\n");
//        } else if(node.getParent() instanceof BlockQuote && (node.next() instanceof Paragraph)) {
//            indent();
//            out.append("\n");
//        }
    }
    
    public func visitBlockElement(node: BlockElement) {
//        if(!node.isFirstChild()) {
//            indent();
//        }
//        node.childrenAccept(this);
//        out.append("\n");
//        if(!node.isNested() || (node.getParent() instanceof ListItem && (node.next() instanceof Paragraph) && !node.isLastChild())) {
//            out.append("\n");
//        } else if(node.getParent() instanceof BlockQuote && (node.next() instanceof Paragraph)) {
//            indent();
//            out.append("\n");
//        }
    }
    
    public func visitImage(node: Image) {
//        out.append("[image: ");
//        node.childrenAccept(this);
//        out.append("]");
//        if(node.getValue() != null && node.getValue().toString().trim().length() > 0) {
//            out.append("(");
//            out.append(escapeUrl(node.getValue().toString()));
//            out.append(")");
//        }
    }
    
    public func visitLink(node: Link) {
//        out.append("[");
//        node.childrenAccept(this);
//        out.append("]");
//        if(node.getValue() != null && node.getValue().toString().trim().length() > 0) {
//            out.append("(");
//            out.append(escapeUrl(node.getValue().toString()));
//            out.append(")");
//        }
        
    }
    
    public func visitStrong(node: Strong) {
//        out.append("*");
//        node.childrenAccept(this);
//        out.append("*");
    }
    
    public func visitEm(node: Em) {
//        out.append("_");
//        node.childrenAccept(this);
//        out.append("_");
    }
    
    public func visitCode(node: Code) {
//        out.append("`");
//        node.childrenAccept(this);
//        out.append("`");
    }
    
    public func visitText(node: Text) {
//        if(node.getParent() instanceof Code) {
//            out.append(node.getValue().toString());
//        } else {
//            out.append(escape(node.getValue().toString()));
//        }
    }
    

    public func visitLineBreak(node: LineBreak) {
//        if(hardWrap || node.isExplicit()) {
//            out.append("  ");
//        }
//        out.append("\n");
//        indent();
    }
    
    public func escape(text: String) -> String {
        //        return text.replaceAll("\\[", "\\\\[")
        //            .replaceAll("\\]", "\\\\]")
        //            .replaceAll("\\*", "\\\\*")
        //            .replaceAll("\\_", "\\\\_")
        //            .replaceFirst("\\`", "\\\\`")
        //            .replaceFirst("\\=", "\\\\=")
        //            .replaceFirst("\\>", "\\\\>")
        //            .replaceFirst("\\-", "\\\\-")
        //            .replaceFirst("(\\d+)\\.", "\\\\$1.");
    }
    
    
//    public String escapeUrl(String text) {
//    return text.replaceAll("\\(", "\\\\(")
//				.replaceAll("\\)", "\\\\)");
//    }
  
}
