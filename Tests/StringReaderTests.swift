import Koara
import XCTest

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
    
    
}
