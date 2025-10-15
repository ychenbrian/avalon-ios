import SwiftUI

struct TeamResult: Codable, Equatable {
    let isApproved: Bool
    let approvedCount: Int
    let rejectedCount: Int
    let decidedAt: Date

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
        case true: return .green
        case false: return .red
        }
    }
}
