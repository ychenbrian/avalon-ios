import SwiftUI

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
