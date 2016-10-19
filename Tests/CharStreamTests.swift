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
    

//    def test_read_char
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('abcd'))
//    assert_equal('a', cs.read_char())
//    assert_equal('b', cs.read_char())
//    assert_equal('c', cs.read_char())
//    assert_equal('d', cs.read_char())
//    end
//    
//    def test_read_char_till_eof
//    assert_raises IOError do
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('abcd'))
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    end
//    end
//    
//    def test_get_image
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('abcd'))
//    cs.read_char
//    cs.read_char
//    assert_equal('ab', cs.image)
//    end
//    
//    def test_begin_token_with_unicode
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('ðinæ'))
//    assert_equal('ð', cs.begin_token)
//    assert_equal(1, cs.begin_column)
//    assert_equal(1, cs.begin_line)
//    assert_equal(1, cs.end_column)
//    assert_equal(1, cs.end_line)
//    end
//    
//    def test_read_char_with_unicode
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('ðinæ'))
//    assert_equal('ð', cs.read_char)
//    assert_equal('i', cs.read_char)
//    assert_equal('n', cs.read_char)
//    assert_equal('æ', cs.read_char)
//    end
//    
//    def test_read_char_till_eof_with_unicode
//    assert_raises IOError do
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('ðinæ'))
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    cs.read_char
//    end
//    end
//    
//    def test_get_image_with_unicode
//    cs = Koara::CharStream.new(Koara::Io::StringReader.new('ðinæ'))
//    cs.read_char
//    cs.read_char
//    assert_equal('ði', cs.image)
//    end
//    
}
