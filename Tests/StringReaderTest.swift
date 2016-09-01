import XCTest

class StringReaderTest: XCTestCase {
    
    var buffer = [Int:Character]()
    
    override func setUp() {
        super.setUp()
        self.buffer = [Int:Character]()
    }
    
//    func testRead() {
//        let reader = StringReader(text: "abcd")
//        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 4), 4)
//        XCTAssertEqual(buffer[0], "a")
//        XCTAssertEqual(buffer[1], "b")
//        XCTAssertEqual(buffer[2], "c")
//        XCTAssertEqual(buffer[3], "d")
//        XCTAssertEqual(buffer.count, 4)
//        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 4), -1)
//    }
//    
//    func testReadPartOfString() {
//        let reader = StringReader(text: "abcd")
//        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), 2)
//        XCTAssertEqual(buffer[0], "a")
//        XCTAssertEqual(buffer[1], "b")
//        XCTAssertEqual(buffer.count, 2)
//    }
//    
//    func testReadWithOffsetPartOfString() {
//        let reader = StringReader(text: "abcd")
//        XCTAssertEqual(reader.read(&buffer, offset: 2, length: 4), 4)
//        XCTAssertNil(buffer[0])
//        XCTAssertNil(buffer[1])
//        XCTAssertEqual(buffer[2], "a")
//        XCTAssertEqual(buffer[3], "b")
//    }
//    
//    func testReadWithOffsetTooLargePartOfString() {
//        let reader = StringReader(text: "abcd")
//        XCTAssertEqual(reader.read(&buffer, offset: 6, length: 4), 4)
//        XCTAssertNil(buffer[0])
//        XCTAssertNil(buffer[1])
//        XCTAssertNil(buffer[2])
//        XCTAssertNil(buffer[3])
//    }
    
    func testReadUntilEof() {
        let reader = StringReader(text: "abcd")

        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), 2)
        XCTAssertEqual(buffer[0], "a")
        XCTAssertEqual(buffer[1], "b")

        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 3), 2)
        //XCTAssertEqual(buffer[0], "c")
        //XCTAssertEqual(buffer[1], "d")

        //XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), -1)
    }
        
    //
    //    it("Test Read With Unicode", function() {
    //    var reader = new koara.StringReader('ðinæ');
    //    expect(reader.read(buffer, 0, 4)).toEqual(4);
    //    expect(buffer[0]).toEqual('ð');
    //    expect(buffer[1]).toEqual('i');
    //    expect(buffer[2]).toEqual('n');
    //    expect(buffer[3]).toEqual('æ');
    //    });
    //
    //    it("Test Read With Unicode Part Of String", function() {
    //    var reader = new koara.StringReader('ðinæ');
    //    expect(reader.read(buffer, 0, 2)).toEqual(2);
    //    expect(buffer[0]).toEqual('ð');
    //    expect(buffer[1]).toEqual('i');
    //    expect(buffer.length).toEqual(2);
    //    });
    //
    //    it("Test Read With Unicode And Offset Part Of String", function() {
    //    var reader = new koara.StringReader('ðinæ');
    //    expect(reader.read(buffer, 2, 4)).toEqual(4);
    //    expect(0 in buffer).toBe(false);
    //    expect(1 in buffer).toBe(false);
    //    expect(buffer[2]).toEqual('ð');
    //    expect(buffer[3]).toEqual('i');
    //    });
    //
    //    it("Test Read With Unicode And Offset Too Large Part Of String", function() {
    //    var reader = new koara.StringReader('ðinæ');
    //    expect(reader.read(buffer, 6, 4)).toEqual(4);
    //    expect(0 in buffer).toBe(false);
    //    expect(1 in buffer).toBe(false);
    //    expect(2 in buffer).toBe(false);
    //    expect(3 in buffer).toBe(false);
    //    });
    //
    //    it("Test Read With Unicode Until Eof", function() {
    //    var reader = new koara.StringReader('ðinæ');
    //    expect(reader.read(buffer, 0, 3)).toEqual(3);
    //    expect(buffer[0]).toEqual('ð');
    //    expect(buffer[1]).toEqual('i');
    //    
    //    expect(reader.read(buffer, 0, 3)).toEqual(1);
    //    expect(buffer[0]).toEqual('æ');
    //    
    //    expect(reader.read(buffer, 0, 2)).toEqual(-1);
    //    });
    
    
    
}
