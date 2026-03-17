import AppKit
import SwiftUI

@MainActor
final class MenuBarController: NSObject, NSWindowDelegate {
    static let shared = MenuBarController()

    private var statusItem: NSStatusItem?
    private var panel: MenuBarPanel?
    private var localClickMonitor: Any?
    private var globalClickMonitor: Any?

    func configure() {
        guard statusItem == nil else {
            return
        }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = MenuBarTomatoImage.icon
        item.button?.target = self
        item.button?.action = #selector(togglePanel(_:))

        statusItem = item
    }

    func showPanel() {
        configure()

        let panel = makePanelIfNeeded()
        refreshPanelContent()
        positionPanel(panel)
        installClickMonitorsIfNeeded()

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func hidePanel() {
        panel?.orderOut(nil)
        removeClickMonitors()
    }

    var isPanelVisible: Bool {
        panel?.isVisible == true
    }

    @objc
    private func togglePanel(_ sender: Any?) {
        if isPanelVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    func windowWillClose(_ notification: Notification) {
        guard let closingWindow = notification.object as? NSWindow, closingWindow == panel else {
            return
        }

        removeClickMonitors()
    }

    private func makePanelIfNeeded() -> MenuBarPanel {
        if let panel {
            return panel
        }

        let hostingController = NSHostingController(rootView: makeContentView())
        let panel = MenuBarPanel(
            contentRect: NSRect(x: 0, y: 0, width: 352, height: 476),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentViewController = hostingController
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.level = .floating
        panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        panel.delegate = self

        self.panel = panel
        return panel
    }

    private func refreshPanelContent() {
        guard let hostingController = panel?.contentViewController as? NSHostingController<ContentView> else {
            return
        }

        hostingController.rootView = makeContentView()
    }

    private func makeContentView() -> ContentView {
        let environment = AppEnvironment.shared
        return ContentView(
            settings: environment.settings,
            panelState: environment.panelState,
            viewModel: environment.viewModel
        )
    }

    private func positionPanel(_ panel: NSPanel) {
        guard let button = statusItem?.button,
              let buttonWindow = button.window else {
            panel.center()
            return
        }

        let buttonFrame = button.convert(button.bounds, to: nil)
        let buttonFrameOnScreen = buttonWindow.convertToScreen(buttonFrame)
        guard let screen = buttonWindow.screen ?? NSScreen.main else {
            panel.setFrameOrigin(
                NSPoint(
                    x: buttonFrameOnScreen.midX - (panel.frame.width / 2),
                    y: buttonFrameOnScreen.minY - panel.frame.height - 8
                )
            )
            return
        }

        let visibleFrame = screen.visibleFrame
        var origin = NSPoint(
            x: buttonFrameOnScreen.midX - (panel.frame.width / 2),
            y: buttonFrameOnScreen.minY - panel.frame.height - 8
        )

        origin.x = min(max(origin.x, visibleFrame.minX + 8), visibleFrame.maxX - panel.frame.width - 8)
        origin.y = max(origin.y, visibleFrame.minY + 8)

        panel.setFrameOrigin(origin)
    }

    private func installClickMonitorsIfNeeded() {
        guard localClickMonitor == nil, globalClickMonitor == nil else {
            return
        }

        localClickMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        ) { [weak self] event in
            self?.handleClick(at: self?.screenPoint(for: event) ?? NSEvent.mouseLocation)
            return event
        }

        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        ) { [weak self] _ in
            self?.handleClick(at: NSEvent.mouseLocation)
        }
    }

    private func removeClickMonitors() {
        if let localClickMonitor {
            NSEvent.removeMonitor(localClickMonitor)
            self.localClickMonitor = nil
        }

        if let globalClickMonitor {
            NSEvent.removeMonitor(globalClickMonitor)
            self.globalClickMonitor = nil
        }
    }

    private func handleClick(at screenPoint: NSPoint) {
        guard isPanelVisible else {
            return
        }

        if isPointInsidePanel(screenPoint) || isPointInsideAlertWindow(screenPoint) || isPointInsideStatusButton(screenPoint) {
            return
        }

        hidePanel()
    }

    private func isPointInsidePanel(_ point: NSPoint) -> Bool {
        guard let panel else {
            return false
        }

        return panel.frame.contains(point)
    }

    private func isPointInsideAlertWindow(_ point: NSPoint) -> Bool {
        guard let alertWindow = AppEnvironment.shared.alertPresenter.activeWindow else {
            return false
        }

        return alertWindow.isVisible && alertWindow.frame.contains(point)
    }

    private func isPointInsideStatusButton(_ point: NSPoint) -> Bool {
        guard let button = statusItem?.button,
              let buttonWindow = button.window else {
            return false
        }

        let buttonFrame = button.convert(button.bounds, to: nil)
        let buttonFrameOnScreen = buttonWindow.convertToScreen(buttonFrame)
        return buttonFrameOnScreen.contains(point)
    }

    private func screenPoint(for event: NSEvent) -> NSPoint {
        guard let window = event.window else {
            return NSEvent.mouseLocation
        }

        let rect = NSRect(origin: event.locationInWindow, size: .zero)
        return window.convertToScreen(rect).origin
    }
}

private final class MenuBarPanel: NSPanel {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        false
    }
}
