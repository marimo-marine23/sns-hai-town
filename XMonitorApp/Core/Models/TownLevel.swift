import Foundation

enum TownLevel: Int, Codable, CaseIterable {
    case paradise = 1       // 楽園 0〜3h
    case prosperity = 2     // 繁栄 3〜7h
    case calm = 3           // 平穏 7〜12h
    case stagnation = 4     // 停滞 12〜18h
    case decline = 5        // 衰退 18〜25h
    case ruins = 6          // 廃墟 25〜35h
    case extinction = 7     // 消滅 35〜50h
    case reincarnation = 8  // 転生 50h〜（隠しレベル）

    var name: String {
        switch self {
        case .paradise: "楽園"
        case .prosperity: "繁栄"
        case .calm: "平穏"
        case .stagnation: "停滞"
        case .decline: "衰退"
        case .ruins: "廃墟"
        case .extinction: "消滅"
        case .reincarnation: "転生"
        }
    }

    var emoji: String {
        switch self {
        case .paradise: "🌈"
        case .prosperity: "☀️"
        case .calm: "⛅"
        case .stagnation: "☁️"
        case .decline: "🌧️"
        case .ruins: "🌑"
        case .extinction: "☄️"
        case .reincarnation: "🕊️"
        }
    }

    var hoursRange: String {
        switch self {
        case .paradise: "0〜3h"
        case .prosperity: "3〜7h"
        case .calm: "7〜12h"
        case .stagnation: "12〜18h"
        case .decline: "18〜25h"
        case .ruins: "25〜35h"
        case .extinction: "35〜50h"
        case .reincarnation: "50h〜"
        }
    }

    /// 隠しレベルかどうか
    var isHidden: Bool { self == .reincarnation }

    /// 週間使用時間（時間単位）からレベルを判定
    static func from(weeklyHours: Double) -> TownLevel {
        switch weeklyHours {
        case ..<3: return .paradise
        case ..<7: return .prosperity
        case ..<12: return .calm
        case ..<18: return .stagnation
        case ..<25: return .decline
        case ..<35: return .ruins
        case ..<50: return .extinction
        default: return .reincarnation
        }
    }

    /// レベルごとの街の色テーマ
    var skyColorTop: String {
        switch self {
        case .paradise: "#87CEEB"
        case .prosperity: "#5DADE2"
        case .calm: "#85929E"
        case .stagnation: "#616A6B"
        case .decline: "#4A4A4A"
        case .ruins: "#1C1C2E"
        case .extinction: "#0A0A0A"
        case .reincarnation: "#2E0854"
        }
    }

    var accentColor: String {
        switch self {
        case .paradise: "#2ECC71"
        case .prosperity: "#3498DB"
        case .calm: "#95A5A6"
        case .stagnation: "#F39C12"
        case .decline: "#E67E22"
        case .ruins: "#E74C3C"
        case .extinction: "#8E44AD"
        case .reincarnation: "#9B59B6"
        }
    }

    var sfSymbol: String {
        switch self {
        case .paradise: "sparkles"
        case .prosperity: "sun.max.fill"
        case .calm: "cloud.sun.fill"
        case .stagnation: "cloud.fill"
        case .decline: "cloud.rain.fill"
        case .ruins: "moon.fill"
        case .extinction: "flame.fill"
        case .reincarnation: "bird.fill"
        }
    }

    var groundColor: String {
        switch self {
        case .paradise: "#2ECC71"
        case .prosperity: "#27AE60"
        case .calm: "#A9B388"
        case .stagnation: "#8B7D6B"
        case .decline: "#6B5B4B"
        case .ruins: "#3B3B3B"
        case .extinction: "#1A1A1A"
        case .reincarnation: "#0D0D2B"
        }
    }
}
