import SwiftUI

enum QuestStatus: String, Codable, Equatable {
    case notStarted
    case inProgress
    case finished

    var color: Color {
        switch self {
        case .notStarted: return .gray.opacity(0.3)
        case .inProgress: return .blue
        case .finished: return .green
        }
    }
}
