import Foundation
import SwiftUI

struct QuestResult: Equatable {
    var leader: Player?
    var team: [Player]
    var type: ResultType? = nil
    var failCount: Int = 0
}

enum ResultType: String, Codable {
    case success
    case fail

    var displayText: String {
        switch self {
        case .success: return String(localized: "quest.result.success")
        case .fail: return String(localized: "quest.result.fail")
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .fail: return .red
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .success: return String(localized: "quest.result.success.accessibility")
        case .fail: return String(localized: "quest.result.fail.accessibility")
        }
    }
}
