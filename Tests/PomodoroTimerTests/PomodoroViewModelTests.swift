import XCTest
@testable import PomodoroTimer

@MainActor
final class PomodoroViewModelTests: XCTestCase {
    func testStartUpdatesVisibleState() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        let notifications = NotificationManagerSpy()
        let now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()

        XCTAssertEqual(viewModel.statusText, "Focus session in progress")
        XCTAssertEqual(viewModel.timerText, "00:10")
        XCTAssertFalse(viewModel.isStartEnabled)
        XCTAssertEqual(notifications.authorizationRequests, 1)
    }

    func testFocusCompletionTriggersBreakAlertAndNotification() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.breakMinutes = 5
        let notifications = NotificationManagerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(10)
        viewModel.processTick()

        XCTAssertEqual(viewModel.statusText, "Take a 5-minute break")
        XCTAssertEqual(viewModel.timerText, "00:05")
        XCTAssertEqual(viewModel.activeAlert?.title, "Pomodoro complete")
        XCTAssertEqual(viewModel.activeAlert?.message, "Time for a 5-minute break.")
        XCTAssertEqual(notifications.deliveredNotifications.count, 1)
        XCTAssertEqual(notifications.deliveredNotifications.first?.title, "Pomodoro complete")
        XCTAssertEqual(notifications.deliveredNotifications.first?.message, "Time for a 5-minute break.")
        XCTAssertEqual(notifications.gentleSoundPlayCount, 1)
    }

    func testBreakCompletionReturnsToIdleAndAlertsUser() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        let notifications = NotificationManagerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(10)
        viewModel.processTick()
        now = now.addingTimeInterval(5)
        viewModel.processTick()

        XCTAssertEqual(viewModel.statusText, "Ready to focus")
        XCTAssertEqual(viewModel.timerText, "25:00")
        XCTAssertTrue(viewModel.isStartEnabled)
        XCTAssertEqual(viewModel.activeAlert?.title, "Break complete")
        XCTAssertEqual(notifications.deliveredNotifications.count, 2)
        XCTAssertEqual(notifications.deliveredNotifications.last?.title, "Break complete")
    }

    func testResetReturnsToIdleWithoutTriggeringAlerts() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        let notifications = NotificationManagerSpy()
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { Date(timeIntervalSince1970: 100) }
        )

        viewModel.start()
        viewModel.reset()

        XCTAssertEqual(viewModel.statusText, "Ready to focus")
        XCTAssertEqual(viewModel.timerText, "25:00")
        XCTAssertTrue(viewModel.isStartEnabled)
        XCTAssertNil(viewModel.activeAlert)
        XCTAssertTrue(notifications.deliveredNotifications.isEmpty)
    }

    func testDisablingInAppAlertsSkipsPopupButStillDeliversNotification() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.inAppAlertsEnabled = false
        let notifications = NotificationManagerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(10)
        viewModel.processTick()

        XCTAssertNil(viewModel.activeAlert)
        XCTAssertEqual(notifications.deliveredNotifications.count, 1)
    }

    func testResetAndBreakCompletionReturnToCurrentSettingsDuration() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.focusMinutes = 25
        let notifications = NotificationManagerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            engine: PomodoroEngine(focusDuration: 15 * 60, breakDuration: 5 * 60),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(25 * 60)
        viewModel.processTick()
        now = now.addingTimeInterval(5 * 60)
        viewModel.processTick()

        XCTAssertEqual(viewModel.timerText, "25:00")
        XCTAssertEqual(viewModel.statusText, "Ready to focus")

        settings.focusMinutes = 30
        viewModel.reset()

        XCTAssertEqual(viewModel.timerText, "30:00")
        XCTAssertEqual(viewModel.statusText, "Ready to focus")
    }

    private func makeUserDefaults() -> UserDefaults {
        let suiteName = "PomodoroViewModelTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}

@MainActor
private final class NotificationManagerSpy: NotificationHandling {
    struct DeliveredNotification: Equatable {
        let title: String
        let message: String
        let playSound: Bool
    }

    var authorizationRequests = 0
    var deliveredNotifications: [DeliveredNotification] = []
    var gentleSoundPlayCount = 0

    func requestAuthorizationIfNeeded() {
        authorizationRequests += 1
    }

    func deliverNotification(title: String, message: String, playSound: Bool) {
        deliveredNotifications.append(
            DeliveredNotification(title: title, message: message, playSound: playSound)
        )
        if playSound {
            playGentleSound()
        }
    }

    func playGentleSound() {
        gentleSoundPlayCount += 1
    }
}
