# DSH Notify

[한국어](README.ko.md) | English

> Windows off-peak widget and browser notification plugin for DeepSeek Harness. Current release: **v0.2.0**.

## Overview

DSH Notify is a local-first notification companion for DeepSeek Harness:

- **Windows widget** — a tray-resident card that shows the current DeepSeek API billing window, the next change, and a countdown.
- **Browser plugin** — `@nolit/dsh-notify-web` notifies on turn completion, tool approvals, user questions, and errors through the Web Notifications API and Web Audio.
- **Portable ZIP** — the Windows widget is distributed as `DSH-Notify-Portable-0.2.0.zip` on GitHub Releases; no installer or administrator rights are required.
- **BYO assets** — fonts, icons, and audio are user-supplied. The package bundles no third-party font, logo, or sound file.

## Peak / Off-peak Schedule (UTC / CST)

DeepSeek API pricing uses **CST (UTC+8, Beijing Time)** as its official business calendar. The canonical definition is UTC; CST is the primary human-readable reference. The widget converts the active window to your device or detected region time zone.

| CST (UTC+8) | UTC | Rate |
|---|---|---|
| 00:00–09:00 | 16:00–01:00 | 50% off-peak |
| 09:00–12:00 | 01:00–04:00 | **100% peak** |
| 12:00–14:00 | 04:00–06:00 | 50% off-peak |
| 14:00–18:00 | 06:00–10:00 | **100% peak** |
| 18:00–24:00 | 10:00–16:00 | 50% off-peak |

Weekends and Chinese public holidays are off-peak for the full day. Holiday dates are evaluated on the Beijing (UTC+8) calendar, not the UTC date. When a local time is shown in the UI, it is a convenience conversion; use UTC or CST for the authoritative boundary.

## Portable Quick Start

1. Download `DSH-Notify-Portable-0.2.0.zip` from [Releases](https://github.com/linuxsung/dsh-notify/releases/tag/v0.2.0).
2. Verify it against `SHA256SUMS.txt` (optional but recommended).
3. Extract the ZIP to a writable folder.
4. Double-click `launch.js`. It uses Windows Script Host/JScript and opens no console window.
5. Right-click the tray icon to enable **Start with Windows**, change display mode, or open settings.

Requirements: Windows 10/11 and PowerShell 7 (`pwsh.exe`). Install PowerShell with:

```powershell
winget install Microsoft.PowerShell
```

`start.cmd` is a debug/recovery fallback and may briefly show a console window. Administrator rights are not required; launching from an elevated shell is de-elevated through Explorer to avoid UIPI issues.

## Browser Compatibility

Validated with Chromium-based browsers: Google Chrome, Microsoft Edge, Naver Whale, and Brave. OS notification banners, tag-based deduplication, Web Audio, and system notification sounds work as expected.

- **Firefox**: strict autoplay blocking may silence asynchronous completion sounds unless site autoplay is allowed.
- **Safari (macOS/iOS)**: background tab freezing and gesture-gated media policies can suppress background sound.
- Other browsers are not guaranteed; Chromium-based browsers are recommended.

### Chrome restart requirement

If notifications appear but sound is silent:

1. Open the site settings from the address-bar icon and set **Sound** to **Allow**.
2. A normal refresh (`F5`) does not restart Chrome's background audio service. Open `chrome://restart` in the address bar and let Chrome restart completely.
3. Return to DSH and use the plugin's **Test notification** action.

This applies to both the DSH web UI and the portable widget's browser notification plugin.

## Troubleshooting

| Symptom | Check |
|---|---|
| No browser notification | Allow notifications for the DSH origin in site settings; check OS Focus Assist / Do Not Disturb. |
| Notification appears, no sound | Set site sound to Allow, then restart Chrome with `chrome://restart`. |
| Plugin does not appear in DSH | Confirm `@nolit/dsh-notify-web` is enabled in the DSH web profile and reload the DSH tab. |
| Widget does not start | Verify PowerShell 7 (`pwsh -v`); try `start.cmd` for a visible diagnostic console. |
| `DSH-Notify.exe` blocked | Smart App Control blocks unsigned executables on some PCs. Use the portable `launch.js` flow instead. |
| Wrong displayed time | The UI converts UTC/CST to your device or detected region time zone; compare the UTC boundary above. |
| Notifications stop after closing the DSH tab | Expected: the web plugin has no service-worker push backend and runs only while a DSH tab is open. |

## Web Plugin

The DSH plugin lives in [`plugin/`](plugin/README.md) as `@nolit/dsh-notify-web@0.2.0`.

```powershell
dsh plugin --profile web add @nolit/dsh-notify-web
```

For a local checkout:

```powershell
dsh plugin --profile web add "link:C:\path\to\dsh-notify\plugin"
```

Then enable the bundle in the DSH web profile and reload the page. The plugin adds a **Notifications** section under Settings and never adds sidebar/header UI.

## Repository Layout

```text
app/        font loader and tray integration
bridge/     optional DSH event -> Windows toast bridge
build/      portable ZIP and executable build scripts
docs/       design, asset policy, timezone, and release notes
notify/     popup/toast helpers
plugin/     @nolit/dsh-notify-web (DSH browser plugin)
providers/  DeepSeek peak/off-peak decision engine
tests/      PowerShell decision/UI/package tests
ui/         WPF indicator and neutral icons
```

## Build

```powershell
pwsh -NoProfile -File build\build-portable.ps1
# dist\DSH-Notify-Portable\ + DSH-Notify-Portable-0.2.0.zip + SHA256SUMS.txt
```

The portable ZIP contains `README.txt` (English) and `README.ko.txt` (Korean).

## License

MIT. See [LICENSE](LICENSE) and [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md). DeepSeek names and marks belong to their respective owners; this project bundles no official logo or brand asset.
