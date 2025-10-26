import Foundation

extension String {
    var localized: String { return NSLocalizedString(self, comment: "") }

    func localizedWithArguments(arguments: [CVarArg]) -> String {
        return String(format: localized, arguments: arguments)
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + lowercased().dropFirst()
    }

    func toHourMinute() -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date = isoFormatter.date(from: self)
        if date == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            date = isoFormatter.date(from: self)
        }

        guard let date else { return nil }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale.current
        timeFormatter.timeZone = TimeZone.current

        return timeFormatter.string(from: date)
    }
}
