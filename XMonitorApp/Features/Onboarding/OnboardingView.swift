import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @State private var nameInput = ""

    var body: some View {
        ZStack {
            Color(hex: "#1A1A2E").ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    howItWorksPage.tag(1)
                    getStartedPage.tag(2)
                    namePage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "building.2.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color(hex: "#1DA1F2"))

            Text("SNS廃タウンへ\nようこそ")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("あなたはこの街の町長です。\nでもSNSを見すぎると…\n街がどんどん廃れていきます。")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            nextButton { currentPage = 1 }
        }
        .padding(32)
    }

    // MARK: - Page 2: How It Works

    private var howItWorksPage: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("8段階で変化する街")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            VStack(spacing: 6) {
                ForEach(TownLevel.allCases, id: \.rawValue) { level in
                    levelRow(level)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            HStack(spacing: 4) {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.4))
                Text("住民たちが毒舌であなたを評価します")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            nextButton { currentPage = 2 }
        }
        .padding(32)
    }

    // MARK: - Page 3: Get Started

    private var getStartedPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "iphone.gen3")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: "#1DA1F2"))

            Text("使い方")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 16) {
                stepRow(icon: "clock.fill", text: "iPhoneの「設定」→「スクリーンタイム」で\nSNSの使用時間を確認")
                stepRow(icon: "slider.horizontal.3", text: "このアプリに時間を入力")
                stepRow(icon: "square.and.arrow.up.fill", text: "街の変化を楽しんで\nスクショをXでシェア！")
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()

            nextButton { currentPage = 3 }
        }
        .padding(32)
    }

    // MARK: - Page 4: Name Input

    private var namePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: "#1DA1F2"))

            Text("町長の名前")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("街の中やシェア画像に表示されます")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))

            TextField("名前を入力", text: $nameInput)
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)

            if !nameInput.isEmpty {
                Text("\(nameInput)のSNS廃タウン")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            Button {
                LocalStore.shared.mayorName = nameInput
                LocalStore.shared.hasCompletedOnboarding = true
                isPresented = false
            } label: {
                Text("はじめる")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#1DA1F2"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                LocalStore.shared.mayorName = ""
                LocalStore.shared.hasCompletedOnboarding = true
                isPresented = false
            } label: {
                Text("スキップ")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(32)
    }

    // MARK: - Components

    private func levelRow(_ level: TownLevel) -> some View {
        HStack(spacing: 8) {
            Image(systemName: levelSFSymbol(for: level))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(levelColor(for: level))
                .frame(width: 24)
            Text("Lv.\(level.rawValue)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.yellow)
                .frame(width: 32)
            Text(level.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, alignment: .leading)
            Text(level.hoursRange)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
            Spacer()
            if level.isHidden {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 10))
                    .foregroundStyle(.purple.opacity(0.5))
            }
        }
    }

    private func stepRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: "#1DA1F2"))
                .frame(width: 28)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(3)
        }
    }

    private func nextButton(action: @escaping () -> Void) -> some View {
        Button {
            withAnimation { action() }
        } label: {
            HStack(spacing: 6) {
                Text("次へ")
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.15))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Helpers

    private func levelSFSymbol(for level: TownLevel) -> String {
        level.sfSymbol
    }

    private func levelColor(for level: TownLevel) -> Color {
        Color(hex: level.accentColor)
    }
}
