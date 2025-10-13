import SwiftUI

enum GameViewAlert: Identifiable {
    case cannotStart
    case confirmStart(quest: QuestViewData)

    var id: String {
        switch self {
        case .cannotStart: return "cannotStart"
        case let .confirmStart(quest): return "confirmStart-\(quest.id)"
        }
    }
}
