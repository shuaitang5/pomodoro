import Foundation

@MainActor
final class AppEnvironment {
    static let shared = AppEnvironment()

    let settings = AppSettingsStore()
    let panelState = MenuPanelState()
    let alertPresenter = CompletionAlertPresenter()
    let notificationManager = NotificationManager()
    lazy var viewModel = PomodoroViewModel(
        settings: settings,
        notificationManager: notificationManager,
        alertPresenter: alertPresenter
    )

    private init() {}

    @discardableResult
    func handleQuickPresetKeyboardShortcut(_ action: QuickPresetKeyboardShortcutAction) -> Bool {
        guard panelState.page == .timer, viewModel.isSessionPresetSelectionEnabled else {
            return false
        }

        switch action {
        case .previous:
            settings.cycleQuickSessionPreset(step: -1)
        case .next:
            settings.cycleQuickSessionPreset(step: 1)
        }

        return true
    }

    @discardableResult
    func handleEscapeOnTimerSurface(onDismiss: () -> Void) -> Bool {
        switch panelState.page {
        case .settings:
            panelState.showTimer()
        case .timer:
            onDismiss()
        }

        return true
    }
}
