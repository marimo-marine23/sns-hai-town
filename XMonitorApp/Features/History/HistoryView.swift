import SwiftUI

/// 過去の記録一覧
struct HistoryView: View {
    @ObservedObject var engine: TownEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A2E").ignoresSafeArea()

                if engine.history().isEmpty {
                    emptyState
                } else {
                    recordsList
                }
            }
            .navigationTitle("街の歴史")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#1A1A2E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🏗️")
                .font(.system(size: 48))
            Text("まだ記録がありません")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            Text("使用時間を入力すると\nここに街の歴史が刻まれます")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
    }

    private var recordsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(engine.history()) { record in
                    RecordRow(record: record)
                }
            }
            .padding()
        }
    }
}

struct RecordRow: View {
    let record: UsageRecord

    var body: some View {
        HStack(spacing: 12) {
            // レベルアイコン
            VStack(spacing: 2) {
                Image(systemName: record.level.sfSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(levelColor(for: record.level))
                Text("Lv.\(record.level.rawValue)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .frame(width: 44)

            // 詳細
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(record.weekLabel)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(record.level.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(levelColor(for: record.level))
                }
                Text("「\(record.dialogue)」")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(2)
            }

            Spacer()

            // 使用時間
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f", record.weeklyHours))
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundStyle(levelColor(for: record.level))
                Text("時間")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func levelColor(for level: TownLevel) -> Color {
        Color(hex: level.accentColor)
    }
}
