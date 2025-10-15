import Foundation
import SwiftUI

struct Quest: Identifiable, Equatable {
    var id = UUID()
    var index: Int
    var numOfPlayers: Int
    var status: QuestStatus = .notStarted
    var result: QuestResult?
    var teams: [Team]

    static func == (lhs: Quest, rhs: Quest) -> Bool {
        lhs.id == rhs.id
    }
}

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
