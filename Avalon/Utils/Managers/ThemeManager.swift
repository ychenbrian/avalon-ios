import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool

    init(initialIsDarkMode: Bool) {
        isDarkMode = initialIsDarkMode
    }

    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
}
