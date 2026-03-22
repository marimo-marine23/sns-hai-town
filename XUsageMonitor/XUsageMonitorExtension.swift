#if canImport(DeviceActivity)
import DeviceActivity
import Foundation

/// X(Twitter)の使用時間を監視するDeviceActivityMonitor Extension
///
/// 閾値を超えた時にApp Group経由でメインアプリにレベルを通知する。
/// このExtensionは独立プロセスで動作するため、メインアプリが閉じていても監視を継続する。
class XUsageMonitorExtension: DeviceActivityMonitor {

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.yourname.xmonitor")
    }

    /// 閾値を超えた時に呼ばれる
    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        // イベント名からレベルを判定してApp Groupに書き込み
        let thresholds: [String: Int] = [
            "level2": 2,
            "level3": 3,
            "level4": 4,
            "level5": 5,
            "level6": 6,
            "level7": 7,
        ]

        if let level = thresholds[event.rawValue] {
            sharedDefaults?.set(level, forKey: "currentLevel")
        }
    }

    /// 監視期間開始時（週の始まり）にレベルをリセット
    override func intervalDidStart(for activity: DeviceActivityName) {
        sharedDefaults?.set(1, forKey: "currentLevel")
    }

    /// 監視期間終了時
    override func intervalDidEnd(for activity: DeviceActivityName) {
        // 必要に応じて週報データの保存等
    }
}
#endif
