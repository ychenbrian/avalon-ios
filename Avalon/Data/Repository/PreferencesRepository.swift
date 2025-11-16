import Foundation

protocol PreferencesRepository {
    func load() -> UserPreferences
    func save(_ prefs: UserPreferences)
}

final class DefaultPreferencesRepository: PreferencesRepository {
    private enum Keys {
        static let prefs = "user.preferences"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> UserPreferences {
        guard
            let data = defaults.data(forKey: Keys.prefs),
            let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data)
        else {
            return UserPreferences(isDarkModeEnabled: false)
        }
        return prefs
    }

    func save(_ prefs: UserPreferences) {
        if let data = try? JSONEncoder().encode(prefs) {
            defaults.set(data, forKey: Keys.prefs)
        }
    }
}
