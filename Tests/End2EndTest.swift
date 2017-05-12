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
        try assertOutput(file: "end2end-000002", modules: "headings")
    }
    
    func testScenario000003() throws {
        try assertOutput(file: "end2end-000003", modules: "paragraphs", "headings")
    }
    
    func testScenario000004() throws {
        try assertOutput(file: "end2end-000004", modules: "lists")
    }
    
    func testScenario000005() throws {
        try assertOutput(file: "end2end-000005", modules: "paragraphs", "lists")
    }
    
    func testScenario000006() throws {
        try assertOutput(file: "end2end-000006", modules: "headings", "lists")
    }
    
    func testScenario000007() throws {
        try assertOutput(file: "end2end-000007", modules: "paragraphs", "headings", "lists")
    }
    
    func testScenario000008() throws {
        try assertOutput(file: "end2end-000008", modules: "links")
    }
    
    func testScenario000009() throws {
        try assertOutput(file: "end2end-000009", modules: "paragraphs", "links")
    }
    
    func testScenario000010() throws {
        try assertOutput(file: "end2end-000010", modules: "headings", "links")
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
        
        print(html)
        print("@----")
        print(renderer.getOutput())
        
        
        expect(renderer.getOutput()).to(equal(html))
    }
    
}
