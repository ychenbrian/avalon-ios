import Foundation

extension String {
    var localized: String { return NSLocalizedString(self, comment: "") }

    func localizedWithArguments(arguments: [CVarArg]) -> String {
        return String(format: localized, arguments: arguments)
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + lowercased().dropFirst()
    }
}
