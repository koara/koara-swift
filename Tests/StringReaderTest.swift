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
        XCTAssertEqual(reader.read(buffer, offset: 0, length: 4), 4)
        //XCTAssertEqual(buffer[0], "a")
        

        //expect(buffer[1]).toEqual('b');
        //expect(buffer[2]).toEqual('c');
        //expect(buffer[3]).toEqual('d');
        //expect(buffer.length).toEqual(4);
        //expect(reader.read(buffer, 0, 4)).toEqual(-1);
    }
}
