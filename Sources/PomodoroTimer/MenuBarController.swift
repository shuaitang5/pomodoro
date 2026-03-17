import AppKit
import SwiftUI

@MainActor
final class MenuBarController: NSObject, NSWindowDelegate {
    static let shared = MenuBarController()

    private let panelScreenInset: CGFloat = 8
    private let panelVerticalSpacing: CGFloat = 6
    private let statusItemWindowRetryLimit = 20
    private let statusItemWindowRetryDelay: TimeInterval = 0.01
    private let panelStabilizationPassCount = 3
    private let panelStabilizationDelay: TimeInterval = 0.02

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
        showPanel(statusItemWindowRetriesRemaining: statusItemWindowRetryLimit)
    }

    private func showPanel(statusItemWindowRetriesRemaining: Int) {
        configure()

        if statusItem?.button?.window == nil,
           statusItemWindowRetriesRemaining > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + statusItemWindowRetryDelay) { [weak self] in
                self?.showPanel(statusItemWindowRetriesRemaining: statusItemWindowRetriesRemaining - 1)
            }
            return
        }

        let panel = makePanelIfNeeded()
        refreshPanelContent()
        positionPanel(panel)
        installClickMonitorsIfNeeded()

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        stabilizePanelPosition(panel, passesRemaining: panelStabilizationPassCount)
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
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: ContentView.panelWidth,
                height: ContentView.panelHeight
            ),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentViewController = hostingController
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
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
        guard let buttonFrameOnScreen = statusButtonFrameOnScreen() else {
            positionPanelUsingMouseLocation(panel)
            return
        }

        let screen = statusItem?.button?.window?.screen
            ?? NSScreen.screens.first(where: { $0.frame.intersects(buttonFrameOnScreen) })
            ?? NSScreen.main

        panel.setFrameOrigin(panelOrigin(for: buttonFrameOnScreen, on: screen, panel: panel))
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
        statusButtonFrameOnScreen()?.contains(point) == true
    }

    private func screenPoint(for event: NSEvent) -> NSPoint {
        guard let window = event.window else {
            return NSEvent.mouseLocation
        }

        let rect = NSRect(origin: event.locationInWindow, size: .zero)
        return window.convertToScreen(rect).origin
    }

    private func positionPanelUsingMouseLocation(_ panel: NSPanel) {
        let mouseLocation = NSEvent.mouseLocation
        let anchorRect = NSRect(origin: mouseLocation, size: .zero)
        let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) ?? NSScreen.main
        panel.setFrameOrigin(panelOrigin(for: anchorRect, on: screen, panel: panel))
    }

    private func stabilizePanelPosition(_ panel: NSPanel, passesRemaining: Int) {
        guard passesRemaining > 0 else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + panelStabilizationDelay) { [weak self, weak panel] in
            guard let self, let panel, panel.isVisible else {
                return
            }

            self.positionPanel(panel)
            self.stabilizePanelPosition(panel, passesRemaining: passesRemaining - 1)
        }
    }

    private func panelOrigin(for anchorRect: NSRect, on screen: NSScreen?, panel: NSPanel) -> NSPoint {
        let fallbackVisibleFrame = NSScreen.main?.visibleFrame ?? .zero
        let visibleFrame = screen?.visibleFrame ?? fallbackVisibleFrame
        let leftAlignedX = anchorRect.minX
        let rightAlignedX = anchorRect.maxX - panel.frame.width
        let rightEdgeLimit = visibleFrame.maxX - panel.frame.width - panelScreenInset
        let shouldRightAlign = leftAlignedX > rightEdgeLimit
        var origin = NSPoint(
            x: shouldRightAlign ? rightAlignedX : leftAlignedX,
            y: anchorRect.minY - panel.frame.height - panelVerticalSpacing
        )

        origin.x = min(
            max(origin.x, visibleFrame.minX + panelScreenInset),
            visibleFrame.maxX - panel.frame.width - panelScreenInset
        )
        origin.y = max(origin.y, visibleFrame.minY + panelScreenInset)

        return origin
    }

    private func statusButtonFrameOnScreen() -> NSRect? {
        guard let buttonWindow = statusItem?.button?.window,
              buttonWindow.frame.width > 0,
              buttonWindow.frame.height > 0 else {
            return nil
        }

        return buttonWindow.frame
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
