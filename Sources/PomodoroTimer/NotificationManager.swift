import AppKit
import Foundation
import UserNotifications

@MainActor
protocol NotificationHandling: AnyObject {
    func requestAuthorizationIfNeeded()
    func deliverNotification(title: String, message: String, playSound: Bool)
    func playGentleSound()
}

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate, NotificationHandling {
    private let center: UNUserNotificationCenter
    private var hasRequestedAuthorization = false

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
        super.init()
        self.center.delegate = self
    }

    func requestAuthorizationIfNeeded() {
        guard !hasRequestedAuthorization else {
            return
        }

        hasRequestedAuthorization = true
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func deliverNotification(title: String, message: String, playSound: Bool) {
        requestAuthorizationIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        center.add(request)

        if playSound {
            playGentleSound()
        }
    }

    func playGentleSound() {
        NSSound(named: NSSound.Name("Glass"))?.play()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list]
    }
}
