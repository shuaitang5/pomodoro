import AppKit

enum EscapeKeyboardShortcut {
    static func shouldHandle(
        keyCode: UInt16,
        modifierFlags: NSEvent.ModifierFlags = []
    ) -> Bool {
        let modifiers = modifierFlags.intersection([.command, .control, .option, .shift])
        return keyCode == 53 && modifiers.isEmpty
    }
}
