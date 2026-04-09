import AppKit
import XCTest
@testable import PomodoroTimer

final class EscapeKeyboardShortcutTests: XCTestCase {
    func testEscapeWithoutModifiersIsHandled() {
        XCTAssertTrue(EscapeKeyboardShortcut.shouldHandle(keyCode: 53))
    }

    func testEscapeWithModifiersIsIgnored() {
        XCTAssertFalse(
            EscapeKeyboardShortcut.shouldHandle(
                keyCode: 53,
                modifierFlags: [.command]
            )
        )
    }

    func testOtherKeysAreIgnored() {
        XCTAssertFalse(EscapeKeyboardShortcut.shouldHandle(keyCode: 49))
    }
}
