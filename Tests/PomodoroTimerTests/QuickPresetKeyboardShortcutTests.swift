import AppKit
import XCTest
@testable import PomodoroTimer

final class QuickPresetKeyboardShortcutTests: XCTestCase {
    func testTabAdvancesToNextPreset() {
        XCTAssertEqual(
            QuickPresetKeyboardShortcut.action(keyCode: 48),
            .next
        )
    }

    func testShiftTabMovesToPreviousPreset() {
        XCTAssertEqual(
            QuickPresetKeyboardShortcut.action(keyCode: 48, modifierFlags: [.shift]),
            .previous
        )
    }

    func testRightArrowAdvancesToNextPreset() {
        XCTAssertEqual(
            QuickPresetKeyboardShortcut.action(keyCode: 124),
            .next
        )
    }

    func testLeftArrowMovesToPreviousPreset() {
        XCTAssertEqual(
            QuickPresetKeyboardShortcut.action(keyCode: 123),
            .previous
        )
    }

    func testModifiedArrowKeyDoesNotTriggerPresetChange() {
        XCTAssertNil(
            QuickPresetKeyboardShortcut.action(keyCode: 124, modifierFlags: [.command])
        )
    }

    func testOtherKeyDoesNotTriggerPresetChange() {
        XCTAssertNil(
            QuickPresetKeyboardShortcut.action(keyCode: 53)
        )
    }
}
