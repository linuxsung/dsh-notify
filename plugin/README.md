# DSH Notify Web

[한국어](README.ko.md) | English

> Browser-only turn, approval, question, and error notifications for DeepSeek Harness. Package: `@nolit/dsh-notify-web@0.2.0`.

## Overview

DSH Notify Web adds browser notifications and Web Audio chimes to DeepSeek Harness. It is a pure client plugin: no local app, port, IPC, file queue, or system dependency.

| DSH event | Notification |
|---|---|
| `api-session/status` (`running=false`) | Turn complete. Root sessions only; 5-second cooldown. |
| `api-session/error` | Error. Message truncated to 160 characters. |
| `approval/request` | Approval needed. Notifies, then immediately calls `next()`. |
| `user-questions/request` | Question pending. Notifies, then immediately calls `next()`. |

- Only one tab owns notifications when several DSH tabs are open (Web Locks with a localStorage fallback).
- If Notification is denied or unsupported, the plugin falls back to an in-page toast on `shell.overlay`.
- The default sound is a synthesized two-tone Web Audio chime. A user-supplied audio file can be stored in IndexedDB; no audio file is bundled.
- `agent/turn-stopping` and `agent/error` are not used: the former is serial, the latter is not delivered to the browser.

## Install

Local checkout:

```powershell
dsh plugin --profile web add "link:C:\path\to\dsh-notify\plugin"
```

Then enable `@nolit/dsh-notify-web` in the web profile's `dsh.profile.bundles` (or from the DSH Plugins page).

After an npm release:

```powershell
dsh plugin --profile web add @nolit/dsh-notify-web
```

Reload the DSH page after installing. If `lib/client.js` is missing or invalid, only the plugin is disabled; the DSH core keeps running.

## Settings and Permissions

- **Settings → Notifications** adds a section to the official DSH Settings modal: permissions, sound, filters, BYO audio, and test notifications.
- The plugin never requests notification permission automatically. A one-time consent card in the lower-right corner runs `requestPermission()` and `AudioContext.resume()` from the same user gesture.
- Choosing **Later** hides the card permanently; settings remain available under Settings → Notifications.
- Browser/OS notification settings, Focus Assist, and tab muting can still suppress display or sound. The plugin cannot guarantee delivery.
- Changing the DSH port or origin creates a new origin; permissions and sound must be enabled again.
- The plugin adds no sidebar footer or header UI.

## Browser Compatibility

Validated with Chromium-based browsers: Google Chrome, Microsoft Edge, Naver Whale, and Brave.

- **Firefox**: strict autoplay blocking may silence asynchronous completion sounds unless site autoplay is allowed.
- **Safari (macOS/iOS)**: background tab freezing and gesture-gated media policies can suppress background sound.
- Other browsers are not guaranteed; Chromium-based browsers are recommended.

### Chrome restart requirement

If notifications appear but sound is silent:

1. Open the site settings from the address-bar icon and set **Sound** to **Allow**.
2. A normal refresh (`F5`) does not restart Chrome's background audio service. Open `chrome://restart` and let Chrome restart completely.
3. Return to DSH and run **Test notification** in Settings → Notifications.

## Limitations

- Notifications work only while a DSH tab is open. Closing or discarding the tab stops them; there is no service-worker push backend.
- Background timer throttling, browser notification policy, and OS Do Not Disturb can delay or suppress notifications.
- Approval/question notifications do not replace DSH approval UI; they notify and immediately pass through `next()`.
- Notification bodies contain fixed copy plus an 80-character session title. Prompts, code, and tool arguments are not included.

## Privacy

- No new `fetch`, `XMLHttpRequest`, `WebSocket`, or `EventSource` connections.
- No filesystem, `%LOCALAPPDATA%`, local port, or IPC access.
- Settings and consent state live in browser `localStorage`.
- User-supplied audio bytes live only in browser `IndexedDB` (`dsh-notify-web/audio`) and are never sent outside the browser.
- No external links are opened. Clicking a notification only focuses the DSH tab.

## Development

```powershell
node --test .\plugin\test\client.test.mjs
```

The tests replace browser APIs (Notification, AudioContext, localStorage, Web Locks) with mocks and verify event filtering, cooldowns, approval pass-through, fallbacks, the tab leader, and settings.

## License and Assets

- Code: MIT. See [LICENSE](LICENSE).
- The package bundles **no fonts, logos, or sound files**. The default icon is a neutral clock SVG; notifications specify no custom icon.
- User-supplied fonts/icons/audio remain the user's responsibility for licensing and redistribution. See the repository's [asset policy](../docs/2026-10-23-asset-policy.md).
- No official DeepSeek logo or trademark asset is included.

## Structure

- `lib/client.js`
  - `createNotifyCore()` — headless engine independent of React/slots. Handles event filters, cooldowns, permissions, Web Audio, IndexedDB, localStorage, tab leadership, and the toast queue.
  - `makeSettingsSection()` — `settings.section` adapter; subscribes to state and renders only the form.
  - `makeOverlay()` — `shell.overlay` adapter; renders the first-use consent card and fallback toast.
- `lib/index.js` — no-op host entry for the Loader. No communication, file, or port code.
- UI does not use `sidebar.footer.action` or `conversation.header`.
