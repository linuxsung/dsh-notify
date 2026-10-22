# DSH Notify (한국어)

[English](README.md) | 한국어

> DeepSeek Harness용 Windows 오프피크 위젯 + 브라우저 알림 플러그인. 현재 릴리스: **v0.2.0**.

## 개요

DSH Notify는 DeepSeek Harness를 쓰는 동안 필요한 외부 상태와 알림을 로컬에서 처리하는 도구입니다.

- **Windows 위젯** — 트레이에 상주하며 현재 DeepSeek API 요금 구간, 다음 전환 시각, 남은 시간을 보여줍니다.
- **브라우저 플러그인** — `@nolit/dsh-notify-web`이 턴 완료·도구 승인·질문·오류를 Web Notifications와 Web Audio로 알립니다.
- **포터블 ZIP** — Windows 위젯은 GitHub Releases의 `DSH-Notify-Portable-0.2.0.zip`으로 배포됩니다. 설치 프로그램이나 관리자 권한이 필요 없습니다.
- **BYO 에셋** — 폰트·아이콘·오디오는 사용자가 직접 주입합니다. 패키지에는 제3자 폰트·로고·사운드 파일이 포함되지 않습니다.

## 피크/오프피크 일정 (UTC/CST)

DeepSeek API 요금의 공식 기준 달력은 **CST(UTC+8, Beijing Time)**이며, 구간 정의 자체는 **UTC**가 기준입니다. 위젯은 현재 구간을 기기 또는 감지된 지역 시간대로 변환해 표시합니다.

| CST (UTC+8) | UTC | 요금 |
|---|---|---|
| 00:00–09:00 | 16:00–01:00 | 50% 오프피크 |
| 09:00–12:00 | 01:00–04:00 | **100% 피크** |
| 12:00–14:00 | 04:00–06:00 | 50% 오프피크 |
| 14:00–18:00 | 06:00–10:00 | **100% 피크** |
| 18:00–24:00 | 10:00–16:00 | 50% 오프피크 |

토요일·일요일과 중국 공휴일은 종일 오프피크입니다. 공휴일 날짜는 UTC 날짜가 아니라 베이징(UTC+8) 달력일 기준으로 판정합니다. UI에 표시되는 현지 시각은 편의를 위한 변환이며, 기준 경계는 UTC/CST를 사용하세요.

## 포터블 빠른 시작

