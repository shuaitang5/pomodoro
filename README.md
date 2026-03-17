# Pomodoro Timer

Native macOS Pomodoro timer built with SwiftUI as a menu bar app.

## What It Does

- launches as a tomato icon in the macOS menu bar
- stays visible in the Dock as a fallback on crowded menu bars
- opens a dropdown panel when the icon is clicked
- opens a compact fallback control window when clicked from the Dock
- runs a focus timer and then an automatic break timer
- shows gentle alerts through notifications, popup alerts, and optional sound
- includes an in-dropdown settings page for timer presets and alert preferences
- packages as a double-clickable `.app`

## High-Level Architecture

### App Shell

- `Sources/PomodoroTimer/PomodoroTimerApp.swift`
- Defines the menu bar app using `MenuBarExtra`
- Adds the `Cmd+,` shortcut for settings
- Holds shared dropdown page state
- Reopens a fallback control window from Dock clicks

- `Sources/PomodoroTimer/AppEnvironment.swift`
- Holds the shared settings, page state, and timer view model used by both surfaces

- `Sources/PomodoroTimer/ControlWindowController.swift`
- Owns the compact fallback window that opens from Dock clicks

### Menu Bar Panel

- `Sources/PomodoroTimer/ContentView.swift`
- Renders the dropdown content shown from the menu bar icon
- Displays the timer page and the sliding settings page
- Shows the colorful tomato illustration inside the panel

- `Sources/PomodoroTimer/MenuPanelState.swift`
- Tracks whether the dropdown is showing the timer page or the settings page

### Timer Engine

- `Sources/PomodoroTimer/PomodoroEngine.swift`
- Pure timer state machine for:
  - idle
  - focus running
  - break running
- Handles countdown transitions and reset behavior

### View Model

- `Sources/PomodoroTimer/PomodoroViewModel.swift`
- Connects the timer engine to SwiftUI
- Formats timer text for the UI
- Runs the repeating timer
- Triggers notifications and popup alerts on transitions
- Makes sure reset and post-break idle return to the current selected focus preset

### Settings

- `Sources/PomodoroTimer/AppSettingsStore.swift`
- Stores saved user preferences in `UserDefaults`
- Handles saved focus and break presets plus alert toggles

- `Sources/PomodoroTimer/SettingsView.swift`
- Settings page UI for choosing presets and alert behavior

### Notifications

- `Sources/PomodoroTimer/NotificationManager.swift`
- Wraps macOS notifications and the gentle completion sound

## Presets And Behavior

- Focus presets: `15, 20, 25, 30, 35, 40, 45, 50`
- Break presets: `5, 10, 15`
- Default values: `25` focus, `5` break
- User-selected presets persist across launches
- After a full focus+break cycle, the app returns to idle using the currently selected focus preset

## Shortcuts

- `Space`: start
- `R`: reset
- `Cmd+,`: switch to settings

## Development

Run the app:

```bash
cd /Users/stang/Downloads/leetcode_grind
swift run
```

Run tests:

```bash
cd /Users/stang/Downloads/leetcode_grind
swift test
```

## Packaging

Build a fresh app bundle:

```bash
cd /Users/stang/Downloads/leetcode_grind
./scripts/package_app.sh
```

Output:

- `dist/PomodoroTimer.app`

Notes:

- Bundle identifier: `com.pomodorotimer.app`
- The packaged app uses the menu bar as the main UI and keeps a Dock fallback
- The packaging script builds a universal macOS app with both `arm64` and `x86_64` slices
- The packaging script clears saved preferences on the machine running the script before creating a fresh app bundle

## Tests

Tests live in `Tests/PomodoroTimerTests`.

Coverage includes:

- timer engine countdown logic
- focus-to-break transitions
- reset behavior
- saved settings behavior
- view model integration flow
