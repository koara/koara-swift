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
    
    func testScenario000011() throws {
        try assertOutput(file: "end2end-000011", modules: "paragraphs", "headings", "links")
    }
    
    func testScenario000012() throws {
        try assertOutput(file: "end2end-000012", modules: "lists", "links")
    }
    
    func testScenario000013() throws {
        try assertOutput(file: "end2end-000013", modules: "paragraphs", "lists", "links")
    }
    
    func testScenario000014() throws {
        try assertOutput(file: "end2end-000014", modules: "headings", "lists", "links")
    }
    
    func testScenario000015() throws {
        try assertOutput(file: "end2end-000015", modules: "paragraphs", "headings", "lists", "links")
    }
    
    func testScenario000016() throws {
        try assertOutput(file: "end2end-000016", modules: "images")
    }
    
    func testScenario000017() throws {
        try assertOutput(file: "end2end-000017", modules: "paragraphs", "images")
    }
    
    func testScenario000018() throws {
        try assertOutput(file: "end2end-000018", modules: "headings", "images")
    }
    
    func testScenario000019() throws {
        try assertOutput(file: "end2end-000019", modules: "paragraphs", "headings", "images")
    }
    
    func testScenario000020() throws {
        try assertOutput(file: "end2end-000020", modules: "lists", "images")
    }
    
    func testScenario000021() throws {
        try assertOutput(file: "end2end-000021", modules: "paragraphs", "lists", "images")
    }
    
    func testScenario000022() throws {
        try assertOutput(file: "end2end-000022", modules: "headings", "lists", "images")
    }
    
    func testScenario000023() throws {
        try assertOutput(file: "end2end-000023", modules: "paragraphs", "headings", "lists", "images")
    }
    
    func testScenario000024() throws {
        try assertOutput(file: "end2end-000024", modules: "links", "images")
    }
    
    func testScenario000025() throws {
        try assertOutput(file: "end2end-000025", modules: "paragraphs", "links", "images")
    }
    
    func testScenario000026() throws {
        try assertOutput(file: "end2end-000026", modules: "headings", "links", "images")
    }
    
    func testScenario000027() throws {
        try assertOutput(file: "end2end-000027", modules: "paragraphs", "headings", "links", "images")
    }
    
    func testScenario000028() throws {
        try assertOutput(file: "end2end-000028", modules: "lists", "links", "images")
    }
    
    func testScenario000029() throws {
        try assertOutput(file: "end2end-000029", modules: "paragraphs", "lists", "links", "images")
    }
    
    func testScenario000030() throws {
        try assertOutput(file: "end2end-000030", modules: "headings", "lists", "links", "images")
    }
    
    func testScenario000031() throws {
        try assertOutput(file: "end2end-000031", modules: "paragraphs", "headings", "lists", "links", "images")
    }
    
    func testScenario000032() throws {
        try assertOutput(file: "end2end-000032", modules: "formatting")
    }
    
    func testScenario000033() throws {
        try assertOutput(file: "end2end-000033", modules: "paragraphs", "formatting")
    }
    
    func testScenario000034() throws {
        try assertOutput(file: "end2end-000034", modules: "headings", "formatting")
    }
    
    func testScenario000035() throws {
        try assertOutput(file: "end2end-000035", modules: "paragraphs", "headings", "formatting")
    }
    
    func testScenario000036() throws {
        try assertOutput(file: "end2end-000036", modules: "lists", "formatting")
    }
    
    func testScenario000037() throws {
        try assertOutput(file: "end2end-000037", modules: "paragraphs", "lists", "formatting")
    }
    
    func testScenario000038() throws {
        try assertOutput(file: "end2end-000038", modules: "headings", "lists", "formatting")
    }
    
    func testScenario000039() throws {
        try assertOutput(file: "end2end-000039", modules: "paragraphs", "headings", "lists", "formatting")
    }
    
    func testScenario000040() throws {
        try assertOutput(file: "end2end-000040", modules: "links", "formatting")
    }
    
    func testScenario000041() throws {
        try assertOutput(file: "end2end-000041", modules: "paragraphs", "links", "formatting")
    }
    
    func testScenario000042() throws {
        try assertOutput(file: "end2end-000042", modules: "headings", "links", "formatting")
    }
    
    func testScenario000043() throws {
        try assertOutput(file: "end2end-000043", modules: "paragraphs", "headings", "links", "formatting")
    }
    
    func testScenario000044() throws {
        try assertOutput(file: "end2end-000044", modules: "lists", "links", "formatting")
    }
    
    func testScenario000045() throws {
        try assertOutput(file: "end2end-000045", modules: "paragraphs", "lists", "links", "formatting")
    }
    
    func testScenario000046() throws {
        try assertOutput(file: "end2end-000046", modules: "headings", "lists", "links", "formatting")
    }
    
    func testScenario000047() throws {
        try assertOutput(file: "end2end-000047", modules: "paragraphs", "headings", "lists", "links", "formatting")
    }
    
    func testScenario000048() throws {
        try assertOutput(file: "end2end-000048", modules: "images", "formatting")
    }
    
    func testScenario000049() throws {
        try assertOutput(file: "end2end-000049", modules: "paragraphs", "images", "formatting")
    }
    
    func testScenario000050() throws {
        try assertOutput(file: "end2end-000050", modules: "headings", "images", "formatting")
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
