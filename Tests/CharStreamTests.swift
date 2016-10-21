import XCTest

class CharStreamTests: XCTestCase {
    
    func testBeginToken() {
        let cs = CharStream(reader: StringReader(text: "abcd"))
        XCTAssertEqual("a", cs.beginToken())
        XCTAssertEqual(1, cs.getBeginColumn())
        XCTAssertEqual(1, cs.getBeginLine())
        XCTAssertEqual(1, cs.getEndColumn())
        XCTAssertEqual(1, cs.getEndLine())
    }
    

    func testReadChar() {
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('abcd'))
//    assert_equal('a', cs.read_char())
//    assert_equal('b', cs.read_char())
//    assert_equal('c', cs.read_char())
//    assert_equal('d', cs.read_char())
    }

    func testReadCharTillEof() {
//    assert_raises IOError do
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('abcd'))
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    cs.read_char
    }
  
    func testGetImage() {
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('abcd'))
//    cs.read_char
//    cs.read_char
//    assert_equal('ab', cs.image)
    }

    func testBeginTokenWithUnicode() {
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('ðinæ'))
//    assert_equal('ð', cs.begin_token)
//    assert_equal(1, cs.begin_column)
//    assert_equal(1, cs.begin_line)
//    assert_equal(1, cs.end_column)
//    assert_equal(1, cs.end_line)
    }

    func testReadCharWithUnicode() {
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('ðinæ'))
//    assert_equal('ð', cs.read_char)
//    assert_equal('i', cs.read_char)
//    assert_equal('n', cs.read_char)
//    assert_equal('æ', cs.read_char)
    }

    func testReadCharTillEofWithUnicode() {
//    assert_raises IOError do
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('ðinæ'))
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    cs.read_char
    }

    func testGetImageWithUnicode() {
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('ðinæ'))
//    cs.read_char
//    cs.read_char
//    assert_equal('ði', cs.image)
//    end
    }
}
