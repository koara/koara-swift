import Koara
import XCTest
import Foundation
import Nimble
import Quick

public class ComplianceTest: QuickSpec {
    override public func spec() {
        describe("ComplianceTest") {
            let testsuite = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("testsuite")
            let modules = FileManager.default.enumerator(at: testsuite.appendingPathComponent("input"), includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
            
            
            while let url = modules?.nextObject() as? URL {
                if(url.lastPathComponent.hasSuffix(".kd") && !url.lastPathComponent.hasPrefix("end2end")) {
                    let module = url.pathComponents[url.pathComponents.count - 2]
                    let testcase = url.lastPathComponent.substring(to: url.lastPathComponent.index(url.lastPathComponent.endIndex, offsetBy: -3)) 
                
                    it("KoaraToHtml_\(testcase)") {
                        do {
                            let expected = testsuite.appendingPathComponent("output").appendingPathComponent("html5").appendingPathComponent(module).appendingPathComponent("\(testcase).htm")

                            let kd = try String(contentsOf: url, encoding: .utf8)
                            let html = try String(contentsOf: expected, encoding: .utf8)
    
                            let parser = Parser()
                            let document = parser.parse(kd)
                            let renderer = Html5Renderer()
                            document.accept(renderer)

                            expect(renderer.getOutput()).to(equal(html))
                            
                        } catch {
                            fail()
                        }
                    }
                    
                    it("KoaraToKoara_\(testcase)") {
                        do {
                            let expected = testsuite.appendingPathComponent("output").appendingPathComponent("koara").appendingPathComponent(module).appendingPathComponent("\(testcase).kd")
                            
                            let kd = try String(contentsOf: url, encoding: .utf8)
                            let kdExpected = try String(contentsOf: expected, encoding: .utf8)
                            
                            let parser = Parser()
                            let document = parser.parse(kd)
                            let renderer = KoaraRenderer()
                            document.accept(renderer)
                            
                            expect(renderer.getOutput()).to(equal(kdExpected))
                            
                        } catch {
                            fail()
                        }
                    }

                }
            }
        }
    }
}
