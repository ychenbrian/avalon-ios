import SwiftUI

enum NewTeamAlert: Identifiable {
    case cannotStart
    case confirmStart(teamVote: TeamVote)

    var id: String {
        switch self {
        case .cannotStart: return "cannotStart"
        case let .confirmStart(teamVote): return "confirmStart-\(teamVote.id)"
        }
    }
}
