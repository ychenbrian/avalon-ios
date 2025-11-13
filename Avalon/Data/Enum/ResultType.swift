import SwiftUI

enum ResultType: String, Codable {
    case success
    case fail

    var displayText: String {
        switch self {
        case .success: return String(localized: "quest.result.success")
        case .fail: return String(localized: "quest.result.fail")
        }
    }

    var color: Color {
        switch self {
        case .success: return .appColor(.successColor)
        case .fail: return .appColor(.failColor)
        }
    }

    var textColor: Color {
        switch self {
        case .success: return .appColor(.successTextColor)
        case .fail: return .appColor(.failTextColor)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .success: return String(localized: "quest.result.success.accessibility")
        case .fail: return String(localized: "quest.result.fail.accessibility")
        }
    }
}