1. [Releases](https://github.com/linuxsung/dsh-notify/releases/tag/v0.2.0)에서 `DSH-Notify-Portable-0.2.0.zip`을 내려받습니다.
2. `SHA256SUMS.txt`와 대조해 무결성을 확인합니다(권장).
3. 쓰기 가능한 폴더에 압축을 풉니다.
4. `launch.js`를 더블클릭합니다. Windows Script Host/JScript로 실행되며 콘솔 창이 뜨지 않습니다.
5. 트레이 아이콘을 우클릭해 **부팅 시 자동 실행**, 표시 모드, 설정을 변경합니다.

요구 사항: Windows 10/11, PowerShell 7(`pwsh.exe`).

```powershell
winget install Microsoft.PowerShell
```

`start.cmd`는 디버그/복구용 폴백이며 cmd 창이 잠깐 보일 수 있습니다. 관리자 권한은 필요하지 않고, 관리자 셸에서 실행하면 UIPI 회피를 위해 Explorer를 통해 일반 권한으로 다시 실행됩니다.

## 브라우저 호환성

Chromium 계열(Google Chrome, Microsoft Edge, Naver Whale, Brave)에서 검증되었습니다. OS 알림 배너, 고유 태그 기반 중복 방지, Web Audio, 시스템 알림음이 정상 동작합니다.

- **Firefox**: 엄격한 자동 재생 차단으로 비동기 완료음이 무음이 될 수 있습니다. 사이트 자동 재생을 허용해야 합니다.
- **Safari(macOS/iOS)**: 백그라운드 탭 동결과 사용자 제스처 기반 미디어 정책으로 백그라운드 사운드가 제한될 수 있습니다.
- 그 외 브라우저는 보증하지 않으며 Chromium 기반 사용을 권장합니다.

### Chrome 재시작 요구 사항

알림은 보이는데 소리가 나지 않으면:

1. 주소창의 사이트 설정에서 **소리**를 **허용**으로 변경합니다.
2. 일반 새로고침(`F5`)으로는 Chrome 백그라운드 오디오 서비스가 갱신되지 않을 수 있습니다. 주소창에 `chrome://restart`를 입력해 Chrome을 완전히 재시작합니다.
3. DSH로 돌아와 플러그인의 **테스트 알림**을 실행합니다.

DSH 웹 UI와 포터블 위젯의 브라우저 알림 플러그인 모두에 적용됩니다.

## 문제 해결

| 증상 | 확인 |
|---|---|
| 브라우저 알림이 없음 | DSH 출처의 알림 권한, OS 집중 지원/방해 금지 모드를 확인합니다. |
| 알림은 뜨는데 소리가 없음 | 사이트 소리를 허용한 뒤 `chrome://restart`로 Chrome을 재시작합니다. |
| DSH에 플러그인이 보이지 않음 | web 프로필에서 `@nolit/dsh-notify-web` 번들이 켜져 있는지 확인하고 DSH 탭을 새로고침합니다. |
| 위젯이 시작되지 않음 | PowerShell 7(`pwsh -v`)을 확인하고, 진단용으로 `start.cmd`를 실행합니다. |
| `DSH-Notify.exe` 차단 | Smart App Control이 서명 없는 exe를 막는 경우입니다. 포터블 `launch.js` 방식을 사용하세요. |
| 표시 시각이 다름 | UI는 UTC/CST를 기기/감지 지역 시간대로 변환합니다. 위의 UTC 경계와 비교하세요. |
| DSH 탭을 닫으면 알림이 끊김 | 웹 플러그인은 서비스 워커 푸시 백엔드가 없어 DSH 탭이 열려 있을 때만 동작합니다. |

## 웹 플러그인

DSH 플러그인은 [`plugin/`](plugin/README.ko.md)에 있으며 패키지명은 `@nolit/dsh-notify-web@0.2.0`입니다.

```powershell
dsh plugin --profile web add @nolit/dsh-notify-web
```

로컬 체크아웃:

```powershell
dsh plugin --profile web add "link:C:\path\to\dsh-notify\plugin"
```

web 프로필에서 번들을 켜고 페이지를 새로고침하세요. 플러그인은 설정에 **알림** 섹션을 추가하며 사이드바/헤더 UI는 건드리지 않습니다.

## 저장소 구조

```text
app/        폰트 로더·트레이 연동
bridge/     선택형 DSH 이벤트 → Windows 토스트 브리지
build/      포터블 ZIP·exe 빌드 스크립트
docs/       설계·에셋 정책·시간대·릴리스 문서
notify/     팝업/토스트 헬퍼
plugin/     @nolit/dsh-notify-web (DSH 브라우저 플러그인)
providers/  DeepSeek 피크/오프피크 판정 엔진
tests/      PowerShell 판정/UI/패키지 테스트
ui/         WPF 인디케이터와 중립 아이콘
```

## 빌드

```powershell
pwsh -NoProfile -File build\build-portable.ps1
# dist\DSH-Notify-Portable\ + DSH-Notify-Portable-0.2.0.zip + SHA256SUMS.txt
```

포터블 ZIP에는 영문 `README.txt`와 한국어 `README.ko.txt`가 함께 포함됩니다.

## 라이선스

MIT. [LICENSE](LICENSE)와 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)를 참고하세요. DeepSeek 명칭과 상표는 각 권리자에게 있으며, 이 프로젝트는 공식 로고/브랜드 에셋을 번들하지 않습니다.
