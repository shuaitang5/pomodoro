import XCTest
@testable import PomodoroTimer

@MainActor
final class PomodoroViewModelTests: XCTestCase {
    func testStartUpdatesVisibleState() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        let now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()

        XCTAssertEqual(viewModel.statusText, "Focus session in progress")
        XCTAssertEqual(viewModel.timerText, "00:10")
        XCTAssertFalse(viewModel.isStartEnabled)
        XCTAssertTrue(alerts.presentedAlerts.isEmpty)
        XCTAssertEqual(notifications.gentleSoundPlayCount, 0)
        XCTAssertEqual(doNotDisturb.enableCount, 0)
    }

    func testFocusCompletionTriggersBreakAlertAndNotification() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.breakMinutes = 5
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(10)
        viewModel.processTick()

        XCTAssertEqual(viewModel.statusText, "Break ready to start")
        XCTAssertEqual(viewModel.timerText, "00:05")
        XCTAssertEqual(alerts.presentedAlerts.first?.title, "Pomodoro complete")
        XCTAssertEqual(alerts.presentedAlerts.first?.message, "Time for a 5-minute break.")
        XCTAssertEqual(notifications.gentleSoundPlayCount, 1)
        XCTAssertEqual(doNotDisturb.disableCount, 0)
    }

    func testBreakCompletionReturnsToIdleAndAlertsUser() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(10)
        viewModel.processTick()
        alerts.acknowledgeLastAlert()
        now = now.addingTimeInterval(5)
        viewModel.processTick()

        XCTAssertEqual(viewModel.statusText, "Ready to focus")
        XCTAssertEqual(viewModel.timerText, "25:00")
        XCTAssertTrue(viewModel.isStartEnabled)
        XCTAssertEqual(alerts.presentedAlerts.last?.title, "Break complete")
        XCTAssertEqual(alerts.presentedAlerts.count, 2)
        XCTAssertEqual(notifications.gentleSoundPlayCount, 2)
        XCTAssertEqual(doNotDisturb.disableCount, 0)
    }

    func testResetReturnsToIdleWithoutTriggeringAlerts() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { Date(timeIntervalSince1970: 100) }
        )

        viewModel.start()
        viewModel.reset()

        XCTAssertEqual(viewModel.statusText, "Ready to focus")
        XCTAssertEqual(viewModel.timerText, "25:00")
        XCTAssertTrue(viewModel.isStartEnabled)
        XCTAssertTrue(alerts.presentedAlerts.isEmpty)
        XCTAssertEqual(notifications.gentleSoundPlayCount, 0)
        XCTAssertEqual(doNotDisturb.disableCount, 0)
    }

    func testDisablingSoundsKeepsPopupWithoutPlayingSound() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.soundsEnabled = false
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(10)
        viewModel.processTick()

        XCTAssertEqual(alerts.presentedAlerts.first?.title, "Pomodoro complete")
        XCTAssertEqual(viewModel.statusText, "Break ready to start")
        XCTAssertEqual(viewModel.timerText, "00:05")
        XCTAssertEqual(notifications.gentleSoundPlayCount, 0)
        XCTAssertEqual(doNotDisturb.disableCount, 0)
    }

    func testBreakWaitsForPopupAcknowledgementBeforeCountdownStarts() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(10)
        viewModel.processTick()

        now = now.addingTimeInterval(4)
        viewModel.processTick()

        XCTAssertEqual(viewModel.statusText, "Break ready to start")
        XCTAssertEqual(viewModel.timerText, "00:05")

        alerts.acknowledgeLastAlert()
        now = now.addingTimeInterval(2)
        viewModel.processTick()

        XCTAssertEqual(viewModel.statusText, "Take a 5-minute break")
        XCTAssertEqual(viewModel.timerText, "00:03")
        XCTAssertEqual(alerts.presentedAlerts.count, 1)
        XCTAssertEqual(notifications.gentleSoundPlayCount, 1)
        XCTAssertEqual(doNotDisturb.disableCount, 0)
    }

    func testChangingFocusMinutesWhileIdleUpdatesDisplayedTimerImmediately() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb
        )

        settings.focusMinutes = 20

        let expectedSeconds = Int(AppSettingsStore.focusDuration(forMinutes: 20))
        XCTAssertEqual(
            viewModel.timerText,
            String(format: "%02d:%02d", expectedSeconds / 60, expectedSeconds % 60)
        )
        XCTAssertEqual(viewModel.statusText, "Ready to focus")
        XCTAssertEqual(doNotDisturb.enableCount, 0)
    }

    func testResetAndBreakCompletionReturnToCurrentSettingsDuration() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.focusMinutes = 25
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 15 * 60, breakDuration: 5 * 60),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(25 * 60)
        viewModel.processTick()
        alerts.acknowledgeLastAlert()
        now = now.addingTimeInterval(5 * 60)
        viewModel.processTick()

        XCTAssertEqual(viewModel.timerText, "25:00")
        XCTAssertEqual(viewModel.statusText, "Ready to focus")

        settings.focusMinutes = 30
        viewModel.reset()

        XCTAssertEqual(viewModel.timerText, "30:00")
        XCTAssertEqual(viewModel.statusText, "Ready to focus")
        XCTAssertEqual(doNotDisturb.enableCount, 0)
    }

    func testStartingFocusWithDoNotDisturbEnabledRunsEnableShortcut() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.doNotDisturbDuringFocusEnabled = true
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { Date(timeIntervalSince1970: 100) }
        )

        viewModel.start()

        XCTAssertEqual(doNotDisturb.enableCount, 1)
        XCTAssertEqual(doNotDisturb.disableCount, 0)
    }

    func testEnablingDoNotDisturbWithoutSetupShowsAlertAndKeepsSettingOff() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        doNotDisturb.hasRequiredSetupResult = false
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { Date(timeIntervalSince1970: 100) }
        )

        viewModel.setDoNotDisturbDuringFocusEnabled(true)

        XCTAssertFalse(settings.doNotDisturbDuringFocusEnabled)
        XCTAssertEqual(doNotDisturb.hasRequiredSetupCount, 1)
        XCTAssertEqual(alerts.presentedAlerts.first?.title, "Set up Do Not Disturb")
        XCTAssertEqual(alerts.presentedAlerts.first?.message, doNotDisturb.setupInstructions)
    }

    func testFocusStillStartsNormallyWhenDoNotDisturbEnableFails() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.doNotDisturbDuringFocusEnabled = true
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        doNotDisturb.enableReturnValue = false
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { Date(timeIntervalSince1970: 100) }
        )

        viewModel.start()

        XCTAssertEqual(viewModel.statusText, "Focus session in progress")
        XCTAssertEqual(viewModel.timerText, "00:10")
        XCTAssertFalse(viewModel.isStartEnabled)
        XCTAssertFalse(settings.doNotDisturbDuringFocusEnabled)
        XCTAssertEqual(doNotDisturb.enableCount, 1)
        XCTAssertEqual(doNotDisturb.disableCount, 0)
        XCTAssertEqual(alerts.presentedAlerts.first?.title, "Set up Do Not Disturb")
        XCTAssertEqual(alerts.presentedAlerts.first?.message, doNotDisturb.setupInstructions)
    }

    func testFocusCompletionWithDoNotDisturbEnabledRunsDisableShortcut() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.doNotDisturbDuringFocusEnabled = true
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        var now = Date(timeIntervalSince1970: 100)
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { now }
        )

        viewModel.start()
        now = now.addingTimeInterval(10)
        viewModel.processTick()

        XCTAssertEqual(doNotDisturb.enableCount, 1)
        XCTAssertEqual(doNotDisturb.disableCount, 1)
    }

    func testResetDuringFocusWithDoNotDisturbEnabledRunsDisableShortcut() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.doNotDisturbDuringFocusEnabled = true
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { Date(timeIntervalSince1970: 100) }
        )

        viewModel.start()
        viewModel.reset()

        XCTAssertEqual(doNotDisturb.enableCount, 1)
        XCTAssertEqual(doNotDisturb.disableCount, 1)
    }

    func testTurningOffDoNotDisturbSettingMidFocusRunsDisableShortcut() {
        let defaults = makeUserDefaults()
        let settings = AppSettingsStore(userDefaults: defaults)
        settings.doNotDisturbDuringFocusEnabled = true
        let notifications = NotificationManagerSpy()
        let alerts = AlertPresenterSpy()
        let doNotDisturb = DoNotDisturbControllerSpy()
        let viewModel = PomodoroViewModel(
            settings: settings,
            notificationManager: notifications,
            alertPresenter: alerts,
            doNotDisturbController: doNotDisturb,
            engine: PomodoroEngine(focusDuration: 10, breakDuration: 5),
            now: { Date(timeIntervalSince1970: 100) }
        )

        viewModel.start()
        settings.doNotDisturbDuringFocusEnabled = false

        XCTAssertEqual(doNotDisturb.enableCount, 1)
        XCTAssertEqual(doNotDisturb.disableCount, 1)
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
    var gentleSoundPlayCount = 0

    func playGentleSound() {
        gentleSoundPlayCount += 1
    }
}

