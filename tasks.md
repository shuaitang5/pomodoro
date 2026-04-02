# Pomodoro Timer Tasks

## Goal

Build a native macOS Pomodoro timer that lives in the system menu bar.

Main flow:

1. App launches into the menu bar
2. User clicks the tomato icon
3. Dropdown shows timer controls
4. User starts a focus countdown
5. Focus completion alerts the user and waits for acknowledgement
6. Break countdown starts after acknowledgement
7. Break completion alerts the user and returns to idle

## Task Breakdown

## Task 1: App Scaffold

Status: completed

Implemented:

- SwiftUI macOS app entry point
- local packaging flow for a `.app` bundle
- bundle metadata and app icon setup

Key files:

- `Sources/PomodoroTimer/PomodoroTimerApp.swift`
- `scripts/package_app.sh`
- `packaging/PomodoroTimer-Info.plist`

## Task 2: Timer Surface

Status: completed

Implemented:

- replace the standalone window with a custom status-item dropdown panel
- show timer controls from the menu bar icon
- stay out of the Dock on normal launch
- open a compact fallback control window when the app is launched again and the menu bar icon is not accessible
- show the Dock icon only while the fallback control window is open
- keep settings inside the dropdown as a second page
- add a quit action inside the dropdown
- animate from the timer page into the settings page
- fit all settings controls without scrolling

Key files:

- `Sources/PomodoroTimer/PomodoroTimerApp.swift`
- `Sources/PomodoroTimer/ContentView.swift`
- `Sources/PomodoroTimer/ControlWindowController.swift`
- `Sources/PomodoroTimer/MenuPanelState.swift`
- `Sources/PomodoroTimer/SettingsView.swift`

## Task 3: Timer Logic

Status: completed

Implemented:

- idle, focus, break pending acknowledgment, and break states
- countdown updates every second
- delayed transition from focus to break until the popup is acknowledged
- reset back to idle
- timer text formatting for the UI

Key files:

- `Sources/PomodoroTimer/PomodoroEngine.swift`
- `Sources/PomodoroTimer/PomodoroViewModel.swift`

## Task 4: Alerts And Settings

Status: completed

Implemented:

- popup window support
- gentle sound
- optional Do Not Disturb during focus via named Shortcuts
- settings UI for focus/break presets, sound preferences, and Do Not Disturb toggle
- setup reminder and safe fallback when the Do Not Disturb automation is missing or broken
- in-dropdown settings page behavior
- keyboard shortcuts:
  - `Space`
  - `R`
  - `Cmd+,`

Key files:

- `Sources/PomodoroTimer/NotificationManager.swift`
- `Sources/PomodoroTimer/AppSettingsStore.swift`
- `Sources/PomodoroTimer/SettingsView.swift`
- `Sources/PomodoroTimer/MenuPanelState.swift`

## Task 5: Integration And QA

Status: pending

Planned:

- end-to-end validation after menu bar conversion
- packaging verification after menu bar conversion
- final cleanup of rough edges

## Task 6: Menu Bar Status Cue

Status: completed

Implemented:

- keep the full-strength tomato menu bar icon for any non-idle timer phase
- dim the tomato icon while the app is idle so the resting state reads differently at a glance
- document the feature in a dedicated feature log

Key files:

- `Sources/PomodoroTimer/MenuBarController.swift`
- `Sources/PomodoroTimer/PomodoroTimerApp.swift`
- `Sources/PomodoroTimer/PomodoroViewModel.swift`
- `docs/feature_log.md`

## Current MVP Definition

The MVP is done when:

- app launches into the menu bar
- app launches with no persistent Dock icon
- launching the app again opens a usable fallback control window when the menu bar item is not accessible
- the Dock icon appears only while the fallback control window is open
- user can click the tomato icon to open the dropdown
- user can start a focus session
- timer counts down correctly
- focus completion alerts the user and waits for acknowledgement
- focus popup also shows the dropdown timer panel
- break starts only after the popup is acknowledged
- break completion alerts the user and returns to idle
- settings slide in inside the dropdown
- settings fit without scrolling
- user can quit from the dropdown
- presets and sound preference work
- optional Do Not Disturb during focus automation works when the required Shortcuts exist
- missing Do Not Disturb automation does not interrupt the Pomodoro timer flow
