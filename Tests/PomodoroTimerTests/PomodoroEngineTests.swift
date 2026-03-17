import XCTest
@testable import PomodoroTimer

final class PomodoroEngineTests: XCTestCase {
    func testInitialStateUsesFocusDuration() {
        let engine = PomodoroEngine(focusDuration: 1500, breakDuration: 300)

        XCTAssertEqual(engine.phase, .idle)
        XCTAssertEqual(engine.remainingSeconds, 1500)
        XCTAssertNil(engine.endDate)
    }

    func testStartEntersFocusMode() {
        var engine = PomodoroEngine(focusDuration: 10, breakDuration: 5)
        let now = Date(timeIntervalSince1970: 100)

        engine.start(now: now)

        XCTAssertEqual(engine.phase, .focusRunning)
        XCTAssertEqual(engine.remainingSeconds, 10)
        XCTAssertEqual(engine.endDate, now.addingTimeInterval(10))
    }

    func testTickCountsDownDuringFocus() {
        var engine = PomodoroEngine(focusDuration: 10, breakDuration: 5)
        let start = Date(timeIntervalSince1970: 100)
        engine.start(now: start)

        let transition = engine.tick(now: start.addingTimeInterval(3.2))

        XCTAssertNil(transition)
        XCTAssertEqual(engine.phase, .focusRunning)
        XCTAssertEqual(engine.remainingSeconds, 7)
    }

    func testFocusCompletionStartsBreakTimer() {
        var engine = PomodoroEngine(focusDuration: 10, breakDuration: 5)
        let start = Date(timeIntervalSince1970: 100)
        engine.start(now: start)

        let transition = engine.tick(now: start.addingTimeInterval(10))

        XCTAssertEqual(transition, .focusCompleted)
        XCTAssertEqual(engine.phase, .breakRunning)
        XCTAssertEqual(engine.remainingSeconds, 5)
        XCTAssertEqual(engine.endDate, start.addingTimeInterval(15))
    }

    func testBreakCompletionResetsBackToIdle() {
        var engine = PomodoroEngine(focusDuration: 10, breakDuration: 5)
        let start = Date(timeIntervalSince1970: 100)
        engine.start(now: start)
        _ = engine.tick(now: start.addingTimeInterval(10))

        let transition = engine.tick(now: start.addingTimeInterval(15))

        XCTAssertEqual(transition, .breakCompleted)
        XCTAssertEqual(engine.phase, .idle)
        XCTAssertEqual(engine.remainingSeconds, 10)
        XCTAssertNil(engine.endDate)
    }

    func testResetReturnsToIdleFromRunningSession() {
        var engine = PomodoroEngine(focusDuration: 10, breakDuration: 5)
        engine.start(now: Date(timeIntervalSince1970: 100))

        engine.reset()

        XCTAssertEqual(engine.phase, .idle)
        XCTAssertEqual(engine.remainingSeconds, 10)
        XCTAssertNil(engine.endDate)
    }

    func testUpdatingDurationsWhileIdleRefreshesDisplayedFocusTime() {
        var engine = PomodoroEngine(focusDuration: 10, breakDuration: 5)

        engine.updateDurations(focusDuration: 20, breakDuration: 8)

        XCTAssertEqual(engine.remainingSeconds, 20)
        XCTAssertEqual(engine.focusDuration, 20)
        XCTAssertEqual(engine.breakDuration, 8)
    }

    func testUpdatingDurationsWhileRunningDoesNotChangeCurrentCountdown() {
        var engine = PomodoroEngine(focusDuration: 10, breakDuration: 5)
        let start = Date(timeIntervalSince1970: 100)
        engine.start(now: start)
        _ = engine.tick(now: start.addingTimeInterval(3))

        engine.updateDurations(focusDuration: 20, breakDuration: 8)

        XCTAssertEqual(engine.phase, .focusRunning)
        XCTAssertEqual(engine.remainingSeconds, 7)
        XCTAssertEqual(engine.focusDuration, 20)
        XCTAssertEqual(engine.breakDuration, 8)
    }
}
