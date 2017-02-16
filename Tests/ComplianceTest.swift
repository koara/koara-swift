import Koara
import XCTest

class ComplianceTest: XCTestCase {
    
    
    func testKoaraToHtml() throws {
        //let testsuite = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("testsuite")
        //let kd = try String(contentsOf: testsuite.appendingPathComponent("input/paragraphs/paragraphs-002-multiline.kd"), encoding: .utf8)
        //let html = try String(contentsOf: testsuite.appendingPathComponent("output/html5/paragraphs/paragraphs-002-multiline.htm"), encoding: .utf8)
        
        
        //let de = FileManager.default.enumerator(at: testsuite, includingPropertiesForKeys: [])
        //de?.forEach({ (_) in
        //    print("//")
        //})
        
 
        let kd = "crea line break,  \nyou"
        //let html = "<p>create a line break,<br>you</p>"
        
        let parser = Parser()
        let document = parser.parse(kd)
        let renderer = Html5Renderer()
        document.accept(renderer)
        
        print(renderer.getOutput())

        //XCTAssertEqual(html, renderer.getOutput())
    }

    
}
