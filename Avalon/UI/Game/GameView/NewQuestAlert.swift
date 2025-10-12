import SwiftUI

enum NewQuestAlert: Identifiable {
    case confirmNewGame
    case cannotStart
    case confirmStart(quest: QuestViewData)

    var id: String {
        switch self {
        case .confirmNewGame: return "confirmNewGame"
        case .cannotStart: return "cannotStart"
        case let .confirmStart(quest): return "confirmStart-\(quest.id)"
        }
    }
}
