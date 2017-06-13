import Foundation

extension String {
    func escapeFirst(of: String) -> String {
        if let range = self.range(of: of, options: .regularExpression) {
            let substr = self[range]
            return self.replacingCharacters(in: range, with: "\\" + substr)
        }
        return self
    }
}

