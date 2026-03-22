import Foundation
import Combine

enum DataSource: String, Codable {
    case manual
    case screenTime
}

final class TownEngine: ObservableObject {
    @Published var townState: TownState
    @Published var currentDialogue: String = ""
    @Published var secretDialogue: String?
    @Published var dataSource: DataSource
    @Published var mayorName: String
    @Published var selectedSNS: [SNSPlatform]

    private let store = LocalStore.shared
    private let dialogueService = DialogueService.shared
    /// セリフはプロセス起動時に1回だけ決定するフラグ
    private var hasInitializedDialogue = false

    init() {
        self.townState = LocalStore.shared.loadTownState()
        self.dataSource = LocalStore.shared.preferredDataSource
        self.mayorName = LocalStore.shared.mayorName
        self.selectedSNS = LocalStore.shared.selectedSNSPlatforms
        refreshDialogue()
        hasInitializedDialogue = true
    }

    func updateHours(_ hours: Double) {
        townState.updateHours(hours)
        dataSource = .manual
        store.preferredDataSource = .manual
        // レベルが変わったらセリフも更新
        refreshDialogue()
        store.saveTownState(townState)
    }

    /// アプリ復帰時に呼ぶ：Screen Timeデータ確認のみ（セリフは変えない）
    func onAppBecameActive() {
        if dataSource == .screenTime {
            syncFromScreenTime()
        }
    }

    /// Screen Timeから自動取得モードに戻す
    func switchToScreenTime() {
        dataSource = .screenTime
        store.preferredDataSource = .screenTime
        syncFromScreenTime()
    }

    /// セリフ更新（レベル変更時 or 初回起動時のみ）
    func refreshDialogue() {
        currentDialogue = dialogueService.randomDialogue(for: townState.level)
        townState.currentDialogue = currentDialogue
        // 裏セリフもリセット
        secretDialogue = nil
    }

    func unlockSecretDialogue() -> String? {
        let text = dialogueService.secretDialogue(for: townState.level)
        secretDialogue = text
        return text
    }

    func updateMayorName(_ name: String) {
        mayorName = name
        store.mayorName = name
    }

    func updateSelectedSNS(_ platforms: [SNSPlatform]) {
        selectedSNS = platforms
        store.selectedSNSIds = platforms.map { $0.id }
    }

    /// タイトル表示用
    var townTitle: String {
        mayorName.isEmpty ? "SNS廃タウン" : "\(mayorName)のSNS廃タウン"
    }

    /// 選択中のSNS名一覧（表示用）
    var selectedSNSLabel: String {
        if selectedSNS.isEmpty { return "未選択" }
        return selectedSNS.map { $0.name }.joined(separator: "・")
    }

    func saveWeeklyRecord() {
        let record = UsageRecord(
            weekStartDate: townState.weekStartDate,
            weeklyHours: townState.weeklyHours,
            dialogue: currentDialogue
        )
        store.addRecord(record)
    }

    func history() -> [UsageRecord] {
        store.loadRecords()
    }

    /// 厳密な時間が取得できているか
    var hasExactTime: Bool {
        dataSource == .manual
    }

    // MARK: - Screen Time Sync

    private func syncFromScreenTime() {
        if let level = store.screenTimeLevel {
            let oldLevel = townState.level
            let hours = estimatedHours(for: level)
            townState.updateHours(hours)
            // レベルが変わった時だけセリフ更新
            if townState.level != oldLevel {
                refreshDialogue()
            }
            store.saveTownState(townState)
        }
    }

    private func estimatedHours(for level: TownLevel) -> Double {
        switch level {
        case .paradise: 0
        case .prosperity: 5
        case .calm: 9
        case .stagnation: 15
        case .decline: 21
        case .ruins: 30
        case .extinction: 42
        case .reincarnation: 55
        }
    }
}
