import AppKit
import SwiftUI

@MainActor
protocol InAppAlertPresenting: AnyObject {
    func presentAlert(title: String, message: String, onDismiss: @escaping @MainActor () -> Void)
}

@MainActor
final class CompletionAlertPresenter: NSObject, InAppAlertPresenting {
    private struct PendingAlert {
        let title: String
        let message: String
        let onDismiss: @MainActor () -> Void
    }

    private var alertWindowController: AlertWindowController?
    private var pendingAlerts: [PendingAlert] = []

    var activeWindow: NSWindow? {
        alertWindowController?.window
    }

    func presentAlert(title: String, message: String, onDismiss: @escaping @MainActor () -> Void = {}) {
        let alert = PendingAlert(title: title, message: message, onDismiss: onDismiss)

        guard alertWindowController == nil else {
            pendingAlerts.append(alert)
            return
        }

        show(alert)
    }

    private func show(_ alert: PendingAlert) {
        AppEnvironment.shared.panelState.showTimer()
        MenuBarController.shared.showPanel()

        let controller = AlertWindowController(title: alert.title, message: alert.message) { [weak self] in
            guard let self else {
                return
            }

            alert.onDismiss()
            self.alertWindowController = nil

            guard let nextAlert = self.pendingAlerts.first else {
                return
            }

            self.pendingAlerts.removeFirst()
            self.show(nextAlert)
        }

        alertWindowController = controller
        controller.showAlertWindow()
    }
}

@MainActor
private final class AlertWindowController: NSWindowController, NSWindowDelegate {
    private let onClose: () -> Void

    init(title: String, message: String, onClose: @escaping () -> Void) {
        self.onClose = onClose

        let hostingController = NSHostingController(
            rootView: CompletionAlertView(title: title, message: message)
        )

        let window = AlertWindow(contentViewController: hostingController)
        window.title = title
        window.styleMask = [.titled, .closable]
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.level = .modalPanel
        window.center()
        window.setContentSize(NSSize(width: 360, height: 190))
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        super.init(window: window)

        window.delegate = self
        window.onAcknowledge = { [weak self] in
            self?.close()
        }
        hostingController.rootView = CompletionAlertView(title: title, message: message) { [weak self] in
            self?.close()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showAlertWindow() {
        showWindow(nil)
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}

private final class AlertWindow: NSWindow {
    var onAcknowledge: () -> Void = {}

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard event.type == .keyDown else {
            return super.performKeyEquivalent(with: event)
        }

        guard CompletionAlertKeyboardShortcut.shouldAcknowledge(
            keyCode: event.keyCode,
            modifierFlags: event.modifierFlags
        ) else {
            return super.performKeyEquivalent(with: event)
        }

        onAcknowledge()
        return true
    }
}

private struct CompletionAlertView: View {
    let title: String
    let message: String
    var onDismiss: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "bell.circle.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color(red: 0.78, green: 0.24, blue: 0.16))

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack {
                Spacer()

                Button("OK") {
                    onDismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 360)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
