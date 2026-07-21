import SwiftUI

struct LastWateredText: View {
    let date: Date?

    var body: some View {
        if let date {
            TimelineView(
                .periodic(from: .now, by: 30)
            ) { context in
                Text(
                    text(
                        for: date,
                        relativeTo: context.date
                    )
                )
            }
        } else {
            Text("Never watered")
        }
    }

    private func text(
        for date: Date,
        relativeTo now: Date
    ) -> String {
        let elapsed = max(
            0,
            now.timeIntervalSince(date)
        )

        if elapsed < 30 {
            return "Just now"
        }

        let month: TimeInterval = 30 * 24 * 60 * 60

        if elapsed >= month {
            return "More than a month ago"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .numeric

        return formatter.localizedString(
            for: date,
            relativeTo: now
        )
    }
}
