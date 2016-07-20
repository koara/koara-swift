import XCTest
@testable import Koara

class StringReaderTest: XCTestCase {
    
    var buffer: [Character]!
    
    override func setUp() {
        super.setUp()
        self.buffer = []
    }
    
    func testRead() {
        let reader = StringReader(text: "abcd")
        XCTAssertEqual(reader.read(), -1)
    }
}
