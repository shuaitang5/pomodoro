import Foundation

enum PomodoroPhase: Equatable {
    case idle
    case focusRunning
    case breakPending
    case breakRunning
}

enum PomodoroTransition: Equatable {
    case focusCompleted
    case breakCompleted
}

struct PomodoroEngine {
    private(set) var focusDuration: TimeInterval
    private(set) var breakDuration: TimeInterval

    private(set) var phase: PomodoroPhase
    private(set) var remainingSeconds: Int
    private(set) var endDate: Date?

    init(focusDuration: TimeInterval = 25 * 60, breakDuration: TimeInterval = 5 * 60) {
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.phase = .idle
        self.remainingSeconds = Int(focusDuration)
        self.endDate = nil
    }

    mutating func start(now: Date) {
        guard phase == .idle else {
            return
        }

        phase = .focusRunning
        remainingSeconds = Int(focusDuration)
        endDate = now.addingTimeInterval(focusDuration)
    }

    mutating func reset() {
        phase = .idle
        remainingSeconds = Int(focusDuration)
        endDate = nil
    }

    mutating func startBreak(now: Date) {
        guard phase == .breakPending else {
            return
        }

        phase = .breakRunning
        remainingSeconds = Int(breakDuration)
        endDate = now.addingTimeInterval(breakDuration)
    }

    mutating func updateDurations(focusDuration: TimeInterval, breakDuration: TimeInterval) {
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration

        if phase == .idle {
            remainingSeconds = Int(focusDuration)
        } else if phase == .breakPending {
            remainingSeconds = Int(breakDuration)
        }
    }

    mutating func tick(now: Date) -> PomodoroTransition? {
        guard let endDate else {
            return nil
        }

        let secondsLeft = max(0, Int(ceil(endDate.timeIntervalSince(now))))

        guard secondsLeft == 0 else {
            remainingSeconds = secondsLeft
            return nil
        }

        switch phase {
        case .idle:
            return nil
        case .focusRunning:
            phase = .breakPending
            remainingSeconds = Int(breakDuration)
            self.endDate = nil
            return .focusCompleted
        case .breakPending:
            return nil
        case .breakRunning:
            reset()
            return .breakCompleted
        }
    }
}
