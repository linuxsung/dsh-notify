<#
.SYNOPSIS    DSH Notify 윈도우 위젯의 포터블 패키지를 만든다.
.DESCRIPTION app\, providers\, ui\ 스크립트와 무음 진입점 launch.js를 dist\DSH-Notify-Portable에 모으고,
             금지 에셋(Digital-7/DeepSeek 로고/ding.wav/exe/vbs)을 제외한다. ZIP과 SHA256을 만든다.
.CONTRACT    core.ps1, app\font-loader.ps1, app\tray.ps1, launch.js, start.cmd
.INPUTS      -Version(기본 0.2.0), -OutRoot(기본 dist)
.OUTPUTS     dist\DSH-Notify-Portable\ (README.txt/README.ko.txt 포함), dist\DSH-Notify-Portable-<version>.zip, SHA256SUMS.txt
.SIDE-EFFECTS dist 폴더 생성/덮어쓰기.
.TESTS       tests\portable-package.ps1
.NOTES       공개 패키지에는 사용자 config/cache/fonts를 넣지 않는다.
#>

#region INDEX
#   Copy-RuntimeFile  런타임 파일 복사
#   (main)            stage → README/LICENSE → zip → SHA256
#endregion

param(
    [string] $Version = '0.2.0',
    [string] $OutRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($OutRoot)) { $OutRoot = Join-Path $repoRoot 'dist' }
$target = Join-Path $OutRoot 'DSH-Notify-Portable'
if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
New-Item -ItemType Directory -Path $target -Force | Out-Null

function Copy-RuntimeFile {
    param([string] $Relative, [string] $DestinationRoot = $target)
    $source = Join-Path $repoRoot $Relative
    if (-not (Test-Path -LiteralPath $source)) { return }
    $destination = Join-Path $DestinationRoot $Relative
    $directory = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
    Copy-Item -LiteralPath $source -Destination $destination -Force
}

foreach ($file in @('core.ps1', 'config.ps1', 'launch.js', 'start.cmd', 'LICENSE')) {
    Copy-RuntimeFile -Relative $file
}
foreach ($file in @('app\font-loader.ps1', 'app\tray.ps1')) {
    Copy-RuntimeFile -Relative $file
}
foreach ($file in @('ui\presenter.ps1', 'ui\indicator.ps1', 'ui\popup.ps1', 'ui\build-neutral-icons.ps1')) {
    Copy-RuntimeFile -Relative $file
}
Copy-RuntimeFile -Relative 'ui\icons\neutral-green.ico'
Copy-RuntimeFile -Relative 'ui\icons\neutral-red.ico'
foreach ($file in @('providers\deepseek-peak.ps1', 'providers\_template.ps1')) {
    Copy-RuntimeFile -Relative $file
}
foreach ($file in @('notify\toast.ps1', 'notify\send-toast.ps1', 'notify\popup.ps1', 'notify\peak-alert.ps1')) {
    Copy-RuntimeFile -Relative $file
}
New-Item -ItemType Directory -Path (Join-Path $target 'fonts') -Force | Out-Null

$readme = @'
DSH Notify v0.2.0 — Portable
================================
[한국어](README.ko.txt) | English

Overview
- Windows tray widget for DeepSeek API peak/off-peak billing windows.
- Browser notification plugin for DeepSeek Harness (turn, approval, question, error).
- Local-first: no local server, port, or IPC. No bundled third-party fonts, logos, or audio.

Requirements
- Windows 10/11
- PowerShell 7 or later (pwsh.exe)
  Install: winget install Microsoft.PowerShell

Quick start
1. Extract this ZIP to a writable folder.
2. Double-click launch.js (Windows Script Host/JScript; no console window).
   - start.cmd is a debug/recovery fallback and may briefly show a console window.
   - Administrator rights are not required. An elevated launch is de-elevated through Explorer (UIPI).
3. Right-click the tray icon to enable "Start with Windows", choose display mode, or open settings.

Peak / Off-peak Schedule (UTC / CST)
The official DeepSeek business calendar is CST (UTC+8, Beijing Time); UTC is the canonical boundary.
The widget converts the active window to your device or detected region time zone.
  CST (UTC+8)    UTC             Rate
  00:00-09:00    16:00-01:00     50% off-peak
  09:00-12:00    01:00-04:00     100% peak
  12:00-14:00    04:00-06:00     50% off-peak
  14:00-18:00    06:00-10:00     100% peak
  18:00-24:00    10:00-16:00     50% off-peak
