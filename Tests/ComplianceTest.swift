import Koara
import XCTest

class ComplianceTest: XCTestCase {
    
    
    func testKoaraToHtml() throws {
        let testsuite = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("testsuite")
        let kd = try String(contentsOf: testsuite.appendingPathComponent("input/paragraphs/paragraphs-030-unicode-linguistics.kd"), encoding: .utf8)
        let html = try String(contentsOf: testsuite.appendingPathComponent("output/html5/paragraphs/paragraphs-030-unicode-linguistics.htm"), encoding: .utf8)
        
        
        //let de = FileManager.default.enumerator(at: testsuite, includingPropertiesForKeys: [])
        //de?.forEach({ (_) in
        //    print("//")
        //})
        
 

        let parser = Parser()
        let document = parser.parse(kd)
        let renderer = Html5Renderer()
        document.accept(renderer)

        XCTAssertEqual(html, renderer.getOutput())
    }

    
}
