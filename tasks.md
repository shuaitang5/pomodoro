# Pomodoro Timer Tasks

## Goal

Build a native macOS Pomodoro timer that lives in the system menu bar.

Main flow:

1. App launches into the menu bar
2. User clicks the tomato icon
3. Dropdown shows timer controls
4. User starts a focus countdown
5. Focus completion alerts the user and starts break countdown
6. Break completion alerts the user and returns to idle

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

- replace the standalone window with a menu bar dropdown panel
- show timer controls from the menu bar icon
- keep a Dock icon fallback when the menu bar is crowded
- open a compact control window when the Dock icon is clicked
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

- idle, focus, and break states
- countdown updates every second
- automatic transition from focus to break
- reset back to idle
- timer text formatting for the UI

Key files:

- `Sources/PomodoroTimer/PomodoroEngine.swift`
- `Sources/PomodoroTimer/PomodoroViewModel.swift`

## Task 4: Alerts And Settings

Status: completed

Implemented:

- macOS notifications
- in-app alert support
- gentle sound
- settings UI for focus/break presets and alert preferences
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

## Current MVP Definition

The MVP is done when:

- app launches into the menu bar
- app is still reachable from the Dock
- clicking the Dock icon opens a usable control window
- user can click the tomato icon to open the dropdown
- user can start a focus session
- timer counts down correctly
- focus completion alerts the user and starts break
- break completion alerts the user and returns to idle
- settings slide in inside the dropdown
- settings fit without scrolling
- user can quit from the dropdown
- presets and alert preferences work
