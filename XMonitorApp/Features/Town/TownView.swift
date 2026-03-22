import SwiftUI

/// メイン画面：街の表示 + セリフ + 操作
struct TownView: View {
    @StateObject private var engine = TownEngine()
    @ObservedObject private var adService = AdService.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var showInput = false
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    @State private var isSecretVisible = false
    @State private var copiedToast = false
    @State private var toastMessage = ""
    @State private var imageSaver: ImageSaver?

    var body: some View {
        ZStack {
            Color(hex: "#1A1A2E").ignoresSafeArea()

            VStack(spacing: 0) {
                BannerAdView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        townSection
                        dialogueSection
                        actionSection
                    }
                    .padding(.horizontal)
                }

                BannerAdView()
            }

            if copiedToast {
                toastOverlay
            }
        }
        .onChange(of: scenePhase) { [scenePhase] newPhase in
            if newPhase == .active {
                engine.onAppBecameActive()
            }
        }
        .onAppear {
            adService.preloadAll()
        }
        .sheet(isPresented: $showInput) {
            UsageInputView(engine: engine)
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(engine: engine)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(engine: engine)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(engine.townTitle)
                    .font(.system(size: engine.mayorName.isEmpty ? 22 : 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                HStack(spacing: 6) {
                    Text("Lv.\(engine.townState.level.rawValue)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.yellow)
                    Text(engine.townState.level.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.trailing, 8)
            Button { showHistory = true } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Town

    private var townSection: some View {
        TownScene(level: engine.townState.level, dialogue: engine.currentDialogue, mayorName: engine.mayorName)
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
    }

    // MARK: - Dialogue

    private var dialogueSection: some View {
        VStack(spacing: 8) {
            // 住民のセリフ
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 2)
                Text("「\(engine.currentDialogue)」")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 裏セリフ（インライン表示）
            if isSecretVisible, let secret = engine.secretDialogue {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.yellow.opacity(0.7))
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("「\(secret)」")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.yellow.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isSecretVisible = false
                                engine.secretDialogue = nil
                            }
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("閉じる")
                                    .font(.system(size: 11))
                            }
                            .foregroundStyle(.white.opacity(0.3))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.yellow.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.15), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // 裏セリフボタン（非表示時のみ）
            if !isSecretVisible {
                Button {
                    Task {
                        let rewarded = await adService.showRewardAd()
                        if rewarded {
                            _ = engine.unlockSecretDialogue()
                            withAnimation(.spring(response: 0.4)) { isSecretVisible = true }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11))
                        Text("裏セリフを見る")
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.yellow.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: - Actions

    private var actionSection: some View {
        VStack(spacing: 10) {
            Button { showInput = true } label: {
                HStack {
                    Image(systemName: "clock.badge.questionmark")
                    Text("今週のSNS使用時間を入力")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "#1DA1F2"))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            HStack(spacing: 10) {
                Button {
                    Task {
                        _ = await adService.showInterstitialAd()
                        copyShareImage()
                    }
                } label: {
                    shareButtonLabel(icon: "doc.on.doc", text: "画像コピー")
                }

                Button {
                    Task {
                        _ = await adService.showInterstitialAd()
                        saveShareImage()
                    }
                } label: {
                    shareButtonLabel(icon: "square.and.arrow.down", text: "画像保存")
                }

                Button {
                    Task {
                        _ = await adService.showInterstitialAd()
                        openShareSheet()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("シェア")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#1DA1F2").opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            // 使用時間 or 時間枠
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                if engine.hasExactTime {
                    Text("今週のSNS合計: \(String(format: "%.1f", engine.townState.weeklyHours))時間")
                } else {
                    Text("推定使用時間帯: \(engine.townState.level.hoursRange)")
                }
                if engine.dataSource == .screenTime {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 9))
                }
            }
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundStyle(.white.opacity(0.3))
            .padding(.bottom, 8)
        }
    }

    private func shareButtonLabel(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
                .font(.system(size: 13, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Toast

    private var toastOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                Text(toastMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.8))
            .clipShape(Capsule())
            .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { copiedToast = false }
            }
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation { copiedToast = true }
    }

    // MARK: - Share Image

    @MainActor
    private func renderShareUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(engine: engine))
        renderer.scale = 3.0
        return renderer.uiImage
    }

    @MainActor
    private func copyShareImage() {
        if let uiImage = renderShareUIImage() {
            UIPasteboard.general.image = uiImage
            showToast("クリップボードにコピーしました")
        }
    }

    @MainActor
    private func saveShareImage() {
        guard let uiImage = renderShareUIImage() else { return }
        let saver = ImageSaver { success in
            showToast(success ? "カメラロールに保存しました" : "保存に失敗しました")
        }
        // ImageSaverはコールバックまで保持する必要がある
        self.imageSaver = saver
        UIImageWriteToSavedPhotosAlbum(uiImage, saver, #selector(ImageSaver.completed(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @MainActor
    private func openShareSheet() {
        shareImage = renderShareUIImage()
        showShareSheet = true
    }
}

// MARK: - Image Save Helper

final class ImageSaver: NSObject {
    private let completion: (Bool) -> Void

    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }

    @objc func completed(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completion(error == nil)
    }
}
