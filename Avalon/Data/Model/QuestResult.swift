import Foundation
import SwiftUI

struct QuestResult: Equatable {
    var leader: Player?
    var team: [Player]
    var type: ResultType? = nil
    var failVotes: Int = 0
}

enum ResultType: String, Codable {
    case success
    case fail

    var displayText: String {
        switch self {
        case .success: return "Success"
        case .fail: return "Fail"
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
        case .success: return "Quest Success"
        case .fail: return "Quest Fail"
        }
    }
}
