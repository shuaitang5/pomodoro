# Pomodoro Timer Feature Log

## PMD-F002: Main Screen Offers Quick Session Presets

Status: shipped

Added: 2026-04-09

Area:

- timer surface
- settings flow

Behavior:

- the main timer page now includes one-click paired presets for `25+5`, `35+10`, and `50+15`
- picking any quick preset updates both the focus and break durations without opening the settings page
- quick preset changes are only enabled while the timer is idle so an active session cannot be accidentally reconfigured mid-run
- `Tab`, `Shift+Tab`, and left/right arrow keys cycle the quick presets while the timer page is idle
- break messaging now reflects the active break length instead of always referring to a `5-minute` break

Why:

- the primary use case is now `select preset -> Start`, which cuts the common start flow down to two clicks
- the settings page remains available for the full preset list, while the main screen handles the most common session combinations

Files changed:

- `Sources/PomodoroTimer/ContentView.swift`
- `Sources/PomodoroTimer/AppSettingsStore.swift`
- `Sources/PomodoroTimer/PomodoroViewModel.swift`
- `Tests/PomodoroTimerTests/AppSettingsStoreTests.swift`
- `Tests/PomodoroTimerTests/PomodoroViewModelTests.swift`

Manual verification:

1. Launch the app and confirm the timer page shows `25+5`, `35+10`, and `50+15` preset buttons.
2. Click `50+15` and confirm the summary updates to a `50-minute` focus session with a `15-minute` break.
3. Click `Start` and confirm the timer begins without visiting settings.
4. Press `Tab`, `Shift+Tab`, and the left/right arrow keys and confirm the quick preset selection changes without opening settings.
5. Let the focus session complete and confirm the alert announces a `15-minute break`.
6. Acknowledge the popup and confirm the break state reflects the `15-minute` preset.

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
