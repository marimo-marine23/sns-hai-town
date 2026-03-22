import Foundation

struct DialogueData: Codable {
    let normal: [String]
    let secret: [String]
}

final class DialogueService {
    static let shared = DialogueService()

    private var dialogues: [String: DialogueData] = [:]
    private var lastShown: [Int: String] = [:]

    private init() {
        loadDialogues()
    }

    private func loadDialogues() {
        guard let url = Bundle.main.url(forResource: "dialogues", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: DialogueData].self, from: data) else {
            return
        }
        dialogues = decoded
    }

    /// 通常セリフをランダムに1つ返す（前回と同じにならないようシャッフル）
    func randomDialogue(for level: TownLevel) -> String {
        let key = String(level.rawValue)
        guard let pool = dialogues[key]?.normal, !pool.isEmpty else {
            return "……"
        }
        var candidate = pool.randomElement()!
        // 前回と同じなら再抽選（プールが2以上の場合）
        if pool.count > 1, candidate == lastShown[level.rawValue] {
            candidate = pool.filter { $0 != candidate }.randomElement() ?? candidate
        }
        lastShown[level.rawValue] = candidate
        return candidate
    }

    /// シークレットセリフ（リワード広告用）
    func secretDialogue(for level: TownLevel) -> String? {
        let key = String(level.rawValue)
        return dialogues[key]?.secret.randomElement()
    }

    /// 指定レベルの通常セリフ全件
    func allDialogues(for level: TownLevel) -> [String] {
        let key = String(level.rawValue)
        return dialogues[key]?.normal ?? []
    }
}
