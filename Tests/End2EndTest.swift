import XCTest
import Koara
import Nimble
import Quick

class End2EndTest: XCTestCase {
        
    var parser = Parser()
    
    override func setUp() {
        parser = Parser()
    }

    func testScenario000001() throws {
        try assertOutput(file: "end2end-000001", modules: "paragraphs")
    }
    
    func testScenario000002() throws {
        //try assertOutput(file: "end2end-000002", modules: "headings")
    }
    
    func assertOutput(file : String, modules: String...) throws {
        let testsuite = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("testsuite")
        let kd = try String(contentsOf: testsuite.appendingPathComponent("input").appendingPathComponent("end2end.kd"), encoding: .utf8)
        let html = try String(contentsOf: testsuite.appendingPathComponent("output").appendingPathComponent("html5").appendingPathComponent("end2end")
            .appendingPathComponent("\(file).htm"), encoding: .utf8)

        let parser = Parser()
        parser.modules = modules
        let document = parser.parse(kd)
        let renderer = Html5Renderer()
        document.accept(renderer)
        
        print(renderer.getOutput())
        print("-------")
        print(html)
        
        
        expect(renderer.getOutput()).to(equal(html))
        
    }
    
}
