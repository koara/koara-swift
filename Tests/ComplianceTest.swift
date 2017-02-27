import Koara
import XCTest
import Foundation
import Nimble
import Quick

class ComplianceTest: QuickSpec {
    override func spec() {
        describe("ComplianceTest") {
            let testsuite = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("testsuite")
            let modules = FileManager.default.enumerator(at: testsuite.appendingPathComponent("input"), includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
            
            
            while let url = modules?.nextObject() as? URL {
                if(url.lastPathComponent.hasSuffix(".kd") && !url.lastPathComponent.hasPrefix("end2end")) {
                    //let module = url.pathComponents[url.pathComponents.count - 2]
                    let testcase = url.lastPathComponent.substring(to: url.lastPathComponent.index(url.lastPathComponent.endIndex, offsetBy: -3))
                    it("KoaraToHtml_\(testcase)") {
                        //let kd = try String(contentsOf: url, encoding: .utf8)
                        
                        
                    }
                }
            }
        }
    }
}


/*
class ComplianceTest: XCTestCase {
    
    
    func testKoaraToHtml() throws {
 
        let kd = try String(contentsOf: testsuite.appendingPathComponent("input/headings/headings-001-simple.kd"), encoding: .utf8)
        let html = try String(contentsOf: testsuite.appendingPathComponent("output/html5/headings/headings-001-simple.htm"), encoding: .utf8)


        


        let parser = Parser()
        let document = parser.parse(kd)
        let renderer = Html5Renderer()
        document.accept(renderer)

        XCTAssertEqual(html, renderer.getOutput())
    }

    
}
*/
