import Foundation

@MainActor
final class MenuPanelState: ObservableObject {
    enum Page {
        case timer
        case settings
    }

    @Published var page: Page = .timer

    func showTimer() {
        page = .timer
    }

    func showSettings() {
        page = .settings
    }
}
