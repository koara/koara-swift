import Koara
import Foundation

class Html5Renderer : Renderer {
    
    var output : String = ""
    var level : Int = 0
    var listSequence = Array<Int>();

    public var hardWrap : Bool = false
    
    func visitDocument(node: Document) {
        output = ""
        node.childrenAccept(renderer: self);
    }
    
    func visitHeading(node: Heading) {
        output += indent() + "<h" + String(describing: node.value) + ">"
        node.childrenAccept(renderer: self);
        output += "</h" + String(describing: node.value) + ">\n"
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
        listSequence.append(0)
        let tag = node.ordered! ? "ol" : "ul"
        output += indent() + "<" + tag + ">\n"
        level += 1
        node.childrenAccept(renderer: self);
        level -= 1
        output += indent() + "</" + tag + ">\n"
        if(!node.isNested()) {
            output += "\n"
        }
        _ = listSequence.popLast()
    }
   
    func visitListItem(node: ListItem) {
        let seq = listSequence.last! + 1
        listSequence[listSequence.count - 1] = seq
        
        output += indent() + "<li"
        if(node.number > 0 && seq != node.number) {
            output += " value=\"\(node.number)\""
            listSequence.append(node.number)
        }
        output += ">"
        
        if(node.children.count > 0) {
            let block = (String(describing: node.children.first!) == "Koara.Paragraph"
                || String(describing: node.children.first!) == "Koara.BlockElement");
            
            if(node.children.count > 1 || !block) { output += "\n"; }
            level += 1
            node.childrenAccept(renderer: self);
            level -= 1
            if(node.children.count > 1 || !block) { output += indent(); }
        }
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
        if(node.isNested() && (node.parent is ListItem) && node.isSingleChild()) {
            node.childrenAccept(renderer: self);
        } else {
            output += indent() + "<p>"
            node.childrenAccept(renderer: self)
            output += "</p>\n"
            if(!node.isNested()) {
                output += "\n"
            }
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
        output += "<img src=\"" + escapeUrl(text: node.value as! String) + "\" alt=\"";
        node.childrenAccept(renderer: self);
        output += "\" />";
    }
    
    func visitLink(node: Link) {
        output += "<a href=\"\(escapeUrl(text: node.value as! String))\">";
        node.childrenAccept(renderer: self);
        output += "</a>";
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
        return text
            .replacingOccurrences(of: " ", with: "%20")
            .replacingOccurrences(of: "\"", with: "%22")
            .replacingOccurrences(of: "`", with: "%60")
            .replacingOccurrences(of: "<", with: "%3C")
            .replacingOccurrences(of: ">", with: "%3E")
            .replacingOccurrences(of: "[", with: "%5B")
            .replacingOccurrences(of: "]", with: "%5D")
            .replacingOccurrences(of: "\\", with: "%5C");
    }
    
    func indent() -> String {
        var indent = ""
        for _ in 0..<(level * 2) {
            indent += " "
        }
        return indent;
    }
    
    func getOutput() -> String {
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
 
