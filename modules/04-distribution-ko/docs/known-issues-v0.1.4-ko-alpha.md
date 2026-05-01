# 알려진 문제 — VoidLight CoDesign v0.1.4-ko-alpha

| 항목 | 값 |
|---|---|
| 버전 | 0.1.4-ko-alpha |
| 채널 | alpha-ko |

---

## 빌드 및 설치

| ID | 영역 | 설명 | 우선순위 |
|---|---|---|---|
| KI-001 | 설치 | 미서명·미공증 빌드. macOS Gatekeeper가 실행을 차단할 수 있음. 설치 가이드에서 Gatekeeper/격리 속성 해제 방법을 확인하십시오. | 높음 |
| KI-002 | 설치 | Homebrew Cask는 PoC 상태. `sha256 :no_check` 사용 중이며 release asset 업로드와 SHA256 고정 전에는 운영 배포용으로 사용할 수 없습니다. | 높음 |
| KI-003 | 업데이트 | alpha-ko 채널은 자동 업데이트를 제공하지 않음. 새 릴리스는 수동 재설치가 필요합니다. | 중간 |

## Provider 연결

| ID | 영역 | 설명 | 우선순위 |
|---|---|---|---|
| KI-010 | Provider | VibeProxy / CLIProxyAPI는 실험적 경로입니다. 기본 local proxy 감지는 localhost `8317/8318` 기준이며, 비표준 포트나 커스텀 relay는 일반 네트워크 오류로 보일 수 있습니다. | 중간 |
| KI-011 | Provider | official API key fallback 경로는 유지되지만, 일부 엔드포인트에서는 최초 연결 시 응답 지연이 있을 수 있습니다. | 낮음 |

## About / 라이선스 표기

| ID | 영역 | 설명 | 우선순위 |
|---|---|---|---|
| KI-020 | About 패널 | 기본 OS About 패널은 제공되지만, NOTICE 전문 뷰나 상세 attribution 탐색 UI는 아직 없습니다. 자세한 라이선스 내용은 배포 패키지의 NOTICE와 이 문서를 함께 확인해야 합니다. | 중간 |

## 범위 밖 (v1.0 이후 계획)

- 코드 서명 및 Apple Notarization
- 자동 업데이트 (stable-ko 채널)
- About 패널 내 상세 NOTICE/attribution 탐색 UI
- Homebrew Cask sha256 고정 및 tap 정식 공개

---

## 문제 보고

이슈는 https://github.com/VoidLight00/voidlight-codesign/issues 에 제출하십시오.
