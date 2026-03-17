import XCTest
@testable import PomodoroTimer

final class MenuBarPanelPositioningTests: XCTestCase {
    func testUsesLeftEdgeAlignmentWhenThereIsRoom() {
        let origin = MenuBarPanelPositioning.panelOrigin(
            anchorRect: CGRect(x: 100, y: 900, width: 24, height: 24),
            visibleFrame: CGRect(x: 0, y: 0, width: 1440, height: 900),
            panelSize: CGSize(width: 316, height: 460),
            screenInset: 8,
            verticalSpacing: 6
        )

        XCTAssertEqual(origin.x, 100)
        XCTAssertEqual(origin.y, 434)
    }

    func testUsesRightEdgeAlignmentNearScreenEdge() {
        let origin = MenuBarPanelPositioning.panelOrigin(
            anchorRect: CGRect(x: 1320, y: 900, width: 24, height: 24),
            visibleFrame: CGRect(x: 0, y: 0, width: 1440, height: 900),
            panelSize: CGSize(width: 316, height: 460),
            screenInset: 8,
            verticalSpacing: 6
        )

        XCTAssertEqual(origin.x, 1028)
        XCTAssertEqual(origin.y, 434)
    }

    func testClampsToVisibleFrameInsets() {
        let origin = MenuBarPanelPositioning.panelOrigin(
            anchorRect: CGRect(x: 2, y: 400, width: 20, height: 20),
            visibleFrame: CGRect(x: 0, y: 0, width: 320, height: 380),
            panelSize: CGSize(width: 316, height: 460),
            screenInset: 8,
            verticalSpacing: 6
        )

        XCTAssertEqual(origin.x, -4)
        XCTAssertEqual(origin.y, 8)
    }
}
