import SwiftUI
import UIKit

struct SNSPlatform: Identifiable, Codable, Hashable {
    let id: String          // 内部ID
    let name: String        // 表示名
    let urlScheme: String?  // canOpenURL用（nilならスキーム検出不可）
    let icon: String        // SF Symbol名
    let color: String       // アクセントカラー hex

    /// 端末にインストールされているか確認
    var isInstalled: Bool {
        guard let scheme = urlScheme,
              let url = URL(string: "\(scheme)://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    static let allPlatforms: [SNSPlatform] = [
        .init(id: "x",         name: "X (旧Twitter)",  urlScheme: "twitter",   icon: "bubble.left.and.text.bubble.right", color: "#1DA1F2"),
        .init(id: "instagram", name: "Instagram",       urlScheme: "instagram", icon: "camera",                            color: "#E1306C"),
        .init(id: "tiktok",    name: "TikTok",          urlScheme: "tiktok",    icon: "music.note",                        color: "#010101"),
        .init(id: "youtube",   name: "YouTube",         urlScheme: "youtube",   icon: "play.rectangle.fill",               color: "#FF0000"),
        .init(id: "facebook",  name: "Facebook",        urlScheme: "fb",        icon: "person.2.fill",                     color: "#1877F2"),
        .init(id: "threads",   name: "Threads",         urlScheme: "threads",   icon: "at",                                color: "#000000"),
        .init(id: "line",      name: "LINE",            urlScheme: "line",      icon: "message.fill",                      color: "#06C755"),
        .init(id: "reddit",    name: "Reddit",          urlScheme: "reddit",    icon: "text.bubble",                       color: "#FF4500"),
        .init(id: "snapchat",  name: "Snapchat",        urlScheme: "snapchat",  icon: "camera.viewfinder",                 color: "#FFFC00"),
        .init(id: "discord",   name: "Discord",         urlScheme: "discord",   icon: "headphones",                        color: "#5865F2"),
    ]

    /// インストール済みのプラットフォームのみ返す
    static var installedPlatforms: [SNSPlatform] {
        allPlatforms.filter { $0.isInstalled }
    }
}