@MainActor
private final class AlertPresenterSpy: InAppAlertPresenting {
    struct PresentedAlert: Equatable {
        let title: String
        let message: String
    }

    var presentedAlerts: [PresentedAlert] = []
    private var dismissActions: [@MainActor () -> Void] = []

    func presentAlert(title: String, message: String, onDismiss: @escaping @MainActor () -> Void) {
        presentedAlerts.append(PresentedAlert(title: title, message: message))
        dismissActions.append(onDismiss)
    }

    func acknowledgeLastAlert() {
        guard let dismiss = dismissActions.popLast() else {
            XCTFail("No pending alert to acknowledge")
            return
        }

        dismiss()
    }
}

@MainActor
private final class DoNotDisturbControllerSpy: DoNotDisturbHandling {
    var setupInstructions = "Create the required Do Not Disturb shortcuts."
    var hasRequiredSetupResult = true
    var hasRequiredSetupCount = 0
    var enableCount = 0
    var disableCount = 0
    var enableReturnValue = true
    var disableReturnValue = true

    func hasRequiredSetup() -> Bool {
        hasRequiredSetupCount += 1
        return hasRequiredSetupResult
    }

    func enableDoNotDisturb() -> Bool {
        enableCount += 1
        return enableReturnValue
    }

    func disableDoNotDisturb() -> Bool {
        disableCount += 1
        return disableReturnValue
    }
}
