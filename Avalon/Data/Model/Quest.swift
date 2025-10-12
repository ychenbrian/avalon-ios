import Foundation
import SwiftUI

struct Quest: Identifiable, Equatable {
    let id = UUID()
    let index: Int
    var status: QuestStatus = .notStarted
    var quest: QuestResult?
    var teams: [Team]
    var currentTeam: Int = 0

    var requiredTeamSize: Int { [3, 4, 4, 5, 5][index] }
    var requiredFails: Int { index == 3 ? 2 : 1 }

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
