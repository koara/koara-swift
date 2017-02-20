import Koara

class Html5Renderer : Renderer {
    
    var output : String = ""
    var level : Int = 0
    //private Stack<Integer> listSequence = new Stack<Integer>();
    public var hardWrap : Bool = false
    
    func visitDocument(node: Document) {
        output = ""
        node.childrenAccept(renderer: self);
    }
    
    func visitHeading(node: Heading) {
        output += indent() + "<h1" + (node.value as! String) + ">"
        node.childrenAccept(renderer: self);
        output += "</h1" + (node.value as! String) + ">\n"
        if !node.isNested() {
            output += "\n"
        }
    }
    
    func visitBlockQuote(node: BlockQuote) {
        output += indent() + "<blockquote>"
        //if(node.getChildren() != null && node.getChildren().length > 0) { out.append("\n"); }
        level += 1
        //node.childrenAccept(this);
        level -= 1
        output += indent() + "</blockquote>\n"
        if(node.isNested()) {
            output += "\n"
        }
    }
  
    func visitListBlock(node: ListBlock) {
        //listSequence.push(0);
        let tag = node.ordered! ? "ol" : "ul"
        output += indent() + "<" + tag + ">\n"
        level += 1
        node.childrenAccept(renderer: self);
        level -= 1
        output += indent() + "</" + tag + ">\n"
        if(!node.isNested()) {
            output += "\n"
        }
        //listSequence.pop();
    }
   
    func visitListItem(node: ListItem) {
        //Integer seq = listSequence.peek() + 1;
        //listSequence.set(listSequence.size() - 1, seq);
        output += indent() + "<li"
        //if(node.getNumber() != null && (!seq.equals(node.getNumber()))) {
        //    out.append(" value=\"" + node.getNumber() + "\"");
        //    listSequence.push(node.getNumber());
        //}
        output += ">"
        //if(node.getChildren() != null) {
        //    boolean block = (node.getChildren()[0].getClass() == Paragraph.class || node.getChildren()[0].getClass() == BlockElement.class);
        //
        //    if(node.getChildren().length > 1 || !block) { out.append("\n"); }
                level += 1
                node.childrenAccept(renderer: self);
                level -= 1
        //    if(node.getChildren().length > 1 || !block) { out.append(indent()); }
        //}
        output += "</li>\n"
    }
    
    func visitCodeBlock(node: CodeBlock) {
        output += indent() + "<pre><code"
        if ((node.language) != nil) {
            output += " class=\"language-\"" + escape(text: node.language)
        }
        output += ">"
        output += escape(text: node.value as! String) + "</code></pre>\n"
        if(!node.isNested()) {
            output += "\n"
        }
    }
    
    func visitParagraph(node: Paragraph) {
        //if(node.isNested() && (node.getParent() instanceof ListItem) && node.isSingleChild()) {
        //    node.childrenAccept(this);
        //} else {
            output += indent() + "<p>"
            node.childrenAccept(renderer: self)
            output += "</p>\n"
        if(!node.isNested()) {
            output += "\n"
        }
    }
  
    func visitBlockElement(node: BlockElement) {
        //if(node.isNested() && (node.getParent() instanceof ListItem) && node.isSingleChild()) {
        //    node.childrenAccept(this);
        //} else {
            output += indent()
            node.childrenAccept(renderer: self)
        if(node.isNested()) {
            output += "\n"
        }
        //}
    }
    
    func visitImage(node: Image) {
        //out.append("<img src=\"" + escapeUrl(node.getValue().toString()) + "\" alt=\"");
        node.childrenAccept(renderer: self);
        //out.append("\" />");
    }
    
    func visitLink(node: Link) {
        //out.append("<a href=\"" + escapeUrl(node.getValue().toString()) + "\">");
        node.childrenAccept(renderer: self);
        //out.append("</a>");
    }
    
    func visitStrong(node: Strong) {
        //out.append("<strong>");
        node.childrenAccept(renderer: self);
        //out.append("</strong>");
    }
    
    func visitEm(node: Em) {
        //out.append("<em>");
        node.childrenAccept(renderer: self);
        //out.append("</em>");
    }
    
    func visitCode(node: Code) {
        //out.append("<code>");
        node.childrenAccept(renderer: self);
        //out.append("</code>");
    }
    
    func visitText(node: Text) {
        output += escape(text: node.value as! String)
    }
    
    func escape(text: String) -> String {
        return text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
    
    func visitLineBreak(node: LineBreak) {
        if(hardWrap || node.explicit!) {
            output += "<br>"
        }
        output += "\n" + indent()
        node.childrenAccept(renderer: self)
    }
    
    func escapeUrl(text: String) -> String {
        return ""
        //return text.replaceAll(" ", "%20")
        //    .replaceAll("\"", "%22")
        //    .replaceAll("`", "%60")
        //    .replaceAll("<", "%3C")
        //    .replaceAll(">", "%3E")
        //    .replaceAll("\\[", "%5B")
        //    .replaceAll("\\]", "%5D")
        //    .replaceAll("\\\\", "%5C");
    }
    
    func indent() -> String {
        //int repeat = level * 2;
        //final char[] buf = new char[repeat];
        //for (int i = repeat - 1; i >= 0; i--) {
        //    buf[i] = ' ';
        //}
        //return new String(buf);
        return ""
    }
    
    func getOutput() -> String {
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
 
