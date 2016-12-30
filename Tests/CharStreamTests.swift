import XCTest
import Koara

class CharStreamTests: XCTestCase {

    func testBeginToken() {
        let cs = CharStream(reader: StringReader(text: "abcd"))
        XCTAssertEqual("a", try cs.beginToken())
        XCTAssertEqual(1, cs.getBeginColumn())
        XCTAssertEqual(1, cs.getBeginLine())
        XCTAssertEqual(1, cs.getEndColumn())
        XCTAssertEqual(1, cs.getEndLine())
    }
    

    func testReadChar() {
        let cs = CharStream(reader: StringReader(text: "abcd"))
        XCTAssertEqual("a", try cs.readChar())
        XCTAssertEqual("b", try cs.readChar())
        XCTAssertEqual("c", try cs.readChar())
        XCTAssertEqual("d", try cs.readChar())
    }

    func testReadCharTillEof() throws {
        let cs = CharStream(reader: StringReader(text: "abcd"))
        try cs.readChar()
        try cs.readChar()
        try cs.readChar()
        try cs.readChar()
        do {
            try cs.readChar()
            XCTFail()
        } catch KoaraError.IOException() {
        }
    }

    func testGetImage() throws {
        let cs = CharStream(reader: StringReader(text: "abcd"))
        try cs.readChar()
        try cs.readChar()
        XCTAssertEqual("ab", cs.getImage())
    }

    func testBeginTokenWithUnicode() {
        let cs = CharStream(reader: StringReader(text: "ðinæ"))
        XCTAssertEqual("ð", try cs.beginToken())
        XCTAssertEqual(1, cs.getBeginColumn())
        XCTAssertEqual(1, cs.getBeginLine())
        XCTAssertEqual(1, cs.getEndColumn())
        XCTAssertEqual(1, cs.getEndLine())
    }

    func testReadCharWithUnicode() {
        let cs = CharStream(reader: StringReader(text: "ðinæ"))
        XCTAssertEqual("ð", try cs.readChar())
        XCTAssertEqual("i", try cs.readChar())
        XCTAssertEqual("n", try cs.readChar())
        XCTAssertEqual("æ", try cs.readChar())
    }

    func testReadCharTillEofWithUnicode() throws {
        let cs = CharStream(reader: StringReader(text: "ðinæ"))
        try cs.readChar()
        try cs.readChar()
        try cs.readChar()
        try cs.readChar()
        do {
            try cs.readChar()
            XCTFail()
        } catch KoaraError.IOException() {
        }
    }

    func testGetImageWithUnicode() throws {
        let cs = CharStream(reader: StringReader(text: "ðinæ"))
        try cs.readChar()
        try cs.readChar()
        XCTAssertEqual("ði", cs.getImage())
    }
    
}
