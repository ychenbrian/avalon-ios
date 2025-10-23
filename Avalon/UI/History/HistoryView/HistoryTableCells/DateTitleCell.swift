import SwiftUI

struct DateTitleCell: View {
    let date: String

    var body: some View {
        Text(formattedDate)
            .font(.headline)
            .foregroundColor(.primary)
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
}

#Preview {
    VStack {
        DateTitleCell(date: Date().toISOString())
        DateTitleCell(date: "")
    }
}
