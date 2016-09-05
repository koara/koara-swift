import XCTest

class FileReaderTest: XCTestCase {
    
    var buffer = [Int:Character]()
    
    override func setUp() {
        super.setUp()
        self.buffer = [Int:Character]()
    }
    
    func testRead() {
        let reader = FileReader(fileName: "test/filereader.kd")
        //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 4), 4)
        //        XCTAssertEqual(buffer[0], "a")
        //        XCTAssertEqual(buffer[1], "b")
        //        XCTAssertEqual(buffer[2], "c")
        //        XCTAssertEqual(buffer[3], "d")
        //        XCTAssertEqual(buffer.count, 4)
        //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 4), -1)
    }
    //
    //    func testReadPartOfString() {
    //        let reader = FileReader(fileName: "test/filereader.kd")
    //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), 2)
    //        XCTAssertEqual(buffer[0], "a")
    //        XCTAssertEqual(buffer[1], "b")
    //        XCTAssertEqual(buffer.count, 2)
    //    }
    //
    //    func testReadWithOffsetPartOfString() {
    //        let reader = FileReader(fileName: "test/filereader.kd")
    //        XCTAssertEqual(reader.read(&buffer, offset: 2, length: 4), 4)
    //        XCTAssertNil(buffer[0])
    //        XCTAssertNil(buffer[1])
    //        XCTAssertEqual(buffer[2], "a")
    //        XCTAssertEqual(buffer[3], "b")
    //    }
    //
    //    func testReadWithOffsetTooLargePartOfString() {
    //        let reader = FileReader(fileName: "test/filereader.kd")
    //        XCTAssertEqual(reader.read(&buffer, offset: 6, length: 4), 4)
    //        XCTAssertNil(buffer[0])
    //        XCTAssertNil(buffer[1])
    //        XCTAssertNil(buffer[2])
    //        XCTAssertNil(buffer[3])
    //    }
    //
    //    func testReadUntilEof() {
    //        let reader = FileReader(fileName: "test/filereader.kd")
    //
    //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), 2)
    //        XCTAssertEqual(buffer[0], "a")
    //        XCTAssertEqual(buffer[1], "b")
    //
    //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 3), 2)
    //        XCTAssertEqual(buffer[0], "c")
    //        XCTAssertEqual(buffer[1], "d")
    //
    //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), -1)
    //    }
    //
    //    func testReadWithUnicode() {
    //        let reader = FileReader(fileName: "test/filereader-unicode.kd")
    //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 4), 4)
    //        XCTAssertEqual(buffer[0], "ð")
    //        XCTAssertEqual(buffer[1], "i")
    //        XCTAssertEqual(buffer[2], "n")
    //        XCTAssertEqual(buffer[3], "æ")
    //        XCTAssertEqual(buffer.count, 4)
    //
    //    }
    //
    //    func testReadWithUnicodePartOfString() {
    //        let reader = FileReader(fileName: "test/filereader-unicode.kd")
    //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), 2)
    //        XCTAssertEqual(buffer[0], "ð")
    //        XCTAssertEqual(buffer[1], "i")
    //        XCTAssertEqual(buffer.count, 2)
    //    }
    //
    //    func testReadWithUnicodeAndOffsetPartOfString() {
    //        let reader = FileReader(fileName: "test/filereader-unicode.kd")
    //        XCTAssertEqual(reader.read(&buffer, offset: 2, length: 4), 4)
    //        XCTAssertNil(buffer[0])
    //        XCTAssertNil(buffer[1])
    //        XCTAssertEqual(buffer[2], "ð")
    //        XCTAssertEqual(buffer[3], "i")
    //    }
    //
    //    func testReadWithUnicodeAndOffsetTooLargePartOfString() {
    //        let reader = FileReader(fileName: "test/filereader-unicode.kd")
    //        XCTAssertEqual(reader.read(&buffer, offset: 6, length: 4), 4)
    //        XCTAssertNil(buffer[0])
    //        XCTAssertNil(buffer[1])
    //        XCTAssertNil(buffer[2])
    //        XCTAssertNil(buffer[3])
    //    }
    //
    //    func testReadWithUnicodeUntilEof() {
    //        let reader = FileReader(fileName: "test/filereader-unicode.kd")
    //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 3), 3)
    //        XCTAssertEqual(buffer[0], "ð")
    //        XCTAssertEqual(buffer[1], "i")
    //        
    //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 3), 1)
    //        XCTAssertEqual(buffer[0], "æ")
    //        
    //        XCTAssertEqual(reader.read(&buffer, offset: 0, length: 2), -1)
    //    }
    
}