Weekends and Chinese public holidays are off-peak all day. Holiday dates use the Beijing (UTC+8)
calendar, not the UTC date. A local time shown in the UI is a convenience conversion.

Browser compatibility (web notification plugin)
- Validated: Chromium-based browsers (Chrome, Edge, Whale, Brave) — OS banners, tag deduplication,
  Web Audio, and system notification sounds.
- Firefox: strict autoplay blocking can silence asynchronous completion sounds. Allow site autoplay.
- Safari (macOS/iOS): background tab freezing and gesture-gated media can limit background sound.
- Chromium-based browsers are recommended; other browsers are not guaranteed.

Chrome restart requirement (when sound is silent)
1. Open the address-bar site settings and set "Sound" to "Allow".
2. A normal refresh (F5) does not restart Chrome's background audio service.
   Open chrome://restart in the address bar and let Chrome restart completely.
3. Return to DSH and use the plugin's "Test notification" action.

Troubleshooting
- No browser notification: allow notifications for the DSH origin; check OS Focus Assist / Do Not Disturb.
- Notification but no sound: allow site sound, then restart Chrome with chrome://restart.
- Plugin missing in DSH: enable @nolit/dsh-notify-web in the web profile and reload the DSH tab.
- Widget does not start: verify pwsh -v reports PowerShell 7; try start.cmd for a visible diagnostic console.
- DSH-Notify.exe blocked: Smart App Control blocks unsigned executables; use the portable launch.js flow.
- Wrong displayed time: the UI converts UTC/CST to your device or detected region time zone.
- Notifications stop after closing the DSH tab: expected; the web plugin has no service-worker push backend.

Fonts (BYO)
- Default: Consolas/Segoe UI system fonts.
- To use a custom font (for example Digital-7), drag a .ttf/.otf file onto the widget window.
- Fonts are stored in fonts\custom\ and applied immediately. Licensing is the user's responsibility.
- If the app folder is not writable, fonts are stored under %LOCALAPPDATA%\DSH-Notify\fonts\.

Data
- Settings/cache live in the app folder when writable, otherwise under %LOCALAPPDATA%\DSH-Notify\.
- Uninstall: disable Start with Windows from the tray, then delete this folder.

License
- MIT. See LICENSE.
- No third-party font, logo, or audio file is bundled.
'@
$readme = $readme -replace 'v\d+\.\d+\.\d+', "v$Version"
Set-Content -LiteralPath (Join-Path $target 'README.txt') -Value $readme -Encoding UTF8

$readmeKo = @'
DSH Notify v0.2.0 — 포터블
================================
[English](README.txt) | 한국어

개요
- DeepSeek API 피크/오프피크 요금 구간을 보여주는 Windows 트레이 위젯.
- DeepSeek Harness용 브라우저 알림 플러그인(턴 완료·승인·질문·오류).
- 로컬 우선: 로컬 서버·포트·IPC를 사용하지 않으며, 제3자 폰트·로고·오디오를 번들하지 않습니다.

요구 사항
- Windows 10/11
- PowerShell 7 이상(pwsh.exe)
  설치: winget install Microsoft.PowerShell

빠른 시작
1. 이 ZIP을 쓰기 가능한 폴더에 압축 해제합니다.
2. launch.js를 더블클릭합니다(Windows Script Host/JScript, 콘솔 창 없음).
   - start.cmd는 디버그/복구용 폴백이며 cmd 창이 잠깐 보일 수 있습니다.
   - 관리자 권한은 필요하지 않습니다. 관리자 셸에서 실행하면 UIPI 회피를 위해 Explorer를 통해 일반 권한으로 다시 실행됩니다.
3. 트레이 아이콘을 우클릭해 "부팅 시 자동 실행", 표시 모드, 설정을 변경합니다.

피크/오프피크 일정 (UTC/CST)
DeepSeek의 공식 기준 달력은 CST(UTC+8, Beijing Time)이며, 구간 정의는 UTC가 기준입니다.
위젯은 현재 구간을 기기 또는 감지된 지역 시간대로 변환해 표시합니다.
  CST (UTC+8)    UTC             요금
  00:00-09:00    16:00-01:00     50% 오프피크
  09:00-12:00    01:00-04:00     100% 피크
  12:00-14:00    04:00-06:00     50% 오프피크
  14:00-18:00    06:00-10:00     100% 피크
  18:00-24:00    10:00-16:00     50% 오프피크
