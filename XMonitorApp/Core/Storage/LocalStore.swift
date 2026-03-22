import Foundation

final class LocalStore {
    static let shared = LocalStore()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let townState = "townState"
        static let records = "usageRecords"
        static let secretUnlocked = "secretUnlocked"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let preferredDataSource = "preferredDataSource"
        static let mayorName = "mayorName"
        static let selectedSNS = "selectedSNS"
    }

    // MARK: - Town State

    func saveTownState(_ state: TownState) {
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: Keys.townState)
        }
    }

    func loadTownState() -> TownState {
        guard let data = defaults.data(forKey: Keys.townState),
              let state = try? JSONDecoder().decode(TownState.self, from: data) else {
            return TownState()
        }
        return state
    }

    // MARK: - Usage Records (History)

    private static let maxRecords = 52 // 約1年分

    func addRecord(_ record: UsageRecord) {
        var records = loadRecords()
        // 同じ週のレコードがあれば上書き
        records.removeAll { Calendar.current.isDate($0.weekStartDate, inSameDayAs: record.weekStartDate) }
        records.append(record)
        // 古いレコードを削除（上限超過時）
        if records.count > Self.maxRecords {
            records = Array(records.prefix(Self.maxRecords))
        }
        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: Keys.records)
        }
    }

    func loadRecords() -> [UsageRecord] {
        guard let data = defaults.data(forKey: Keys.records),
              let records = try? JSONDecoder().decode([UsageRecord].self, from: data) else {
            return []
        }
        return records.sorted { $0.weekStartDate > $1.weekStartDate }
    }

    // MARK: - Reward Ad (Secret Dialogue Unlock)

    var isSecretUnlocked: Bool {
        get { defaults.bool(forKey: Keys.secretUnlocked) }
        set { defaults.set(newValue, forKey: Keys.secretUnlocked) }
    }

    func resetSecretUnlock() {
        defaults.set(false, forKey: Keys.secretUnlocked)
    }

    // MARK: - Onboarding

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    // MARK: - Data Source

    var preferredDataSource: DataSource {
        get {
            guard let raw = defaults.string(forKey: Keys.preferredDataSource),
                  let source = DataSource(rawValue: raw) else {
                return .manual
            }
            return source
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.preferredDataSource) }
    }

    // MARK: - Screen Time (App Group)

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: SharedConstants.appGroupID)
    }

    var screenTimeLevel: TownLevel? {
        guard let raw = sharedDefaults?.integer(forKey: SharedConstants.currentLevelKey),
              raw > 0,
              let level = TownLevel(rawValue: raw) else {
            return nil
        }
        return level
    }

    // MARK: - Mayor Name

    var mayorName: String {
        get { defaults.string(forKey: Keys.mayorName) ?? "" }
        set { defaults.set(newValue, forKey: Keys.mayorName) }
    }

    // MARK: - Selected SNS

    var selectedSNSIds: [String] {
        get { defaults.stringArray(forKey: Keys.selectedSNS) ?? [] }
        set { defaults.set(newValue, forKey: Keys.selectedSNS) }
    }

    var selectedSNSPlatforms: [SNSPlatform] {
        let ids = Set(selectedSNSIds)
        return SNSPlatform.allPlatforms.filter { ids.contains($0.id) }
    }

    // MARK: - Reset

    func resetAllData() {
        defaults.removeObject(forKey: Keys.townState)
        defaults.removeObject(forKey: Keys.records)
        defaults.removeObject(forKey: Keys.secretUnlocked)
        defaults.removeObject(forKey: Keys.preferredDataSource)
    }
}
