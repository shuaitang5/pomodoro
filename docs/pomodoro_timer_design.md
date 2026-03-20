# Pomodoro Timer Design Doc

## Goal

Build a simple native macOS Pomodoro app that lives in the system menu bar.

Core flow:

1. User opens the app
2. App appears as a tomato icon in the macOS menu bar
3. User clicks the icon to open a dropdown panel
4. User starts a focus timer from the dropdown
5. Focus completion alerts the user and waits for acknowledgement
6. After acknowledgement, break countdown starts
7. Break completion alerts the user and returns to idle

## Chosen Product Shape

- Menu bar app with a temporary Dock fallback
- No normal main app window on launch
- Tomato icon in the macOS menu bar
- No Dock icon on normal launch
- Countdown timer shown inside the dropdown panel when the icon is clicked
- Settings live inside the same dropdown panel as a second page
- Launching the app again opens a compact fallback control window when the menu bar icon is not accessible
- The Dock icon is visible only while the fallback control window is open

## Menu Bar Behavior

The menu bar itself shows:

- a monochrome tomato icon

The dropdown panel shows:

- a main timer page with countdown, status, `Start`, `Reset`, `Settings`, and `Quit`
- a settings page with focus, break, and sound controls
- an optional Do Not Disturb during focus toggle that uses named Shortcuts
- the panel aligns to the left edge of the menu bar icon by default and flips to right-edge alignment when the icon is near the screen edge

When the user clicks `Settings`:

- the dropdown stays open
- the settings page slides in from the right

When the user clicks `Done` in settings:

- the timer page slides back in

## Focus And Break Durations

- Default focus length: `25` minutes
- Default break length: `5` minutes
- Focus presets: `5, 15, 20, 25, 30, 35, 40, 45, 50`
- Break presets: `5, 10, 15`

The app remembers the user's last selected focus and break presets across launches.

## Alerts

When focus ends:

- always show an in-app popup window
- show the dropdown timer panel together with the popup
- play a gentle sound if enabled
- optionally run the Do Not Disturb off shortcut
- wait for the user to acknowledge the popup before starting the break timer

When break ends:

- show the same style of popup
- reset to idle
- return the timer to the currently selected focus preset

## Settings

The settings page lets the user control:

- focus preset
- break preset
- gentle sound on/off
- Do Not Disturb during focus on/off
- a setup reminder if the required Shortcuts are missing when the toggle is turned on
- fit all controls without requiring scrolling

## Shortcuts

- `Space`: start a session
- `R`: reset the timer
- `Cmd+,`: switch the dropdown to the settings page

## Technical Design

- `NSStatusItem` plus a custom `NSPanel` for the menu bar entry point
- `NSWindow` fallback for relaunches when the menu bar item is not accessible
- `SwiftUI` for the dropdown content, popup content, and in-panel settings page
- `PomodoroEngine` for timer state and transitions
- `PomodoroViewModel` for UI-facing behavior
- `NotificationManager` for gentle sound delivery
- `DoNotDisturbShortcutController` for optional Shortcuts-based DND automation
- `AppSettingsStore` for saved user preferences
- shared app state so the menu bar and temporary Dock fallback stay in sync

If the required Shortcuts automation is missing, the app falls back to a normal Pomodoro session and leaves Do Not Disturb unchanged.

## Packaging

- App bundle identifier: `com.pomodorotimer.app`
- Packaged output: `dist/PomodoroTimer.app`
- Packaging script builds a universal Mac app with `arm64` and `x86_64` slices
- Packaging script clears local preferences on the machine that builds the app, then creates a fresh `.app`
