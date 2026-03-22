import SwiftUI

/// 天気やエフェクトのオーバーレイ
struct EffectsOverlay: View {
    let level: TownLevel

    var body: some View {
        ZStack {
            switch level {
            case .paradise:
                RainbowEffect()
            case .prosperity:
                EmptyView()
            case .calm:
                EmptyView()
            case .stagnation:
                CloudsEffect()
            case .decline:
                RainEffect()
            case .ruins:
                DarknessEffect()
            case .extinction:
                MeteorEffect()
            case .reincarnation:
                ReincarnationEffect()
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Rainbow

struct RainbowEffect: View {
    var body: some View {
        GeometryReader { geo in
            Text("🌈")
                .font(.system(size: 40))
                .position(x: geo.size.width * 0.3, y: geo.size.height * 0.12)
        }
    }
}

// MARK: - Clouds

struct CloudsEffect: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<3, id: \.self) { i in
                Text("☁️")
                    .font(.system(size: 20))
                    .opacity(0.6)
                    .position(
                        x: geo.size.width * CGFloat(0.2 + Double(i) * 0.3),
                        y: geo.size.height * CGFloat(0.08 + Double(i) * 0.04)
                    )
            }
        }
    }
}

// MARK: - Rain

struct RainEffect: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<12, id: \.self) { i in
                Text("💧")
                    .font(.system(size: 8))
                    .opacity(0.4)
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: animate
                            ? geo.size.height
                            : CGFloat.random(in: 0...geo.size.height * 0.3)
                    )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }
}

// MARK: - Darkness

struct DarknessEffect: View {
    @State private var flicker = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)

            GeometryReader { geo in
                // ゆらゆら光るスマホの光
                Circle()
                    .fill(.blue.opacity(flicker ? 0.3 : 0.1))
                    .frame(width: 30, height: 30)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.6)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                flicker = true
            }
        }
    }
}

// MARK: - Meteor

struct MeteorEffect: View {
    @State private var streak = false

    var body: some View {
        GeometryReader { geo in
            Text("☄️")
                .font(.system(size: 24))
                .rotationEffect(.degrees(-30))
                .position(
                    x: streak ? geo.size.width * 0.7 : geo.size.width * 0.9,
                    y: streak ? geo.size.height * 0.25 : geo.size.height * 0.05
                )
                .opacity(streak ? 0 : 1)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 3).repeatForever(autoreverses: false)) {
                streak = true
            }
        }
    }
}

// MARK: - Reincarnation (転生エフェクト)

struct ReincarnationEffect: View {
    @State private var pulse = false
    @State private var sparkle = false

    var body: some View {
        ZStack {
            // 紫の神秘的なオーバーレイ
            Color(hex: "#2E0854").opacity(0.4)

            // 中央の光
            GeometryReader { geo in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(pulse ? 0.6 : 0.2), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: pulse ? 120 : 60
                        )
                    )
                    .frame(width: 240, height: 240)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)

                // 漂う✨
                let xPositions: [CGFloat] = [0.15, 0.35, 0.55, 0.75, 0.9]
                let yFactors: [CGFloat] = [0.5, 0.8, 0.3, 0.7, 0.5]
                ForEach(Array(zip(xPositions, yFactors).enumerated()), id: \.offset) { _, pair in
                    Text("✨")
                        .font(.system(size: 12))
                        .opacity(sparkle ? 1 : 0.3)
                        .position(
                            x: geo.size.width * pair.0,
                            y: geo.size.height * (sparkle ? 0.2 : 0.8) * pair.1
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever()) { pulse = true }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { sparkle = true }
        }
    }
}
