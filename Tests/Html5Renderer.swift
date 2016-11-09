class Html5Renderer : Renderer {
    
    //var output : String {
    //    set (newVal) { self.output = newVal }
    //    get { return self.output }    }
    
    var level : Int = 0
    //private Stack<Integer> listSequence = new Stack<Integer>();
   
    var hardWrap : Bool {
        set (newVal) { self.hardWrap = newVal }
        get { return self.hardWrap }
    }
    
    func visitDocument(node: Document) {
      //  out = new StringBuffer();
    //  node.childrenAccept(this);
    }
    
    func visitHeading(node: Heading) {
        //out.append(indent() + "<h" + node.getValue() + ">");
        //node.childrenAccept(this);
        //out.append("</h" + node.getValue() + ">\n");
        //if(!node.isNested()) { out.append("\n"); }
    }
    
    func visitBlockQuote(node: BlockQuote) {
        //out.append(indent() + "<blockquote>");
        //if(node.getChildren() != null && node.getChildren().length > 0) { out.append("\n"); }
        //level++;
        //node.childrenAccept(this);
        //level--;
        //out.append(indent() + "</blockquote>\n");
        //if(!node.isNested()) { out.append("\n"); }
    }
  
    func visitListBlock(node: ListBlock) {
        //listSequence.push(0);
        //String tag = node.isOrdered() ? "ol" : "ul";
        //out.append(indent() + "<" + tag + ">\n");
        //level++;
        //node.childrenAccept(this);
        //level--;
        //out.append(indent() + "</" + tag + ">\n");
        //if(!node.isNested()) { out.append("\n"); }
        //listSequence.pop();
    }
   
    func visitListItem(node: ListItem) {
        //Integer seq = listSequence.peek() + 1;
        //listSequence.set(listSequence.size() - 1, seq);
        //out.append(indent() + "<li");
        //if(node.getNumber() != null && (!seq.equals(node.getNumber()))) {
        //    out.append(" value=\"" + node.getNumber() + "\"");
        //    listSequence.push(node.getNumber());
        //}
        //out.append(">");
        //if(node.getChildren() != null) {
        //    boolean block = (node.getChildren()[0].getClass() == Paragraph.class || node.getChildren()[0].getClass() == BlockElement.class);
        //
        //    if(node.getChildren().length > 1 || !block) { out.append("\n"); }
        //    level++;
        //    node.childrenAccept(this);
        //    level--;
        //    if(node.getChildren().length > 1 || !block) { out.append(indent()); }
        //}
        //out.append("</li>\n");
    }
    
    func visitCodeBlock(node: CodeBlock) {
        //out.append(indent() + "<pre><code");
        //if(node.getLanguage() != null) {
        //    out.append(" class=\"language-" + escape(node.getLanguage()) + "\"");
        //}
        //out.append(">");
        //out.append(escape(node.getValue().toString()) + "</code></pre>\n");
        //if(!node.isNested()) { out.append("\n"); }
    }
    
    func visitParagraph(node: Paragraph) {
        //if(node.isNested() && (node.getParent() instanceof ListItem) && node.isSingleChild()) {
        //    node.childrenAccept(this);
        //} else {
        //    out.append(indent() + "<p>");
        //    node.childrenAccept(this);
        //    out.append("</p>\n");
        //    if(!node.isNested()) { out.append("\n"); }
        //}
    }
  
    func visitBlockElement(node: BlockElement) {
        //if(node.isNested() && (node.getParent() instanceof ListItem) && node.isSingleChild()) {
        //    node.childrenAccept(this);
        //} else {
        //    out.append(indent());
        //    node.childrenAccept(this);
        //    if(!node.isNested()) { out.append("\n"); }
        //}
    }
    
    func visitImage(node: Image) {
        //out.append("<img src=\"" + escapeUrl(node.getValue().toString()) + "\" alt=\"");
        //node.childrenAccept(this);
        //out.append("\" />");
    }
    
    func visitLink(node: Link) {
        //out.append("<a href=\"" + escapeUrl(node.getValue().toString()) + "\">");
        //node.childrenAccept(this);
        //out.append("</a>");
    }
    
    func visitStrong(node: Strong) {
        //out.append("<strong>");
        //node.childrenAccept(this);
        //out.append("</strong>");
    }
    
    func visitEm(node: Em) {
        //out.append("<em>");
        //node.childrenAccept(this);
        //out.append("</em>");
    }
    
    func visitCode(node: Code) {
        //out.append("<code>");
        //node.childrenAccept(this);
        //out.append("</code>");
    }
    
    func visitText(node: Text) {
        //out.append(escape(node.getValue().toString()));
    }
    
    func escape(text: String) -> String {
        return ""
        //return text.replaceAll("&", "&amp;")
        //    .replaceAll("<", "&lt;")
        //    .replaceAll(">", "&gt;")
        //    .replaceAll("\"", "&quot;");
    }
    
    func visitLineBreak(node: LineBreak) {
        //if(hardWrap || node.isExplicit()) {
        //    out.append("<br>");
        //}
        //out.append("\n" + indent());
        //node.childrenAccept(this);
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
    
}
 
