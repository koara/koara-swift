import XCTest
import Koara

class TokenManagerTest: XCTestCase {

    func testEof() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: ""))).getNextToken()
        XCTAssertEqual(TokenManager.EOF, token?.kind)
    }
 
    func testAsterisk() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "*"))).getNextToken()
        XCTAssertEqual(TokenManager.ASTERISK, token?.kind)
        XCTAssertEqual("*", token?.image)
    }
    
    func testBackslash() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "\\"))).getNextToken()
        XCTAssertEqual(TokenManager.BACKSLASH, token?.kind)
        XCTAssertEqual("\\", token?.image)
    }
    
    func testBacktick() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "`"))).getNextToken()
        XCTAssertEqual(TokenManager.BACKTICK, token?.kind)
        XCTAssertEqual("`", token?.image)
    }
    
    func testCharSequenceLowerCase() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "m"))).getNextToken()
        XCTAssertEqual(TokenManager.CHAR_SEQUENCE, token?.kind)
        XCTAssertEqual("m", token?.image)
    }
    
    func testCharSequenceUpperCase() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "C"))).getNextToken()
        XCTAssertEqual(TokenManager.CHAR_SEQUENCE, token?.kind)
        XCTAssertEqual("C", token?.image)
    }
    
    func testColon() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: ":"))).getNextToken()
        XCTAssertEqual(TokenManager.COLON, token?.kind)
        XCTAssertEqual(":", token?.image)
    }
    
    func testDash() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "-"))).getNextToken()
        XCTAssertEqual(TokenManager.DASH, token?.kind)
        XCTAssertEqual("-", token?.image)
    }
    
    func testDigits() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "4"))).getNextToken()
        XCTAssertEqual(TokenManager.DIGITS, token?.kind)
        XCTAssertEqual("4", token?.image)
    }
    
    func testDot() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "."))).getNextToken()
        XCTAssertEqual(TokenManager.DOT, token?.kind)
        XCTAssertEqual(".", token?.image)
    }
    
    func testEol() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "\n"))).getNextToken()
        XCTAssertEqual(TokenManager.EOL, token?.kind)
        XCTAssertEqual("\n", token?.image)
    }
    
    func testEolWithSpaces() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "  \n"))).getNextToken()
        XCTAssertEqual(TokenManager.EOL, token?.kind)
        XCTAssertEqual("  \n", token?.image)
    }
    
    func testEq() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "="))).getNextToken()
        XCTAssertEqual(TokenManager.EQ, token?.kind)
        XCTAssertEqual("=", token?.image)
    }
    
    func testEscapedChar() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "\\*"))).getNextToken()
        XCTAssertEqual(TokenManager.ESCAPED_CHAR, token?.kind)
        XCTAssertEqual("\\*", token?.image)
    }
    
    func testGt() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: ">"))).getNextToken()
        XCTAssertEqual(TokenManager.GT, token?.kind)
        XCTAssertEqual(">", token?.image)
    }
    
    func testImageLabel() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "image:"))).getNextToken()
        XCTAssertEqual(TokenManager.IMAGE_LABEL, token?.kind)
        XCTAssertEqual("image:", token?.image)
    }
    
    func testLbrack() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "["))).getNextToken()
        XCTAssertEqual(TokenManager.LBRACK, token?.kind)
        XCTAssertEqual("[", token?.image)
    }
    
    func testLparen() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "("))).getNextToken()
        XCTAssertEqual(TokenManager.LPAREN, token?.kind)
        XCTAssertEqual("(", token?.image)
    }
    
    func testLt() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "<"))).getNextToken()
        XCTAssertEqual(TokenManager.LT, token?.kind)
        XCTAssertEqual("<", token?.image)
    }
    
    func testRbrack() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "]"))).getNextToken()
        XCTAssertEqual(TokenManager.RBRACK, token?.kind)
        XCTAssertEqual("]", token?.image)
    }
    
    func testRparen() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: ")"))).getNextToken()
        XCTAssertEqual(TokenManager.RPAREN, token?.kind)
        XCTAssertEqual(")", token?.image)
    }
    
    func testSpace() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: " "))).getNextToken()
        XCTAssertEqual(TokenManager.SPACE, token?.kind)
        XCTAssertEqual(" ", token?.image)
    }
    
    func testTab() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "\t"))).getNextToken()
        XCTAssertEqual(TokenManager.TAB, token?.kind)
        XCTAssertEqual("\t", token?.image)
    }
    
    func testUnderscore() {
        let token = TokenManager(stream: CharStream(reader: StringReader(text: "_"))).getNextToken()
        XCTAssertEqual(TokenManager.UNDERSCORE, token?.kind)
        XCTAssertEqual("_", token?.image)
    }
    
    func testLineBreak() {
        let tm = TokenManager(stream: CharStream(reader: StringReader(text: "a\nb")))
        var token = tm.getNextToken()
        XCTAssertEqual(TokenManager.CHAR_SEQUENCE, token?.kind)
        XCTAssertEqual("a", token?.image)
        token = tm.getNextToken()
        XCTAssertEqual(TokenManager.EOL, token?.kind)
        XCTAssertEqual("\n", token?.image)
        token = tm.getNextToken()
        XCTAssertEqual(TokenManager.CHAR_SEQUENCE, token?.kind)
        XCTAssertEqual("b", token?.image)
    }
        
}
