import SwiftUI

enum QuestStatus: String, Codable, Equatable {
    case notStarted
    case inProgress
    case finished

    var color: Color {
        switch self {
        case .notStarted: return .appColor(.emptyColor)
        case .inProgress: return .appColor(.selectedColor)
        case .finished: return .appColor(.successColor)
        }
    }
}
