import SwiftUI

enum NewRoundAlert: Identifiable {
    case confirmNewGame
    case cannotStart
    case confirmStart(round: RoundViewData)

    var id: String {
        switch self {
        case .confirmNewGame: return "confirmNewGame"
        case .cannotStart: return "cannotStart"
        case let .confirmStart(round): return "confirmStart-\(round.id)"
        }
    }
}
