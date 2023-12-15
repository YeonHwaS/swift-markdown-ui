import Foundation

extension Int {
    public var alphabet: String {
        guard self > 0 else {
            return "\(self)"
        }

        let base = 26
        var number = self
        var result = ""

        while number > 0 {
            number -= 1
            let remainder = number % base
            let character = UnicodeScalar(65 + remainder)!
            result = String(character) + result
            number /= base
        }

        return result
    }
}
