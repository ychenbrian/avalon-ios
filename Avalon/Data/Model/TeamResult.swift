import SwiftData
import SwiftUI

@Model
final class TeamResult {
    var isApproved: Bool
    var approvedCount: Int
    var rejectedCount: Int
    var decidedAt: Date

    init(isApproved: Bool, approvedCount: Int, rejectedCount: Int, decidedAt: Date = Date()) {
        self.isApproved = isApproved
        self.approvedCount = approvedCount
        self.rejectedCount = rejectedCount
        self.decidedAt = decidedAt
    }

    var displayText: String {
        switch isApproved {
        case true: return String(localized: "team.result.approve")
        case false: return String(localized: "team.result.reject")
        }
    }

    var color: Color {
        switch isApproved {
        case true: return .appColor(.successColor)
        case false: return .appColor(.failColor)
        }
    }

    var textColor: Color {
        switch isApproved {
        case true: return .appColor(.successTextColor)
        case false: return .appColor(.failTextColor)
        }
    }
}
