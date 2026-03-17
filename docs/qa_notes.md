# Pomodoro Timer QA Notes

## Scope

Final integration and QA pass for the macOS Pomodoro MVP.

## End-To-End Checks

- Launch app window successfully
- Start focus session from button and with `Space`
- Reset from button and with `R`
- Open settings from gear button and `Cmd+,`
- Countdown updates in the UI
- Focus completion triggers:
  - break transition
  - notification if enabled
  - in-app alert if enabled
  - gentle sound if enabled
- Break completion triggers:
  - completion alert
  - idle reset
  - timer returning to the currently selected focus preset
- Settings persist across launches for:
  - focus preset
  - break preset
  - alert toggles
- Invalid saved duration values fall back to:
  - `25` focus
  - `5` break
- `.app` packaging succeeds

## Bugs Fixed During QA

- Fixed settings crash caused by recursive `didSet` writes
- Replaced free-form duration changes with preset values
- Added app-level settings shortcut with `Cmd+,`
- Added keyboard shortcuts for `Start` and `Reset`
- Fixed idle timer after full cycle so it returns to the current selected focus preset
- Switched bundle ID to `com.pomodorotimer.app`

## Current Expected Behavior

- Focus timer ends and automatically starts break timer
- Break timer ends and the app returns to idle
- If the user walks away, the app waits in idle for the next manual start
- User-selected focus and break presets persist across launches
- Packaging clears preferences on the build machine before generating a fresh app bundle

## Verification Commands

```bash
cd /Users/stang/Downloads/leetcode_grind
swift test
./scripts/package_app.sh
```
