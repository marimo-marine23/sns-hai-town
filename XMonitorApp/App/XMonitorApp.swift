import SwiftUI
import AppTrackingTransparency
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct XMonitorApp: App {
    @State private var showOnboarding = !LocalStore.shared.hasCompletedOnboarding

    var body: some Scene {
        WindowGroup {
            TownView()
                .preferredColorScheme(.dark)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView(isPresented: $showOnboarding)
                }
                .onFirstAppear {
                    requestTrackingAuthorization()
                }
        }
    }

    private func requestTrackingAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                print("[ATT] Authorization status: \(status.rawValue)")
                DispatchQueue.main.async {
                    startGoogleMobileAds()
                }
            }
        }
    }

    private func startGoogleMobileAds() {
        #if canImport(GoogleMobileAds)
        GADMobileAds.sharedInstance().start { _ in
            print("[AdMob] SDK initialized")
            DispatchQueue.main.async {
                AdService.shared.preloadAll()
            }
        }
        #else
        AdService.shared.preloadAll()
        #endif
    }
}

// MARK: - onFirstAppear Modifier

private struct OnFirstAppearModifier: ViewModifier {
    @State private var hasAppeared = false
    let action: () -> Void

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

extension View {
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(action: action))
    }
}
