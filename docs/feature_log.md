# Pomodoro Timer Feature Log

## PMD-F001: Idle Menu Bar Icon Uses a Lighter Tomato

Status: shipped

Added: 2026-04-02

Area:

- menu bar icon state

Behavior:

- while the app is idle, the menu bar tomato uses a lighter template appearance
- when a focus session, break-ready state, or break timer is active, the menu bar returns to the original full-strength tomato icon

Why:

- the menu bar now communicates whether Pomodoro is resting or in the middle of a session without opening the dropdown
- the lighter idle icon follows the same diluted visual cue the user referenced from the macOS sleep-style state

Files changed:

- `Sources/PomodoroTimer/MenuBarController.swift`
- `Sources/PomodoroTimer/PomodoroTimerApp.swift`
- `Sources/PomodoroTimer/PomodoroViewModel.swift`
- `Tests/PomodoroTimerTests/PomodoroViewModelTests.swift`

Manual verification:

1. Launch the app and confirm the menu bar tomato appears lighter before starting a session.
2. Start a focus session and confirm the full-strength tomato returns immediately.
3. Let focus complete and confirm the full-strength tomato remains visible while waiting for the break acknowledgement popup.
4. Dismiss the popup and confirm the full-strength tomato remains visible during the break countdown.
5. Let the break complete and confirm the menu bar tomato returns to the lighter idle appearance.
