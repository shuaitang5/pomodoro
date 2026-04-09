import SwiftUI
import AppKit

@main
struct PomodoroTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let environment = AppEnvironment.shared

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") {
                    environment.panelState.showSettings()
                    MenuBarController.shared.showPanel()
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            CommandGroup(after: .appSettings) {
                Button("Quit PomodoroTimer") {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        MenuBarController.shared.configure()
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppEnvironment.shared.viewModel.handleApplicationTermination()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            ControlWindowController.shared.show()
            return false
        }

        return true
    }
}

enum MenuBarTomatoImage {
    private static let idleOpacity: CGFloat = 0.56

    private static let activeIcon = makeIcon(fillColor: .labelColor)
    private static let idleIcon = makeIcon(fillColor: NSColor.labelColor.withAlphaComponent(idleOpacity))

    static func icon(for state: MenuBarIconState) -> NSImage {
        switch state {
        case .idle:
            return idleIcon
        case .active:
            return activeIcon
        }
    }

    private static func makeIcon(fillColor: NSColor) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { _ in
            fillColor.setFill()

            NSBezierPath(ovalIn: NSRect(x: 2.2, y: 1.8, width: 13.6, height: 11.8)).fill()

            let sepal = NSBezierPath()
            let center = CGPoint(x: 9.0, y: 12.0)
            let outerRadius: CGFloat = 4.5
            let innerRadius: CGFloat = 2.0

            for index in 0..<10 {
                let angle = (CGFloat(index) * (.pi / 5.0)) - (.pi / 2.0)
                let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
                let point = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )

                if index == 0 {
                    sepal.move(to: point)
                } else {
                    sepal.line(to: point)
                }
            }

            sepal.close()
            sepal.fill()

            let stem = NSBezierPath(roundedRect: NSRect(x: 8.1, y: 11.2, width: 1.9, height: 5.2), xRadius: 0.95, yRadius: 0.95)
            var transform = AffineTransform()
            transform.translate(x: 8.8, y: 11.7)
            transform.rotate(byDegrees: 24)
            transform.translate(x: -8.8, y: -11.7)
            stem.transform(using: transform)
            stem.fill()

            return true
        }

        image.isTemplate = true
        return image
    }
}
