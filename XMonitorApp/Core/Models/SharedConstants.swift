import Foundation

enum SharedConstants {
    static let appGroupID = "group.com.pipimoss.sns-hai-town"
    static let currentLevelKey = "currentLevel"

    /// DeviceActivityMonitor の閾値設定
    static let thresholds: [(eventName: String, hours: Int, level: Int)] = [
        ("level2", 3, 2),
        ("level3", 7, 3),
        ("level4", 12, 4),
        ("level5", 18, 5),
        ("level6", 25, 6),
        ("level7", 35, 7),
        ("level8", 50, 8),
    ]
}
