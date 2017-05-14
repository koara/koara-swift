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
    
    func testScenario000051() throws {
        try assertOutput(file: "end2end-000051", modules: "paragraphs", "headings", "images", "formatting")
    }
    
    func testScenario000052() throws {
        try assertOutput(file: "end2end-000052", modules: "lists", "images", "formatting")
    }
    
    func testScenario000053() throws {
        try assertOutput(file: "end2end-000053", modules: "paragraphs", "lists", "images", "formatting")
    }
    
    func testScenario000054() throws {
        try assertOutput(file: "end2end-000054", modules: "headings", "lists", "images", "formatting")
    }
    
    func testScenario000055() throws {
        try assertOutput(file: "end2end-000055", modules: "paragraphs", "headings", "lists", "images", "formatting")
    }
    
    func testScenario000056() throws {
        try assertOutput(file: "end2end-000056", modules: "links", "images", "formatting")
    }
    
    func testScenario000057() throws {
        try assertOutput(file: "end2end-000057", modules: "paragraphs", "links", "images", "formatting")
    }
    
    func testScenario000058() throws {
        try assertOutput(file: "end2end-000058", modules: "headings", "links", "images", "formatting")
    }
    
    func testScenario000059() throws {
        try assertOutput(file: "end2end-000059", modules: "paragraphs", "headings", "links", "images", "formatting")
    }
    
    func testScenario000060() throws {
        try assertOutput(file: "end2end-000060", modules: "lists", "links", "images", "formatting")
    }
    
    func testScenario000061() throws {
        try assertOutput(file: "end2end-000061", modules: "paragraphs", "lists", "links", "images", "formatting")
    }
    
    func testScenario000062() throws {
        try assertOutput(file: "end2end-000062", modules: "headings", "lists", "links", "images", "formatting")
    }
    
    func testScenario000063() throws {
        try assertOutput(file: "end2end-000063", modules: "paragraphs", "headings", "lists", "links", "images", "formatting")
    }
    
    func testScenario000064() throws {
        try assertOutput(file: "end2end-000064", modules: "blockquotes")
    }
    
    func testScenario000065() throws {
        try assertOutput(file: "end2end-000065", modules: "paragraphs", "blockquotes")
    }
    
    func testScenario000066() throws {
        try assertOutput(file: "end2end-000066", modules: "headings", "blockquotes")
    }
    
    func testScenario000067() throws {
        try assertOutput(file: "end2end-000067", modules: "paragraphs", "headings", "blockquotes")
    }
    
    func testScenario000068() throws {
        try assertOutput(file: "end2end-000068", modules: "lists", "blockquotes")
    }
    
    func testScenario000069() throws {
        try assertOutput(file: "end2end-000069", modules: "paragraphs", "lists", "blockquotes")
    }
    
    func testScenario000070() throws {
        try assertOutput(file: "end2end-000070", modules: "headings", "lists", "blockquotes")
    }
    
    func testScenario000071() throws {
        try assertOutput(file: "end2end-000071", modules: "paragraphs", "headings", "lists", "blockquotes")
    }
    
    func testScenario000072() throws {
        try assertOutput(file: "end2end-000072", modules: "links", "blockquotes")
    }
    
    func testScenario000073() throws {
        try assertOutput(file: "end2end-000073", modules: "paragraphs", "links", "blockquotes")
    }
    
    func testScenario000074() throws {
        try assertOutput(file: "end2end-000074", modules: "headings", "links", "blockquotes")
    }
    
    func testScenario000075() throws {
        try assertOutput(file: "end2end-000075", modules: "paragraphs", "headings", "links", "blockquotes")
    }
    
    func testScenario000076() throws {
        try assertOutput(file: "end2end-000076", modules: "lists", "links", "blockquotes")
    }
    
    func testScenario000077() throws {
        try assertOutput(file: "end2end-000077", modules: "paragraphs", "lists", "links", "blockquotes")
    }
    
    func testScenario000078() throws {
        try assertOutput(file: "end2end-000078", modules: "headings", "lists", "links", "blockquotes")
    }
    
    func testScenario000079() throws {
        try assertOutput(file: "end2end-000079", modules: "paragraphs", "headings", "lists", "links", "blockquotes")
    }
    
    func testScenario000080() throws {
        try assertOutput(file: "end2end-000080", modules: "images", "blockquotes")
    }
    
    func testScenario000081() throws {
        try assertOutput(file: "end2end-000081", modules: "paragraphs", "images", "blockquotes")
    }
    
    func testScenario000082() throws {
        try assertOutput(file: "end2end-000082", modules: "headings", "images", "blockquotes")
    }
    
    func testScenario000083() throws {
        try assertOutput(file: "end2end-000083", modules: "paragraphs", "headings", "images", "blockquotes")
    }
    
    func testScenario000084() throws {
        try assertOutput(file: "end2end-000084", modules: "lists", "images", "blockquotes")
    }
    
    func testScenario000085() throws {
        try assertOutput(file: "end2end-000085", modules: "paragraphs", "lists", "images", "blockquotes")
    }
    
    func testScenario000086() throws {
        try assertOutput(file: "end2end-000086", modules: "headings", "lists", "images", "blockquotes")
    }
    
    func testScenario000087() throws {
        try assertOutput(file: "end2end-000087", modules: "paragraphs", "headings", "lists", "images", "blockquotes")
    }
    
    func testScenario000088() throws {
        try assertOutput(file: "end2end-000088", modules: "links", "images", "blockquotes")
    }
    
    func testScenario000089() throws {
        try assertOutput(file: "end2end-000089", modules: "paragraphs", "links", "images", "blockquotes")
    }
    
    func testScenario000090() throws {
        try assertOutput(file: "end2end-000090", modules: "headings", "links", "images", "blockquotes")
    }
    
    func testScenario000091() throws {
        try assertOutput(file: "end2end-000091", modules: "paragraphs", "headings", "links", "images", "blockquotes")
    }
    
    func testScenario000092() throws {
        try assertOutput(file: "end2end-000092", modules: "lists", "links", "images", "blockquotes")
    }
    
    func testScenario000093() throws {
        try assertOutput(file: "end2end-000093", modules: "paragraphs", "lists", "links", "images", "blockquotes")
    }
    
    func testScenario000094() throws {
        try assertOutput(file: "end2end-000094", modules: "headings", "lists", "links", "images", "blockquotes")
    }
    
    func testScenario000095() throws {
        try assertOutput(file: "end2end-000095", modules: "paragraphs", "headings", "lists", "links", "images", "blockquotes")
    }
    
    func testScenario000096() throws {
        try assertOutput(file: "end2end-000096", modules: "formatting", "blockquotes")
    }
    
    func testScenario000097() throws {
        try assertOutput(file: "end2end-000097", modules: "paragraphs", "formatting", "blockquotes")
    }
    
    func testScenario000098() throws {
        try assertOutput(file: "end2end-000098", modules: "headings", "formatting", "blockquotes")
    }
    
    func testScenario000099() throws {
        try assertOutput(file: "end2end-000099", modules: "paragraphs", "headings", "formatting", "blockquotes")
    }
    
    func testScenario000100() throws {
        try assertOutput(file: "end2end-000100", modules: "lists", "formatting", "blockquotes")
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
