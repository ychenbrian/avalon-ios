import Foundation
import SwiftUI

struct AvalonGame: Identifiable {
    var id = UUID()
    var name: String?
    var startedAt: String?
    var finishedAt: String?
    var players: [Player]
    var quests: [Quest]
    var status: GameStatus = .inProgress
    var result: GameResult?
}

// MARK: - Game Status

enum GameStatus: String, Codable, Equatable {
    case inProgress
    case threeSuccesses
    case threeFails
    case earlyAssassin
    case complete

    var color: Color {
        switch self {
        case .inProgress: return .blue
        case .threeSuccesses: return .yellow
        case .threeFails: return .red
        case .earlyAssassin: return .red
        case .complete: return .green
        }
    }
}
