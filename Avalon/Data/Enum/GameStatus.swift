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
        case .initial: return .appColor(.emptyColor)
        case .inProgress: return .appColor(.selectedColor)
        case .threeSuccesses: return .yellow
        case .threeFails: return .appColor(.failColor)
        case .earlyAssassin: return .appColor(.failColor)
        case .complete: return .appColor(.successColor)
        }
    }
}
