import Foundation
import SwiftUI

struct AvalonGame: Identifiable {
    let id = UUID()
    var startedAt: String?
    var finishedAt: String?
    var players: [Player]
    var quests: [Quest]
    var status: GameStatus = .initial
    var result: GameResult?
}

// MARK: - Game Rules

enum GameRules {
    static let defaultPlayerCount: Int = 10
    static let questsPerGame: Int = 5
    static let teamsPerQuest: Int = 5
    static let defaultTeamSizeRange: Range<Int> = 3 ..< 6
}

// MARK: - Game Status

enum GameStatus: String, Codable, Equatable {
    case initial
    case inProgress
    case finish

    var color: Color {
        switch self {
        case .initial: return .gray.opacity(0.3)
        case .inProgress: return .blue
        case .finish: return .green
        }
    }
}

enum GameResult: String, Codable, Equatable {
    case goodWinByQuest
    case goodWinByFailedAss
    case evilWinByQuest
    case evilWinByAssassin

    var color: Color {
        switch self {
        case .goodWinByQuest, .goodWinByFailedAss: return .green
        case .evilWinByQuest, .evilWinByAssassin: return .red
        }
    }
}
