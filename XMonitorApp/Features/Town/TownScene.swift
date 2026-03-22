import SwiftUI

/// 街全体のシーンを描画するメインビュー
struct TownScene: View {
    let level: TownLevel
    let dialogue: String
    let mayorName: String
    let isForShare: Bool

    init(level: TownLevel, dialogue: String, mayorName: String = "", isForShare: Bool = false) {
        self.level = level
        self.dialogue = dialogue
        self.mayorName = mayorName
        self.isForShare = isForShare
    }

    var body: some View {
        ZStack {
            // 空
            SkyView(level: level)

            // 地面
            GroundView(level: level)

            // 建物群
            BuildingsView(level: level)

            // 住民
            ResidentsView(level: level)

            // エフェクト（天気など）
            EffectsOverlay(level: level)

            // 町長の名前（フルランダム配置）
            if !mayorName.isEmpty {
                NameGraffitiView(name: mayorName)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: isForShare ? 0 : 16))
    }

}

// MARK: - Name Graffiti (フルランダム配置)

struct NameGraffitiView: View {
    let name: String
    @State private var xRatio: CGFloat = 0.5
    @State private var yRatio: CGFloat = 0.35
    @State private var angle: Double = 0
    @State private var color: Color = .black

    private static let colors: [Color] = [
        .black,
        Color(hex: "#E74C3C"),
        Color(hex: "#2980B9"),
        Color(hex: "#E67E22"),
        Color(hex: "#8E44AD"),
        Color(hex: "#27AE60"),
        Color(hex: "#D81B60"),
        Color(hex: "#1DA1F2"),
    ]

    var body: some View {
        GeometryReader { geo in
            Text(name)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundStyle(color)
                .rotationEffect(.degrees(angle))
                .position(x: geo.size.width * xRatio, y: geo.size.height * yRatio)
        }
        .onAppear { randomize() }
    }

    private func randomize() {
        xRatio = CGFloat.random(in: 0.25...0.85)
        yRatio = CGFloat.random(in: 0.15...0.55)
        angle = Double.random(in: -18...18)
        color = Self.colors.randomElement()!
    }
}

// MARK: - Sky

struct SkyView: View {
    let level: TownLevel

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(skyGradient)
                .frame(height: geo.size.height)

            // 太陽 or 月
            celestialBody
                .position(x: geo.size.width * 0.8, y: geo.size.height * 0.15)
        }
    }

    private var skyGradient: LinearGradient {
        switch level {
        case .paradise:
            LinearGradient(colors: [Color(hex: "#4FC3F7"), Color(hex: "#81D4FA")],
                           startPoint: .top, endPoint: .bottom)
        case .prosperity:
            LinearGradient(colors: [Color(hex: "#42A5F5"), Color(hex: "#90CAF9")],
                           startPoint: .top, endPoint: .bottom)
        case .calm:
            LinearGradient(colors: [Color(hex: "#90A4AE"), Color(hex: "#B0BEC5")],
                           startPoint: .top, endPoint: .bottom)
        case .stagnation:
            LinearGradient(colors: [Color(hex: "#78909C"), Color(hex: "#90A4AE")],
                           startPoint: .top, endPoint: .bottom)
        case .decline:
            LinearGradient(colors: [Color(hex: "#546E7A"), Color(hex: "#607D8B")],
                           startPoint: .top, endPoint: .bottom)
        case .ruins:
            LinearGradient(colors: [Color(hex: "#1A1A2E"), Color(hex: "#16213E")],
                           startPoint: .top, endPoint: .bottom)
        case .extinction:
            LinearGradient(colors: [Color(hex: "#0D0D0D"), Color(hex: "#1A1A1A")],
                           startPoint: .top, endPoint: .bottom)
        case .reincarnation:
            LinearGradient(colors: [Color(hex: "#1A0033"), Color(hex: "#2E0854"), Color(hex: "#0D0D2B")],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    @ViewBuilder
    private var celestialBody: some View {
        switch level {
        case .paradise:
            ZStack {
                Circle().fill(.yellow.opacity(0.3)).frame(width: 60, height: 60)
                Text("☀️").font(.system(size: 36))
            }
        case .prosperity:
            Text("☀️").font(.system(size: 32))
        case .calm:
            Text("⛅").font(.system(size: 30))
        case .stagnation:
            Text("☁️").font(.system(size: 28))
        case .decline:
            Text("🌧️").font(.system(size: 28))
        case .ruins:
            Text("🌑").font(.system(size: 28))
        case .extinction:
            Text("☄️").font(.system(size: 32))
        case .reincarnation:
            Text("🕊️").font(.system(size: 36))
        }
    }
}

// MARK: - Ground

struct GroundView: View {
    let level: TownLevel

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()
                // 道路
                Rectangle()
                    .fill(roadColor)
                    .frame(height: 12)
                    .overlay(roadMarkings(width: geo.size.width))
                // 地面
                Rectangle()
                    .fill(groundGradient)
                    .frame(height: geo.size.height * 0.2)
            }
        }
    }

    private var roadColor: Color {
        level.rawValue >= 6 ? Color(hex: "#2C2C2C") : Color(hex: "#555555")
    }

    private var groundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: level.groundColor), Color(hex: level.groundColor).opacity(0.8)],
            startPoint: .top, endPoint: .bottom
        )
    }

    @ViewBuilder
    private func roadMarkings(width: CGFloat) -> some View {
        if level.rawValue <= 5 {
            HStack(spacing: 16) {
                ForEach(0..<Int(width / 24), id: \.self) { _ in
                    Rectangle()
                        .fill(.yellow.opacity(level.rawValue <= 3 ? 0.8 : 0.3))
                        .frame(width: 10, height: 2)
                }
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
