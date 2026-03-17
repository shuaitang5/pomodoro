# Pomodoro Timer Design Doc

## Goal

Build a simple native macOS Pomodoro app that lives in the system menu bar.

Core flow:

1. User opens the app
2. App appears as a tomato icon in the macOS menu bar
3. User clicks the icon to open a dropdown panel
4. User starts a focus timer from the dropdown
5. Focus completion alerts the user and starts break countdown
6. Break completion alerts the user and returns to idle

## Chosen Product Shape

- Menu bar app only
- No normal main app window on launch
- Tomato icon in the macOS menu bar
- Countdown timer shown inside the dropdown panel when the icon is clicked
- Settings live inside the same dropdown panel as a second page

## Menu Bar Behavior

The menu bar itself shows:

- a monochrome tomato icon

The dropdown panel shows:

- a main timer page with countdown, status, `Start`, `Reset`, `Settings`, and `Quit`
- a settings page with focus, break, and alert controls

When the user clicks `Settings`:

- the dropdown stays open
- the settings page slides in from the right

When the user clicks `Done` in settings:

- the timer page slides back in

## Focus And Break Durations

- Default focus length: `25` minutes
- Default break length: `5` minutes
- Focus presets: `15, 20, 25, 30, 35, 40, 45, 50`
- Break presets: `5, 10, 15`

The app remembers the user's last selected focus and break presets across launches.

## Alerts

When focus ends:

- show a macOS notification if enabled
- show an in-app alert if enabled
- play a gentle sound if enabled
- automatically start the break timer

When break ends:

- show the same style of alert
- reset to idle
- return the timer to the currently selected focus preset

## Settings

The settings page lets the user control:

- focus preset
- break preset
- macOS notifications on/off
- in-app popup alerts on/off
- gentle sound on/off
- fit all controls without requiring scrolling

## Shortcuts

- `Space`: start a session
- `R`: reset the timer
- `Cmd+,`: switch the dropdown to the settings page

## Technical Design

- `MenuBarExtra` for the menu bar app entry point
- `SwiftUI` for the dropdown panel and in-panel settings page
- `PomodoroEngine` for timer state and transitions
- `PomodoroViewModel` for UI-facing behavior
- `NotificationManager` for notification and sound delivery
- `AppSettingsStore` for saved user preferences

## Packaging

- App bundle identifier: `com.pomodorotimer.app`
- Packaged output: `dist/PomodoroTimer.app`
- Packaging script builds a universal Mac app with `arm64` and `x86_64` slices
- Packaging script clears local preferences on the machine that builds the app, then creates a fresh `.app`
