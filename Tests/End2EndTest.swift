import XCTest
import Koara

class End2EndTest: XCTestCase {
        
    var parser = Parser()
    
    override func setUp() {
        parser = Parser()
    }

    func testScenario000001() throws {
        try assertOutput(file: "end2end-000001", modules: "paragraphs")
    }
    

    
    func assertOutput(file : String, modules: String...) throws {
        let testsuite = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("testsuite")
        let input = try String(contentsOf: testsuite.appendingPathComponent("input").appendingPathComponent("end2end.kd"), encoding: .utf8)
        //print(expected)
    }
    
}
