import SwiftUI

enum NewRoundAlert: Identifiable {
    case cannotStart
    case confirmStart(round: RoundViewData)

    var id: String {
        switch self {
        case .cannotStart: return "cannotStart"
        case let .confirmStart(round): return "confirmStart-\(round.id)"
        }
    }
}
