# Pomodoro Timer

Simple macOS Pomodoro timer that lives as a system menu bar icon.

## Overview

Pomodoro Timer sits in the macOS menu bar as a tomato icon. Click the icon to open the dropdown timer, start a focus session, adjust your focus and break lengths, and reset whenever you want.

By default the app stays out of the Dock. If your menu bar is too full and the tomato icon is not accessible, launch the app again to open the fallback window in front. Closing that fallback window removes the Dock icon again.

The app shows popup alerts when a focus session or break ends. After a focus session ends, the break timer waits until you acknowledge the popup.

## Screenshot

![Pomodoro Timer dropdown](docs/images/screenshot.png)

## What You Can Do

- start and reset the timer directly from the dropdown
- choose your preferred focus length
- choose your preferred break length
- keep the timer accessible from the menu bar
- optionally play a gentle sound when a session ends

## Keyboard Shortcuts

- `Space` to start
- `R` to reset
- `Cmd+,` to open settings

## Settings

You can change:

- focus length
- break length
- sound on or off

## Run Locally

```bash
cd /Users/tangshua/Downloads/pomodoro
swift run
```

## Build The App

```bash
cd /Users/tangshua/Downloads/pomodoro
./scripts/package_app.sh
```
