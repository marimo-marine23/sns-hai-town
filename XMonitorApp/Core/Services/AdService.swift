import Foundation
import SwiftUI

// MARK: - Protocols

protocol RewardAdProvider {
    func loadAd() async
    func showAd() async -> Bool
    var isAdReady: Bool { get }
}

protocol InterstitialAdProvider {
    func loadAd() async
    func showAd() async -> Bool
    var isAdReady: Bool { get }
}

// MARK: - Mock Providers

final class MockRewardAdProvider: RewardAdProvider {
    var isAdReady: Bool = true
    func loadAd() async {
        try? await Task.sleep(for: .milliseconds(300))
        isAdReady = true
    }
    func showAd() async -> Bool {
        try? await Task.sleep(for: .milliseconds(500))
        return true
    }
}

final class MockInterstitialAdProvider: InterstitialAdProvider {
    var isAdReady: Bool = true
    func loadAd() async {
        try? await Task.sleep(for: .milliseconds(300))
        isAdReady = true
    }
    func showAd() async -> Bool {
        try? await Task.sleep(for: .milliseconds(300))
        return true
    }
}

// MARK: - Ad Service

@MainActor
final class AdService: ObservableObject {
    static let shared = AdService()

    @Published var isRewardAdReady = false
    @Published var isInterstitialAdReady = false

    private var rewardProvider: RewardAdProvider = MockRewardAdProvider()
    private var interstitialProvider: InterstitialAdProvider = MockInterstitialAdProvider()

    func preloadAll() {
        Task {
            await rewardProvider.loadAd()
            isRewardAdReady = rewardProvider.isAdReady
        }
        Task {
            await interstitialProvider.loadAd()
            isInterstitialAdReady = interstitialProvider.isAdReady
        }
    }

    /// リワード広告を表示（裏セリフ用）
    func showRewardAd() async -> Bool {
        let result = await rewardProvider.showAd()
        if result {
            LocalStore.shared.isSecretUnlocked = true
        }
        // 次の広告をロード
        Task { await rewardProvider.loadAd(); isRewardAdReady = rewardProvider.isAdReady }
        return result
    }

    /// インタースティシャル広告を表示（シェア用）
    func showInterstitialAd() async -> Bool {
        guard interstitialProvider.isAdReady else { return true } // 未ロード時はスキップ
        let result = await interstitialProvider.showAd()
        Task { await interstitialProvider.loadAd(); isInterstitialAdReady = interstitialProvider.isAdReady }
        return result
    }
}

// MARK: - Banner Ad View (Mock)

struct BannerAdView: View {
    var body: some View {
        Text("AD")
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.2))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white.opacity(0.03))
    }
}

// MARK: - Share Sheet (UIActivityViewController wrapper)

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - AdMob Integration Templates
/*
 import GoogleMobileAds

 final class GoogleRewardAdProvider: RewardAdProvider {
     private var rewardedAd: GADRewardedAd?
     var isAdReady: Bool { rewardedAd != nil }

     func loadAd() async {
         do {
             rewardedAd = try await GADRewardedAd.load(
                 withAdUnitID: "ca-app-pub-XXXXX/YYYYY",
                 request: GADRequest()
             )
         } catch { print("Reward ad load failed: \(error)") }
     }

     func showAd() async -> Bool {
         guard let ad = rewardedAd else { return false }
         guard let rootVC = UIApplication.shared.connectedScenes
             .compactMap({ $0 as? UIWindowScene })
             .first?.windows.first?.rootViewController else { return false }
         return await withCheckedContinuation { cont in
             ad.present(fromRootViewController: rootVC) { cont.resume(returning: true) }
         }
     }
 }

 final class GoogleInterstitialAdProvider: InterstitialAdProvider {
     private var interstitialAd: GADInterstitialAd?
     var isAdReady: Bool { interstitialAd != nil }

     func loadAd() async {
         do {
             interstitialAd = try await GADInterstitialAd.load(
                 withAdUnitID: "ca-app-pub-XXXXX/ZZZZZ",
                 request: GADRequest()
             )
         } catch { print("Interstitial ad load failed: \(error)") }
     }

     func showAd() async -> Bool {
         guard let ad = interstitialAd else { return false }
         guard let rootVC = UIApplication.shared.connectedScenes
             .compactMap({ $0 as? UIWindowScene })
             .first?.windows.first?.rootViewController else { return false }
         ad.present(fromRootViewController: rootVC)
         return true
     }
 }

 // Usage: In AdService init, replace providers:
 // rewardProvider = GoogleRewardAdProvider()
 // interstitialProvider = GoogleInterstitialAdProvider()

 // Banner: Use UIViewRepresentable wrapping GADBannerView
 struct GoogleBannerAdView: UIViewRepresentable {
     func makeUIView(context: Context) -> GADBannerView {
         let banner = GADBannerView(adSize: GADAdSizeBanner)
         banner.adUnitID = "ca-app-pub-XXXXX/BBBBB"
         banner.rootViewController = UIApplication.shared.connectedScenes
             .compactMap({ $0 as? UIWindowScene })
             .first?.windows.first?.rootViewController
         banner.load(GADRequest())
         return banner
     }
     func updateUIView(_ uiView: GADBannerView, context: Context) {}
 }
 */
