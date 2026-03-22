import AppKit
import XCTest
@testable import PomodoroTimer

final class CompletionAlertKeyboardShortcutTests: XCTestCase {
    func testReturnAcknowledgesAlert() {
        XCTAssertTrue(CompletionAlertKeyboardShortcut.shouldAcknowledge(keyCode: 36))
    }

    func testSpaceAcknowledgesAlert() {
        XCTAssertTrue(CompletionAlertKeyboardShortcut.shouldAcknowledge(keyCode: 49))
    }

    func testKeypadEnterAcknowledgesAlert() {
        XCTAssertTrue(CompletionAlertKeyboardShortcut.shouldAcknowledge(keyCode: 76))
    }

    func testCommandModifiedKeyDoesNotAcknowledgeAlert() {
        XCTAssertFalse(
            CompletionAlertKeyboardShortcut.shouldAcknowledge(
                keyCode: 49,
                modifierFlags: [.command]
            )
        )
    }

    func testOtherKeyDoesNotAcknowledgeAlert() {
        XCTAssertFalse(CompletionAlertKeyboardShortcut.shouldAcknowledge(keyCode: 53))
    }
}
