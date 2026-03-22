import SwiftUI

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
        }
    }
}
