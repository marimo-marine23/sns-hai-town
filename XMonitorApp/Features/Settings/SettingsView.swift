import SwiftUI

struct SettingsView: View {
    @ObservedObject var engine: TownEngine
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirm = false
    @State private var showOnboarding = false
    @State private var showSNSSelection = false
    @State private var nameInput: String = ""

    private let privacyPolicyURL = URL(string: "https://marimo-marine23.github.io/sns-hai-town/privacy-policy.html")!
    private let termsURL = URL(string: "https://marimo-marine23.github.io/sns-hai-town/terms.html")!
    private let supportURL = URL(string: "mailto:support@pipimoss.com")!

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A2E").ignoresSafeArea()

                List {
                    // 町長名
                    Section {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white.opacity(0.4))
                            TextField("名前を入力（任意）", text: $nameInput)
                                .onChange(of: nameInput) { newValue in
                                    engine.updateMayorName(newValue)
                                }
                        }
                        if !nameInput.isEmpty {
                            Text("表示: 「\(nameInput)のSNS廃タウン」")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    } header: {
                        Text("町長の名前")
                    } footer: {
                        Text("設定するとタイトルとシェア画像に反映されます")
                    }

                    // SNS選択
                    Section {
                        Button {
                            showSNSSelection = true
                        } label: {
                            HStack {
                                Label("トラッキング対象", systemImage: "app.badge.checkmark")
                                Spacer()
                                Text(engine.selectedSNSLabel)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .lineLimit(1)
                            }
                        }
                    } header: {
                        Text("SNS")
                    }

                    // データソース
                    Section {
                        HStack {
                            Label("データ取得方法", systemImage: "antenna.radiowaves.left.and.right")
                            Spacer()
                            Text(engine.dataSource == .screenTime ? "Screen Time" : "手動入力")
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        if engine.dataSource == .manual {
                            Button {
                                engine.switchToScreenTime()
                            } label: {
                                Label("Screen Timeに切り替え", systemImage: "arrow.triangle.2.circlepath")
                            }
                        } else {
                            Button {
                                engine.dataSource = .manual
                                LocalStore.shared.preferredDataSource = .manual
                            } label: {
                                Label("手動入力に切り替え", systemImage: "pencil.line")
                            }
                        }
                    } header: {
                        Text("データソース")
                    }

                    // その他
                    Section {
                        Button {
                            showOnboarding = true
                        } label: {
                            Label("使い方を見る", systemImage: "questionmark.circle")
                        }

                        Button(role: .destructive) {
                            showResetConfirm = true
                        } label: {
                            Label("データをリセット", systemImage: "trash")
                        }
                    } header: {
                        Text("その他")
                    }

                    // 法的情報
                    Section {
                        Link(destination: privacyPolicyURL) {
                            Label("プライバシーポリシー", systemImage: "hand.raised.fill")
                        }
                        Link(destination: termsURL) {
                            Label("利用規約", systemImage: "doc.text.fill")
                        }
                        Link(destination: supportURL) {
                            Label("お問い合わせ・サポート", systemImage: "envelope.fill")
                        }
                    } header: {
                        Text("法的情報")
                    }

                    // アプリ情報
                    Section {
                        HStack {
                            Text("バージョン")
                            Spacer()
                            Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        HStack {
                            Text("開発")
                            Spacer()
                            Text("PipiMoss")
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    } header: {
                        Text("アプリについて")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "#1A1A2E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .alert("データをリセット", isPresented: $showResetConfirm) {
                Button("リセット", role: .destructive) {
                    LocalStore.shared.resetAllData()
                    engine.updateHours(0)
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("すべての履歴と設定が削除されます。この操作は取り消せません。")
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(isPresented: $showOnboarding)
            }
            .sheet(isPresented: $showSNSSelection) {
                SNSSelectionView(engine: engine)
            }
            .onAppear {
                nameInput = engine.mayorName
            }
        }
    }
}
