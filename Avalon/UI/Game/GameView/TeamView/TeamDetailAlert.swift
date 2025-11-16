import SwiftUI

enum TeamDetailAlert: Identifiable {
    case cannotEditTeam

    var id: String {
        switch self {
        case .cannotEditTeam: return "cannotEditTeam"
        }
    }
}
