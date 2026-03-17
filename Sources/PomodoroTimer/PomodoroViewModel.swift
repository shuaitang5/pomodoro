import Combine
import Foundation

@MainActor
final class PomodoroViewModel: ObservableObject {
    @Published private(set) var phase: PomodoroPhase
    @Published private(set) var remainingSeconds: Int

    private var engine: PomodoroEngine
    private var timer: Timer?
    private let now: () -> Date
    private let settings: AppSettingsStore
    private let notificationManager: NotificationHandling
    private let alertPresenter: InAppAlertPresenting
    private var cancellables = Set<AnyCancellable>()

    init(
        settings: AppSettingsStore,
        notificationManager: NotificationHandling = NotificationManager(),
        alertPresenter: InAppAlertPresenting = CompletionAlertPresenter(),
        engine: PomodoroEngine? = nil,
        now: @escaping () -> Date = Date.init
    ) {
        self.settings = settings
        self.notificationManager = notificationManager
        self.alertPresenter = alertPresenter
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
                    focusDuration: AppSettingsStore.focusDuration(forMinutes: focusMinutes),
                    breakDuration: AppSettingsStore.breakDuration(forMinutes: breakMinutes)
                )
                self.syncFromEngine()
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
        case .breakPending:
            return "Break ready to start"
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

        guard let transition else {
            return
        }

        switch transition {
        case .focusCompleted:
            timer?.invalidate()
            timer = nil
            handleFocusCompleted()
        case .breakCompleted:
            timer?.invalidate()
            timer = nil
            syncEngineDurationsToSettings()
            syncFromEngine()
            handleBreakCompleted()
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

    private func handleFocusCompleted() {
        let title = "Pomodoro complete"
        let message = "Time for a \(settings.breakMinutes)-minute break."
        deliverAlert(title: title, message: message) { [weak self] in
            self?.startBreakAfterAcknowledgement()
        }
    }

    private func handleBreakCompleted() {
        let title = "Break complete"
        let message = "Ready for the next focus session."
        deliverAlert(title: title, message: message)
    }

    private func startBreakAfterAcknowledgement() {
        guard phase == .breakPending else {
            return
        }

        engine.startBreak(now: now())
        syncFromEngine()
        startTimer()
    }

    private func deliverAlert(
        title: String,
        message: String,
        onDismiss: @escaping @MainActor () -> Void = {}
    ) {
        if settings.soundsEnabled {
            notificationManager.playGentleSound()
        }

        alertPresenter.presentAlert(title: title, message: message, onDismiss: onDismiss)
    }
}
