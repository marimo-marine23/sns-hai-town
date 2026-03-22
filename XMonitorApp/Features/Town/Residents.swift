import SwiftUI

/// レベルに応じた住民を描画（位置ランダム）
struct ResidentsView: View {
    let level: TownLevel
    @State private var positions: [(CGFloat, CGFloat)] = []

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(residents.enumerated()), id: \.offset) { i, resident in
                if i < positions.count {
                    Text(resident)
                        .font(.system(size: 20))
                        .position(
                            x: geo.size.width * positions[i].0,
                            y: geo.size.height * positions[i].1
                        )
                }
            }
        }
        .onAppear { generatePositions() }
    }

    private func generatePositions() {
        positions = residents.map { _ in
            (CGFloat.random(in: 0.10...0.90), CGFloat.random(in: 0.72...0.82))
        }
    }

    private var residents: [String] {
        switch level {
        case .paradise:
            ["👨‍👩‍👧‍👦", "🧑‍🌾", "🐕", "👶", "🧑‍🍳"]
        case .prosperity:
            ["👫", "🧑‍🍳", "👶", "🐕"]
        case .calm:
            ["🧑", "🐈", "🚶"]
        case .stagnation:
            ["🧓", "🐈"]
        case .decline:
            ["🐈", "🐈"]
        case .ruins:
            ["🐈‍⬛", "👻"]
        case .extinction:
            ["📱"]
        case .reincarnation:
            ["🕊️", "✨"]
        }
    }
}

/// 装飾要素（位置ランダム）
struct DecorationsView: View {
    let level: TownLevel
    @State private var positions: [(CGFloat, CGFloat)] = []

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(decorations.enumerated()), id: \.offset) { i, deco in
                if i < positions.count {
                    Text(deco)
                        .font(.system(size: 14))
                        .position(
                            x: geo.size.width * positions[i].0,
                            y: geo.size.height * positions[i].1
                        )
                }
            }
        }
        .onAppear { generatePositions() }
    }

    private func generatePositions() {
        positions = decorations.map { _ in
            (CGFloat.random(in: 0.08...0.92), CGFloat.random(in: 0.84...0.93))
        }
    }

    private var decorations: [String] {
        switch level {
        case .paradise:
            ["💐", "🌷", "⛲", "🌻", "💐", "🌸"]
        case .prosperity:
            ["🌷", "⛲", "🌻"]
        case .calm:
            ["🌱", "🌱"]
        case .stagnation:
            ["🍂"]
        case .decline:
            ["🍂", "🍂", "🕸️"]
        case .ruins:
            ["🕸️", "🍂", "🪦"]
        case .extinction:
            ["🦴"]
        case .reincarnation:
            ["🌌"]
        }
    }
}
