import SwiftUI

struct GameSectionTitleView: View {
    let date: String
    let count: Int

    var body: some View {
        HStack {
            Text(formattedDate)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Text(localizedGameCount())
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var formattedDate: String {
        if date == "" {
            return String(localized: "historyView.title.unfinished")
        }

        let formatter = ISO8601DateFormatter()
        guard let isoDate = formatter.date(from: date) else {
            return date
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none

        let calendar = Calendar.current
        if calendar.isDateInToday(isoDate) {
            return String(localized: "date.today")
        } else if calendar.isDateInYesterday(isoDate) {
            return String(localized: "date.yesterday")
        } else {
            return displayFormatter.string(from: isoDate)
        }
    }

    private func localizedGameCount() -> String {
        let key = count == 1 ? "historyView.title.gameSingular" : "historyView.title.gamePlural"
        return key.localizedWithArguments(arguments: [count])
    }
}

#Preview {
    VStack {
        GameSectionTitleView(date: Date().toISOString(), count: 5)
        GameSectionTitleView(date: "", count: 0)
    }
}
