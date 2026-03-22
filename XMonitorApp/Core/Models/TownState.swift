import Foundation

struct TownState: Codable {
    var weeklyHours: Double
    var level: TownLevel
    var currentDialogue: String
    var lastUpdated: Date
    var weekStartDate: Date

    init(weeklyHours: Double = 0, date: Date = .now) {
        self.weeklyHours = weeklyHours
        self.level = TownLevel.from(weeklyHours: weeklyHours)
        self.currentDialogue = ""
        self.lastUpdated = date
        self.weekStartDate = Calendar.current.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }

    mutating func updateHours(_ hours: Double) {
        weeklyHours = hours
        level = TownLevel.from(weeklyHours: hours)
        lastUpdated = .now
    }
}
