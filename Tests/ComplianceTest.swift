import Koara
import XCTest

class ComplianceTest: XCTestCase {
    
    
    func testKoaraToHtml() throws {
        //let testsuite = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("testsuite")
        //let kd = try String(contentsOf: testsuite.appendingPathComponent("input/paragraphs/paragraphs-001-simple.kd"), encoding: .utf8)
        //let html = try String(contentsOf: testsuite.appendingPathComponent("output/html5/paragraphs/paragraphs-001-simple.htm"), encoding: .utf8)
        
        let kd = "s a"
        let html = "<p>s a</p>"
        
        let parser = Parser()
        let document = parser.parse(kd)
        let renderer = Html5Renderer()
        document.accept(renderer)

        XCTAssertEqual(html, renderer.getOutput())
    }

    
}
