import Koara
import XCTest

class ComplianceTest: XCTestCase {
    
    
    func testKoaraToHtml() throws {
        //let kd = try String(contentsOf: testsuite.appendingPathComponent("input/paragraphs/paragraphs-002-multiline.kd"), encoding: .utf8)
        //let html = try String(contentsOf: testsuite.appendingPathComponent("output/html5/paragraphs/paragraphs-002-multiline.htm"), encoding: .utf8)
        
        let kd = "a\nb"
        let html = "<p>a\nb</p>"
        
        let parser = Parser()
        let document = parser.parse(kd)
        let renderer = Html5Renderer()
        document.accept(renderer)

        XCTAssertEqual(html, renderer.getOutput())
    }

    
}
