# Pomodoro Timer Issue Log

## PMD-001: First Menu Bar Dropdown Open Used a Different Position

Status: fixed

Reported: 2026-03-17

Area:

- menu bar dropdown positioning

Symptoms:

- after launching the app, the first click on the tomato icon opened the dropdown in a different horizontal position than later opens
- later toggles were consistent, but the first open could appear shifted relative to the menu bar icon
- this made the dropdown feel unstable compared with native menu bar apps

Root cause:

- the dropdown anchor was originally derived from the status button's internal bounds converted into screen coordinates
- on the first open after launch, AppKit had not always stabilized the status-item view geometry yet
- that meant the first position could be computed from stale or incomplete geometry, while later opens used settled geometry

Fix:

- wait briefly for the status-item window to exist before showing the dropdown
- anchor the panel from the status-item window frame on screen instead of the button's converted bounds
- run a few short post-show stabilization passes to correct the panel position once AppKit finishes settling the status item

Files changed:

- `Sources/PomodoroTimer/MenuBarController.swift`

Manual verification:

1. Quit the app completely.
2. Launch the app again.
3. Click the tomato icon once and note the dropdown position.
4. Click away to dismiss it.
5. Open it several more times.
6. Confirm the first open position matches the later opens.

Notes:

- this fix was implemented alongside a small UI correction that returned the `Quit` button to the same bordered style family as `Reset`
