# Pomodoro Timer QA Notes

## Scope

Final integration and QA pass for the macOS Pomodoro MVP.

## End-To-End Checks

- Launch app successfully with only the menu bar item visible
- Launch the app again and confirm the fallback control window opens in front
- Close the fallback control window and confirm the Dock icon disappears again
- Start focus session from button and with `Space`
- Reset from button and with `R`
- Open settings from gear button and `Cmd+,`
- Countdown updates in the UI
- Focus completion triggers:
  - in-app popup
  - dropdown remaining visible while the popup is onscreen
  - gentle sound if enabled
  - break waiting for user acknowledgement before countdown starts
- Break completion triggers:
  - completion alert
  - idle reset
  - timer returning to the currently selected focus preset
- Settings persist across launches for:
  - focus preset
  - break preset
  - sound toggle
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
- Added ticket-style issue log in `docs/issue_log.md` for notable resolved UI bugs

## Current Expected Behavior

- Focus timer ends, shows a popup, and waits for acknowledgement before break starts
- While the popup is visible, the dropdown timer panel is also shown
- After the popup is dismissed, the dropdown stays visible until the user clicks elsewhere or toggles the tomato icon
- Break timer ends and the app returns to idle
- If the user walks away, the app waits in idle for the next manual start
- User-selected focus and break presets persist across launches
- Packaging clears preferences on the build machine before generating a fresh app bundle

## Verification Commands

```bash
cd /Users/tangshua/Downloads/pomodoro
swift test
./scripts/package_app.sh
```
