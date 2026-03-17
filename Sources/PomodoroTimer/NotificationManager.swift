import AppKit

@MainActor
protocol NotificationHandling: AnyObject {
    func playGentleSound()
}

@MainActor
final class NotificationManager: NotificationHandling {
    func playGentleSound() {
        NSSound(named: NSSound.Name("Glass"))?.play()
    }
}
