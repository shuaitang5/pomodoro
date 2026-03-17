import Foundation

@MainActor
final class AppEnvironment {
    static let shared = AppEnvironment()

    let settings = AppSettingsStore()
    let panelState = MenuPanelState()
    lazy var viewModel = PomodoroViewModel(settings: settings)

    private init() {}
}