토요일·일요일과 중국 공휴일은 종일 오프피크입니다. 공휴일 날짜는 UTC 날짜가 아니라
베이징(UTC+8) 달력일 기준입니다. UI의 현지 시각은 편의를 위한 변환입니다.

브라우저 호환성(웹 알림 플러그인)
- 검증: Chromium 계열(Chrome, Edge, Whale, Brave) — OS 알림 배너, 태그 중복 방지, Web Audio, 시스템 알림음.
- Firefox: 엄격한 자동 재생 차단으로 비동기 완료음이 무음이 될 수 있습니다. 사이트 자동 재생을 허용하세요.
- Safari(macOS/iOS): 백그라운드 탭 동결과 사용자 제스처 기반 미디어 정책으로 백그라운드 사운드가 제한될 수 있습니다.
- Chromium 기반 사용을 권장하며 다른 브라우저는 보증하지 않습니다.

Chrome 재시작 요구 사항(소리가 나지 않을 때)
1. 주소창의 사이트 설정에서 "소리"를 "허용"으로 변경합니다.
2. 일반 새로고침(F5)으로는 Chrome 백그라운드 오디오 서비스가 갱신되지 않습니다.
   주소창에 chrome://restart를 입력해 Chrome을 완전히 재시작합니다.
3. DSH로 돌아와 플러그인의 "테스트 알림"을 실행합니다.

문제 해결
- 브라우저 알림이 없음: DSH 출처의 알림 권한과 OS 집중 지원/방해 금지를 확인합니다.
- 알림은 뜨는데 소리가 없음: 사이트 소리를 허용한 뒤 chrome://restart로 Chrome을 재시작합니다.
- DSH에 플러그인이 없음: web 프로필에서 @nolit/dsh-notify-web을 켜고 DSH 탭을 새로고침합니다.
- 위젯이 시작되지 않음: pwsh -v로 PowerShell 7을 확인하고, 진단용으로 start.cmd를 실행합니다.
- DSH-Notify.exe 차단: Smart App Control이 서명 없는 exe를 막는 경우입니다. 포터블 launch.js를 사용하세요.
- 표시 시각이 다름: UI는 UTC/CST를 기기/감지 지역 시간대로 변환합니다.
- DSH 탭을 닫으면 알림이 끊김: 웹 플러그인은 서비스 워커 푸시 백엔드가 없어 탭이 열려 있을 때만 동작합니다.

폰트 (BYO)
- 기본은 Consolas/Segoe UI 시스템 폰트입니다.
- Digital-7 등 외부 폰트를 쓰려면 .ttf/.otf 파일을 위젯 창 위로 끌어다 놓으세요.
- 폰트는 fonts\custom\에 저장되고 즉시 적용됩니다. 라이선스 책임은 사용자에게 있습니다.
- 앱 폴더가 쓰기 불가면 %LOCALAPPDATA%\DSH-Notify\fonts\에 저장됩니다.

데이터
- 설정/캐시는 앱 폴더가 쓰기 가능하면 그곳에, 아니면 %LOCALAPPDATA%\DSH-Notify\에 저장됩니다.
- 제거: 트레이에서 부팅 시 자동 실행을 끄고 이 폴더를 삭제합니다.

라이선스
- MIT. LICENSE 참조.
- 제3자 폰트·로고·오디오 파일을 번들하지 않습니다.
'@
$readmeKo = $readmeKo -replace 'v\d+\.\d+\.\d+', "v$Version"
Set-Content -LiteralPath (Join-Path $target 'README.ko.txt') -Value $readmeKo -Encoding UTF8

$notices = @'
DSH Notify — Third-Party Notices

This package does not include:
- Digital-7 or other third-party fonts (BYO)
- Official DeepSeek logos or icons
- ding.wav or other audio files

The default icons are neutral clock SVG/ICO assets released by this project under MIT.
Users are responsible for the licensing of fonts, icons, and audio they inject.
'@
Set-Content -LiteralPath (Join-Path $target 'THIRD-PARTY-NOTICES.md') -Value $notices -Encoding UTF8

$zip = Join-Path $OutRoot ("DSH-Notify-Portable-$Version.zip")
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
Compress-Archive -Path (Join-Path $target '*') -DestinationPath $zip -Force
$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
Set-Content -LiteralPath (Join-Path $OutRoot 'SHA256SUMS.txt') -Value ("{0}  {1}" -f $hash, (Split-Path -Leaf $zip)) -Encoding ASCII

Write-Host "OK: $target"
Write-Host "ZIP: $zip"
Write-Host "SHA256: $hash"
