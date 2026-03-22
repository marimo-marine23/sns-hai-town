import SwiftUI

/// 使用時間の入力画面
struct UsageInputView: View {
    @ObservedObject var engine: TownEngine
    @Environment(\.dismiss) private var dismiss
    @State private var hours: Double
    @State private var showPreview = false

    init(engine: TownEngine) {
        self.engine = engine
        self._hours = State(initialValue: engine.townState.weeklyHours)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A2E").ignoresSafeArea()

                VStack(spacing: 24) {
                    // 説明
                    instructionSection

                    // スライダー
                    sliderSection

                    // プレビュー
                    previewSection

                    Spacer()

                    // 確定ボタン
                    confirmButton
                }
                .padding()
            }
            .navigationTitle("SNS使用時間を入力")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#1A1A2E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }

    // MARK: - Instruction

    private var instructionSection: some View {
        VStack(spacing: 8) {
            Text("設定 → スクリーンタイム → すべてのアクティビティを確認")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)

            Text("SNSの今週の合計使用時間を入力してください")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Slider

    private var sliderSection: some View {
        VStack(spacing: 12) {
            // 時間表示
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", hours))
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundStyle(levelColor)
                    .contentTransition(.numericText())
                Text("時間")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
            }

            // レベル表示
            HStack(spacing: 4) {
                Text(previewLevel.emoji)
                Text("Lv.\(previewLevel.rawValue) \(previewLevel.name)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(levelColor)
            }

            // スライダー
            VStack(spacing: 4) {
                Slider(value: $hours, in: 0...60, step: 0.5)
                    .tint(levelColor)

                HStack {
                    Text("0h")
                    Spacer()
                    Text("30h")
                    Spacer()
                    Text("60h")
                }
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.3))
            }

            // クイック入力
            HStack(spacing: 8) {
                ForEach([3.0, 7.0, 12.0, 18.0, 25.0, 35.0, 50.0], id: \.self) { h in
                    Button {
                        withAnimation(.spring(response: 0.3)) { hours = h }
                    } label: {
                        Text("\(Int(h))h")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(hours == h ? .black : .white.opacity(0.5))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(hours == h ? levelColor : Color.white.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        TownScene(level: previewLevel, dialogue: previewDialogue)
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
    }

    // MARK: - Confirm

    private var confirmButton: some View {
        Button {
            engine.updateHours(hours)
            engine.saveWeeklyRecord()
            dismiss()
        } label: {
            Text("この時間で確定する")
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(levelColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Helpers

    private var previewLevel: TownLevel {
        TownLevel.from(weeklyHours: hours)
    }

    private var previewDialogue: String {
        DialogueService.shared.randomDialogue(for: previewLevel)
    }

    private var levelColor: Color {
        Color(hex: previewLevel.accentColor)
    }
}
