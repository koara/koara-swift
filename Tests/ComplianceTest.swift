import Koara
import XCTest
import Foundation

class ComplianceTest: XCTestCase {
    
    
    func testKoaraToHtml() throws {
        let testsuite = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("testsuite")
        let kd = try String(contentsOf: testsuite.appendingPathComponent("input/paragraphs/paragraphs-031-unicode-science.kd"), encoding: .utf8)
        let html = try String(contentsOf: testsuite.appendingPathComponent("output/html5/paragraphs/paragraphs-031-unicode-science.htm"), encoding: .utf8)

        /*
        let modules = FileManager.default.enumerator(at: testsuite.appendingPathComponent("input"), includingPropertiesForKeys: [],
                                                     options: [ .skipsSubdirectoryDescendants, .skipsHiddenFiles])
        while let url = modules?.nextObject() as? URL {
            if(!url.lastPathComponent.hasPrefix("end2end")) {
                print("\(url)")
                
            }
        }*/
            
            
            

       
        
 

        let parser = Parser()
        let document = parser.parse(kd)
        let renderer = Html5Renderer()
        document.accept(renderer)

        XCTAssertEqual(html, renderer.getOutput())
    }

    
}
