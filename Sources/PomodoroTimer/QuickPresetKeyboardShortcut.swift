import AppKit

enum QuickPresetKeyboardShortcutAction: Equatable {
    case previous
    case next
}

enum QuickPresetKeyboardShortcut {
    static func action(
        keyCode: UInt16,
        modifierFlags: NSEvent.ModifierFlags = []
    ) -> QuickPresetKeyboardShortcutAction? {
        let modifiers = modifierFlags.intersection(.deviceIndependentFlagsMask)

        switch keyCode {
        case 48:
            switch modifiers.intersection([.command, .control, .option, .shift]) {
            case []:
                return .next
            case [.shift]:
                return .previous
            default:
                return nil
            }
        case 123:
            guard modifiers.intersection([.command, .control, .option, .shift]).isEmpty else {
                return nil
            }
            return .previous
        case 124:
            guard modifiers.intersection([.command, .control, .option, .shift]).isEmpty else {
                return nil
            }
            return .next
        default:
            return nil
        }
    }
}
