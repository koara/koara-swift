import XCTest
import Koara

class StringReaderTest: XCTestCase {
    
    var buffer = [Character]()
    
    override func setUp() {
        super.setUp()
        self.buffer = [Character]()
    }

    func testRead() {
        let reader = StringReader(text: "abcd")
        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 4), 4)
        XCTAssertEqual(buffer[0], "a")
        XCTAssertEqual(buffer[1], "b")
        XCTAssertEqual(buffer[2], "c")
        XCTAssertEqual(buffer[3], "d")
        XCTAssertEqual(buffer.count, 4)
        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 4), -1)
    }

   func testReadPartOfString() {
        let reader = StringReader(text: "abcd")
        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), 2)
        XCTAssertEqual(buffer[0], "a")
        XCTAssertEqual(buffer[1], "b")
        XCTAssertEqual(buffer.count, 2)
    }
    
    func testReadWithOffsetPartOfString() {
        let reader = StringReader(text: "abcd")
        buffer.append(" ")
        buffer.append(" ")
        XCTAssertEqual(reader.read(&buffer, offset: 2, length: 4), 4)
        XCTAssertEqual(" ", buffer[0])
        XCTAssertEqual(" ", buffer[1])
        XCTAssertEqual(buffer[2], "a")
        XCTAssertEqual(buffer[3], "b")
    }
  
    func testReadWithOffsetTooLargePartOfString() {
        let reader = StringReader(text: "abcd")
        buffer.append(" ")
        buffer.append(" ")
        buffer.append(" ")
        buffer.append(" ")
        buffer.append(" ")
        buffer.append(" ")
        XCTAssertEqual(reader.read(&buffer, offset: 6, length: 4), 4)
        XCTAssertEqual(" ", buffer[0])
        XCTAssertEqual(" ", buffer[1])
        XCTAssertEqual(" ", buffer[2])
        XCTAssertEqual(" ", buffer[3])
    }
  
    func testReadUntilEof() {
        let reader = StringReader(text: "abcd")

        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), 2)
        XCTAssertEqual(buffer[0], "a")
        XCTAssertEqual(buffer[1], "b")

        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 3), 2)
        XCTAssertEqual(buffer[0], "c")
        XCTAssertEqual(buffer[1], "d")

        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), -1)
    }

    func testReadWithUnicode() {
        let reader = StringReader(text: "ðinæ");
        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 4), 4)
        XCTAssertEqual(buffer[0], "ð")
        XCTAssertEqual(buffer[1], "i")
        XCTAssertEqual(buffer[2], "n")
        XCTAssertEqual(buffer[3], "æ")
    }
    
    func testReadWithUnicodePartOfString() {
        let reader = StringReader(text: "ðinæ");
        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), 2)
        XCTAssertEqual(buffer[0], "ð")
        XCTAssertEqual(buffer[1], "i")
        XCTAssertEqual(buffer.count, 2)
    }

    func testReadWithUnicodeAndOffsetPartOfString() {
        let reader = StringReader(text: "ðinæ");
        buffer.append(" ")
        buffer.append(" ")
        XCTAssertEqual(reader.read(&buffer, offset: 2, length: 4), 4)
        XCTAssertEqual(" ", buffer[0])
        XCTAssertEqual(" ", buffer[1])
        XCTAssertEqual(buffer[2], "ð")
        XCTAssertEqual(buffer[3], "i")
    }
    
    func testReadWithUnicodeAndOffsetTooLargePartOfString() {
        let reader = StringReader(text: "ðinæ");
        buffer.append(" ")
        buffer.append(" ")
        buffer.append(" ")
        buffer.append(" ")
        buffer.append(" ")
        buffer.append(" ")
        XCTAssertEqual(reader.read(&buffer, offset: 6, length: 4), 4)
        XCTAssertEqual(" ", buffer[0])
        XCTAssertEqual(" ", buffer[1])
        XCTAssertEqual(" ", buffer[2])
        XCTAssertEqual(" ", buffer[3])
    }
    
    func testReadWithUnicodeUntilEof() {
        let reader = StringReader(text: "ðinæ");
        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 3), 3)
        XCTAssertEqual(buffer[0], "ð")
        XCTAssertEqual(buffer[1], "i")

        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 3), 1)
        XCTAssertEqual(buffer[0], "æ")

        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), -1)
    }
    
}
