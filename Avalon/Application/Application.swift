import SwiftUI

@main
struct MainApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager: ThemeManager

    init() {
        let repo = DefaultPreferencesRepository()
        let prefs = repo.load()
        _themeManager = StateObject(
            wrappedValue: ThemeManager(initialIsDarkMode: prefs.isDarkModeEnabled)
        )
    }

    var body: some Scene {
        WindowGroup {
            appDelegate.rootView
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}

extension AppEnvironment {
    var rootView: some View {
        VStack {
            if isRunningTests {
                Text("Running unit tests")
            } else {
                ContentView()
                    .modifier(RootViewAppearance())
                    .modelContainer(modelContainer)
                    .inject(diContainer)
                if modelContainer.isStub {
                    Text("⚠️ There is an issue with local database")
                        .font(.caption2)
                }
            }
        }
    }
}
