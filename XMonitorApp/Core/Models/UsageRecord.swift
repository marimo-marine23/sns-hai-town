import Foundation

struct UsageRecord: Codable, Identifiable {
    let id: UUID
    let weekStartDate: Date
    let weeklyHours: Double
    let level: TownLevel
    let dialogue: String
    let recordedAt: Date

    init(weekStartDate: Date, weeklyHours: Double, dialogue: String) {
        self.id = UUID()
        self.weekStartDate = weekStartDate
        self.weeklyHours = weeklyHours
        self.level = TownLevel.from(weeklyHours: weeklyHours)
        self.dialogue = dialogue
        self.recordedAt = .now
    }

    private static let weekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d〜"
        return formatter
    }()

    var weekLabel: String {
        Self.weekFormatter.string(from: weekStartDate)
    }
}
