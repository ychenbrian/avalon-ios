import SwiftUI

public enum AppColor: String {
    case successColor
    case failColor
    case selectedColor
    case emptyColor

    case successTextColor
    case failTextColor
    case selectedTextColor
    case primaryTextColor
    case disabledTextColor

    case circleRing
}

public extension Color {
    static func appColor(_ name: AppColor, bundle: Bundle = .main) -> Color {
        Color(name.rawValue, bundle: bundle)
    }
}
