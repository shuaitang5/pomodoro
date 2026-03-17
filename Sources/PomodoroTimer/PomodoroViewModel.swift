import Combine
import Foundation

struct PomodoroAlertContent: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
final class PomodoroViewModel: ObservableObject {
    @Published private(set) var phase: PomodoroPhase
    @Published private(set) var remainingSeconds: Int
    @Published var activeAlert: PomodoroAlertContent?

    private var engine: PomodoroEngine
    private var timer: Timer?
    private let now: () -> Date
    private let settings: AppSettingsStore
    private let notificationManager: NotificationHandling
    private var cancellables = Set<AnyCancellable>()

    init(
        settings: AppSettingsStore,
        notificationManager: NotificationHandling = NotificationManager(),
        engine: PomodoroEngine? = nil,
        now: @escaping () -> Date = Date.init
    ) {
        self.settings = settings
        self.notificationManager = notificationManager
        let configuredEngine = engine ?? PomodoroEngine(
            focusDuration: settings.focusDuration,
            breakDuration: settings.breakDuration
        )
        self.engine = configuredEngine
        self.phase = configuredEngine.phase
        self.remainingSeconds = configuredEngine.remainingSeconds
        self.now = now

        settings.$focusMinutes
            .combineLatest(settings.$breakMinutes)
            .dropFirst()
            .sink { [weak self] focusMinutes, breakMinutes in
                guard let self else {
                    return
                }

                self.engine.updateDurations(
                    focusDuration: TimeInterval(focusMinutes * 60),
                    breakDuration: TimeInterval(breakMinutes * 60)
                )
                self.syncFromEngine()
            }
            .store(in: &cancellables)

        settings.$notificationsEnabled
            .sink { [weak self] isEnabled in
                guard isEnabled else {
                    return
                }

                self?.notificationManager.requestAuthorizationIfNeeded()
            }
            .store(in: &cancellables)
    }

    var timerText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var statusText: String {
        switch phase {
        case .idle:
            return "Ready to focus"
        case .focusRunning:
            return "Focus session in progress"
        case .breakRunning:
            return "Take a 5-minute break"
        }
    }

    var isStartEnabled: Bool {
        phase == .idle
    }

    func start() {
        guard phase == .idle else {
            return
        }

        engine.start(now: now())
        syncFromEngine()
        startTimer()
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        syncEngineDurationsToSettings()
        engine.reset()
        syncFromEngine()
    }

    func processTick() {
        let transition = engine.tick(now: now())
        syncFromEngine()

        handleTransition(transition)

        if transition == .breakCompleted {
            timer?.invalidate()
            timer = nil
            syncEngineDurationsToSettings()
            syncFromEngine()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.processTick()
            }
        }
    }

    private func syncFromEngine() {
        phase = engine.phase
        remainingSeconds = engine.remainingSeconds
    }

    private func syncEngineDurationsToSettings() {
        engine.updateDurations(
            focusDuration: settings.focusDuration,
            breakDuration: settings.breakDuration
        )
    }

    private func handleTransition(_ transition: PomodoroTransition?) {
        guard let transition else {
            return
        }

        switch transition {
        case .focusCompleted:
            let title = "Pomodoro complete"
            let message = "Time for a \(settings.breakMinutes)-minute break."
            deliverAlert(title: title, message: message)
        case .breakCompleted:
            let title = "Break complete"
            let message = "Ready for the next focus session."
            deliverAlert(title: title, message: message)
        }
    }

    private func deliverAlert(title: String, message: String) {
        if settings.notificationsEnabled {
            notificationManager.deliverNotification(title: title, message: message, playSound: settings.soundsEnabled)
        } else if settings.soundsEnabled {
            notificationManager.playGentleSound()
        }

        if settings.inAppAlertsEnabled {
            activeAlert = PomodoroAlertContent(title: title, message: message)
        }
    }
}
