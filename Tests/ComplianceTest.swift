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
                    let module = url.pathComponents[url.pathComponents.count - 2]
                    let testcase = url.lastPathComponent.substring(to: url.lastPathComponent.index(url.lastPathComponent.endIndex, offsetBy: -3)) 
                    
                    let expected = testsuite.appendingPathComponent("output").appendingPathComponent("html5").appendingPathComponent(module).appendingPathComponent("\(testcase).htm")

                    it("KoaraToHtml_\(testcase)") {
                        do {
                            let kd = try String(contentsOf: url, encoding: .utf8)
                            let html = try String(contentsOf: expected, encoding: .utf8)
                            
                            let parser = Parser()
                            let document = parser.parse(kd)
                            let renderer = Html5Renderer()
                            document.accept(renderer)
                            
                            
                            print("Expected:")
                            print(html)
                            print("Actual:")
                            print(renderer.getOutput())
                            print("\n\n")
                            
                            expect(renderer.getOutput()).to(equal(html))
                            
                            
                            
                        } catch {
                            fail()
                        }
                    }
                }
            }
        }
    }
}
