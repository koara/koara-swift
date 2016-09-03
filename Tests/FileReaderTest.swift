import XCTest

class FileReaderTest: XCTestCase {

    var buffer = [Int:Character]()
    
    override func setUp() {
        super.setUp()
        self.buffer = [Int:Character]()
    }
    
    func testRead() {
//    @reader = Koara::Io::FileReader.new('test/filereader.kd')
//    assert_equal(4, @reader.read(@buffer, 0, 4))
//    assert_equal('a', @buffer[0])
//    assert_equal('b', @buffer[1])
//    assert_equal('c', @buffer[2])
//    assert_equal('d', @buffer[3])
//    assert_equal(4, @buffer.length)
//    assert_equal(-1, @reader.read(@buffer, 0, 4))
    }
    
    func testReadPartOfString() {
//    @reader = Koara::Io::FileReader.new('test/filereader.kd')
//    assert_equal(2, @reader.read(@buffer, 0, 2))
//    assert_equal('a', @buffer[0])
//    assert_equal('b', @buffer[1])
//    assert_equal(2, @buffer.length)
    }
    
    func testReadWithOffsetPartOfString() {
//    @reader = Koara::Io::FileReader.new('test/filereader.kd')
//    assert_equal(4, @reader.read(@buffer, 2, 4))
//    assert_equal(nil, @buffer[0])
//    assert_equal(nil, @buffer[1])
//    assert_equal('a', @buffer[2])
//    assert_equal('b', @buffer[3])
    }
    
    func testReadWithOffsetTooLargePartOfString() {
//    @reader = Koara::Io::FileReader.new('test/filereader.kd')
//    assert_equal(4, @reader.read(@buffer, 6, 4))
//    assert_equal(nil, @buffer[0])
//    assert_equal(nil, @buffer[1])
//    assert_equal(nil, @buffer[2])
//    assert_equal(nil, @buffer[3])
    }
    
    func testReadUntilEof() {
//    @reader = Koara::Io::FileReader.new('test/filereader.kd')
//    assert_equal(2, @reader.read(@buffer, 0, 2))
//    assert_equal('a', @buffer[0])
//    assert_equal('b', @buffer[1])
//    assert_equal(2, @reader.read(@buffer, 0, 3))
//    assert_equal('c', @buffer[0])
//    assert_equal('d', @buffer[1])
//    assert_equal(-1, @reader.read(@buffer, 0, 2))
    }
    
    func testReadWithUnicode() {
//    @reader = Koara::Io::FileReader.new('test/filereader-unicode.kd')
//    assert_equal(4, @reader.read(@buffer, 0, 4))
//    assert_equal('ð', @buffer[0])
//    assert_equal('i', @buffer[1])
//    assert_equal('n', @buffer[2])
//    assert_equal('æ', @buffer[3])
//    assert_equal(4, @buffer.length)
    }
    
    func testReadWithUnicodePartOfString() {
//    @reader = Koara::Io::FileReader.new('test/filereader-unicode.kd')
//    assert_equal(2, @reader.read(@buffer, 0, 2))
//    assert_equal('ð', @buffer[0])
//    assert_equal('i', @buffer[1])
//    assert_equal(2, @buffer.length)
    }
    
    func testReadWithUnicodeAndOffsetPartOfString() {
//    @reader = Koara::Io::FileReader.new('test/filereader-unicode.kd')
//    assert_equal(4, @reader.read(@buffer, 2, 4))
//    assert_equal(nil, @buffer[0])
//    assert_equal(nil, @buffer[1])
//    assert_equal('ð', @buffer[2])
//    assert_equal('i', @buffer[3])
    }
    
    func testReadWithUnicodeAndOffsetTooLargePartOfString() {
//    @reader = Koara::Io::FileReader.new('test/filereader-unicode.kd')
//    assert_equal(4, @reader.read(@buffer, 6, 4))
//    assert_equal(nil, @buffer[0])
//    assert_equal(nil, @buffer[1])
//    assert_equal(nil, @buffer[2])
//    assert_equal(nil, @buffer[3])
    }
    
    func testReadWithUnicodeUntilEof() {
//    @reader = Koara::Io::FileReader.new('test/filereader-unicode.kd')
//    assert_equal(3, @reader.read(@buffer, 0, 3))
//    assert_equal('ð', @buffer[0])
//    assert_equal('i', @buffer[1])
//    assert_equal('n', @buffer[2])
//    assert_equal(1, @reader.read(@buffer, 0, 3))
//    assert_equal('æ', @buffer[0])
//    assert_equal(-1, @reader.read(@buffer, 0, 2))
    }
    
}