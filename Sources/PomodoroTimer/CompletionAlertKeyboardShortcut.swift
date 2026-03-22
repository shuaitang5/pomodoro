import AppKit

enum CompletionAlertKeyboardShortcut {
    static func shouldAcknowledge(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags = []) -> Bool {
        let relevantModifiers = modifierFlags.intersection([.command, .control, .option])
        guard relevantModifiers.isEmpty else {
            return false
        }

        return keyCode == 36 || keyCode == 49 || keyCode == 76
    }
}
