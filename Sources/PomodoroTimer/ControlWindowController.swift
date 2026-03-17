import AppKit
import SwiftUI

@MainActor
final class ControlWindowController: NSObject, NSWindowDelegate {
    static let shared = ControlWindowController()

    private var window: NSWindow?

    func show() {
        let window = makeWindowIfNeeded()

        if let hostingController = window.contentViewController as? NSHostingController<ContentView> {
            let environment = AppEnvironment.shared
            hostingController.rootView = ContentView(
                settings: environment.settings,
                panelState: environment.panelState,
                viewModel: environment.viewModel
            )
        }

        AppEnvironment.shared.panelState.showTimer()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        guard let closingWindow = notification.object as? NSWindow, closingWindow == window else {
            return
        }

        closingWindow.orderOut(nil)
    }

    private func makeWindowIfNeeded() -> NSWindow {
        if let window {
            return window
        }

        let environment = AppEnvironment.shared
        let contentView = ContentView(
            settings: environment.settings,
            panelState: environment.panelState,
            viewModel: environment.viewModel
        )

        let hostingController = NSHostingController(rootView: contentView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Pomodoro Timer"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.setContentSize(NSSize(width: 352, height: 476))
        window.center()
        window.delegate = self

        self.window = window
        return window
    }
}
