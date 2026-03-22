import SwiftUI

struct SNSSelectionView: View {
    @ObservedObject var engine: TownEngine
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIds: Set<String> = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A2E").ignoresSafeArea()

                List {
                    // インストール済みSNS
                    let installed = SNSPlatform.installedPlatforms
                    if !installed.isEmpty {
                        Section {
                            ForEach(installed) { platform in
                                snsRow(platform)
                            }
                        } header: {
                            Text("インストール済み")
                        }
                    }

                    // 全SNS一覧
                    Section {
                        ForEach(SNSPlatform.allPlatforms) { platform in
                            if !platform.isInstalled {
                                snsRow(platform)
                            }
                        }
                    } header: {
                        Text(installed.isEmpty ? "SNSを選択" : "その他")
                    } footer: {
                        Text("選択したSNSの合計使用時間で街のレベルが決まります")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("SNS選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#1A1A2E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        let platforms = SNSPlatform.allPlatforms.filter { selectedIds.contains($0.id) }
                        engine.updateSelectedSNS(platforms)
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: "#1DA1F2"))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .onAppear {
                selectedIds = Set(engine.selectedSNS.map { $0.id })
            }
        }
    }

    private func snsRow(_ platform: SNSPlatform) -> some View {
        Button {
            if selectedIds.contains(platform.id) {
                selectedIds.remove(platform.id)
            } else {
                selectedIds.insert(platform.id)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: platform.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: platform.color))
                    .frame(width: 28)

                Text(platform.name)
                    .foregroundStyle(.white)

                if platform.isInstalled {
                    Text("検出済み")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.green.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                }

                Spacer()

                Image(systemName: selectedIds.contains(platform.id) ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(selectedIds.contains(platform.id) ? Color(hex: "#1DA1F2") : .white.opacity(0.2))
            }
        }
    }
}
