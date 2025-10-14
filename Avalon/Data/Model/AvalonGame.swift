import Foundation
import SwiftUI

struct AvalonGame: Identifiable {
    let id = UUID()
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

// MARK: - Game Result

enum GameResult: String, Codable, Equatable, CaseIterable {
    case goodWinByFailedAss
    case evilWinByQuest
    case evilWinByAssassin

    var color: Color {
        switch self {
        case .goodWinByFailedAss:
            return .green
        case .evilWinByQuest, .evilWinByAssassin:
            return .red
        }
    }

    private var localizationKey: String {
        switch self {
        case .goodWinByFailedAss:
            return "game.result.goodWin.assistanationFail"
        case .evilWinByQuest:
            return "game.result.evilWin.threeFailedQuests"
        case .evilWinByAssassin:
            return "game.result.evilWin.assistanationSuccess"
        }
    }

    var displayText: String {
        String(localized: String.LocalizationValue(localizationKey))
    }

    init?(displayText: String) {
        self.init(rawValue: Self.allCases.first {
            $0.displayText == displayText
        }?.rawValue ?? "")
    }
}
