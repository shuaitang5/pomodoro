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
}
