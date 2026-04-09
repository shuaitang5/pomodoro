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
                viewModel: environment.viewModel,
                surfaceStyle: .fullWindow
            )
        }

        AppEnvironment.shared.panelState.showTimer()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        guard let closingWindow = notification.object as? NSWindow, closingWindow == window else {
            return
        }

        closingWindow.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
    }

    private func makeWindowIfNeeded() -> NSWindow {
        if let window {
            return window
        }

        let environment = AppEnvironment.shared
        let contentView = ContentView(
            settings: environment.settings,
            panelState: environment.panelState,
            viewModel: environment.viewModel,
            surfaceStyle: .fullWindow
        )

        let hostingController = NSHostingController(rootView: contentView)
        let window = ControlWindow(contentViewController: hostingController)
        window.title = "Pomodoro Timer"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.isReleasedWhenClosed = false
        window.isOpaque = true
        window.backgroundColor = .windowBackgroundColor
        window.hasShadow = true
        window.setContentSize(NSSize(width: ContentView.panelWidth, height: ContentView.panelHeight))
        window.center()
        window.delegate = self

        self.window = window
        return window
    }
}

private final class ControlWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        if EscapeKeyboardShortcut.shouldHandle(
            keyCode: event.keyCode,
            modifierFlags: event.modifierFlags
        ),
        AppEnvironment.shared.handleEscapeOnTimerSurface(
            onDismiss: { [weak self] in
                self?.close()
            }
        ) {
            return
        }

        if let action = QuickPresetKeyboardShortcut.action(
            keyCode: event.keyCode,
            modifierFlags: event.modifierFlags
        ),
        AppEnvironment.shared.handleQuickPresetKeyboardShortcut(action) {
            return
        }

        super.keyDown(with: event)
    }
}
