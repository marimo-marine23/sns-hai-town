import SwiftUI

/// Xにシェアするための画像カード（1:1正方形 — Xタイムラインでクロップされない）
struct ShareCardView: View {
    @ObservedObject var engine: TownEngine

    private let cardSize: CGFloat = 400

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            // ヘッダー
            HStack(spacing: 6) {
                Text(engine.mayorName.isEmpty ? "今週のSNS廃タウン" : "\(engine.mayorName)のSNS廃タウン")
                    .font(.system(size: engine.mayorName.isEmpty ? 18 : 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Text(weekLabel)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)

            // 街の描画
            TownScene(
                level: engine.townState.level,
                dialogue: engine.currentDialogue,
                mayorName: engine.mayorName,
                isForShare: true
            )
            .frame(width: 360, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 20)

            // ステータス
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.4))
                        Text("SNS使用時間")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    if engine.hasExactTime {
                        Text("\(String(format: "%.0f", engine.townState.weeklyHours))時間")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundStyle(levelColor)
                    } else {
                        Text(engine.townState.level.hoursRange)
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundStyle(levelColor)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.white.opacity(0.4))
                        Text("街レベル")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    HStack(spacing: 4) {
                        Text("Lv.\(engine.townState.level.rawValue)")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundStyle(levelColor)
                        Text(engine.townState.level.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // 通常セリフ
            dialogueBubble(
                icon: "bubble.left.fill",
                iconColor: .white.opacity(0.5),
                text: engine.currentDialogue,
                textColor: .white
            )
            .padding(.top, 10)

            // 裏セリフ（解放済みの場合）
            if let secret = engine.secretDialogue {
                dialogueBubble(
                    icon: "eye.fill",
                    iconColor: .yellow.opacity(0.7),
                    text: secret,
                    textColor: .yellow.opacity(0.9),
                    bgColor: Color.yellow.opacity(0.06),
                    borderColor: Color.yellow.opacity(0.15)
                )
                .padding(.top, 4)
            }

            Spacer(minLength: 0)

            // フッター
            HStack {
                Text("#SNS廃タウン")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#1DA1F2"))
                Spacer()
                Text("by PipiMoss")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: cardSize, height: cardSize)
        .background(Color(hex: "#1A1A2E"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Dialogue Bubble

    private func dialogueBubble(
        icon: String,
        iconColor: Color,
        text: String,
        textColor: Color,
        bgColor: Color = Color.white.opacity(0.08),
        borderColor: Color? = nil
    ) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(iconColor)
                .padding(.top, 2)
            Text("「\(text)」")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(textColor)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(bgColor)
        .overlay {
            if let border = borderColor {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(border, lineWidth: 1)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private static let weekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d〜"
        return formatter
    }()

    private var weekLabel: String {
        Self.weekFormatter.string(from: engine.townState.weekStartDate)
    }

    private var levelColor: Color {
        Color(hex: engine.townState.level.accentColor)
    }
}
