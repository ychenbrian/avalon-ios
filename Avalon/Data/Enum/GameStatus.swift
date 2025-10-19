import SwiftUI

enum GameStatus: String, Codable, Equatable {
    case initial
    case inProgress
    case threeSuccesses
    case threeFails
    case earlyAssassin
    case complete

    var color: Color {
        switch self {
        case .initial: return .gray
        case .inProgress: return .blue
        case .threeSuccesses: return .yellow
        case .threeFails: return .red
        case .earlyAssassin: return .red
        case .complete: return .green
        }
    }
}
