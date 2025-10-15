import SwiftUI

extension Date {
    func toISOString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
}
