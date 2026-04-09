# Pomodoro Timer Tasks

## Goal

Build a native macOS Pomodoro timer that lives in the system menu bar.

Main flow:

1. App launches into the menu bar
2. User clicks the tomato icon
3. Dropdown shows timer controls and quick session presets
4. User can pick a `25+5`, `35+10`, or `50+15` preset from the main screen
5. User starts a focus countdown
6. Focus completion alerts the user and waits for acknowledgement
7. Break countdown starts after acknowledgement
8. Break completion alerts the user and returns to idle

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
- add one-click `25+5`, `35+10`, and `50+15` quick presets to the main timer page
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
- settings UI for full focus/break preset selection, sound preferences, and Do Not Disturb toggle
- setup reminder and safe fallback when the Do Not Disturb automation is missing or broken
- in-dropdown settings page behavior
- keyboard shortcuts:
  - `Space`
  - `Tab`
  - `Shift+Tab`
  - `Left Arrow`
  - `Right Arrow`
  - `Esc`
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

## Task 7: Main-Screen Quick Session Presets

Status: completed

Implemented:

- expose `25+5`, `35+10`, and `50+15` paired presets on the timer page
- allow changing the next session in one click without visiting settings
- keep settings as the full editor for all supported focus and break presets
- disable quick preset changes while a timer is already running
- allow `Tab`, `Shift+Tab`, and left/right arrow keys to cycle the quick presets while the timer page is idle
- allow `Esc` to return from settings to the timer page and dismiss the timer surface from the main page

Key files:

- `Sources/PomodoroTimer/ContentView.swift`
- `Sources/PomodoroTimer/AppSettingsStore.swift`
- `Sources/PomodoroTimer/PomodoroViewModel.swift`
- `Tests/PomodoroTimerTests/AppSettingsStoreTests.swift`
- `Tests/PomodoroTimerTests/PomodoroViewModelTests.swift`

## Current MVP Definition

The MVP is done when:

- app launches into the menu bar
- app launches with no persistent Dock icon
- launching the app again opens a usable fallback control window when the menu bar item is not accessible
- the Dock icon appears only while the fallback control window is open
- user can click the tomato icon to open the dropdown
- user can switch between `25+5`, `35+10`, and `50+15` from the main timer page
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
