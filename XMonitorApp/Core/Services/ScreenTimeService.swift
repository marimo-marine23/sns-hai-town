import Foundation

#if canImport(FamilyControls)
import FamilyControls
import DeviceActivity
#endif

final class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()

    enum AuthorizationStatus {
        case notDetermined
        case approved
        case denied
    }

    @Published var authStatus: AuthorizationStatus = .notDetermined

    /// Family Controls の認可をリクエスト
    func requestAuthorization() async -> Bool {
        #if canImport(FamilyControls)
        let center = AuthorizationCenter.shared
        do {
            try await center.requestAuthorization(for: .individual)
            await MainActor.run { authStatus = .approved }
            return true
        } catch {
            await MainActor.run { authStatus = .denied }
            return false
        }
        #else
        // Simulator fallback
        await MainActor.run { authStatus = .denied }
        return false
        #endif
    }

    /// DeviceActivity の閾値監視を開始
    func setupMonitoring() {
        #if canImport(FamilyControls)
        let center = DeviceActivityCenter()

        // 週間スケジュール（月曜0時〜日曜23:59）
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, weekday: 2),
            intervalEnd: DateComponents(hour: 23, minute: 59, weekday: 1),
            repeats: true
        )

        // 各レベルの閾値イベント
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        for threshold in SharedConstants.thresholds {
            events[DeviceActivityEvent.Name(threshold.eventName)] = DeviceActivityEvent(
                threshold: DateComponents(hour: threshold.hours)
            )
        }

        do {
            try center.startMonitoring(
                DeviceActivityName("xWeeklyUsage"),
                during: schedule,
                events: events
            )
        } catch {
            print("Failed to start monitoring: \(error)")
        }
        #endif
    }

    /// 監視を停止
    func stopMonitoring() {
        #if canImport(FamilyControls)
        let center = DeviceActivityCenter()
        center.stopMonitoring([DeviceActivityName("xWeeklyUsage")])
        #endif
    }
}
