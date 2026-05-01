# 업데이트 채널 정책

VoidLight CoDesign은 upstream Open CoDesign과 혼동되지 않도록 별도 앱 메타데이터와 업데이트 채널을 사용한다. 알파 단계에서는 자동 업데이트보다 **수동 업데이트 안내**를 우선한다.

## 채널 구분

| 채널 | 대상 | 안정성 | 배포 방식 |
|---|---|---|---|
| `alpha-ko` | 내부/초기 한국어 테스터 | 낮음 | 수동 다운로드, Homebrew Cask PoC |
| `beta-ko` | 공개 베타 후보 | 중간 | 서명 상태 확인 후 제한 배포 |
| `stable-ko` | v1.0 이후 일반 사용자 | 높음 | signed/notarized 또는 동등 정책 필요 |

## 기본 정책

- `alpha-ko`는 자동 업데이트를 기본 제공하지 않는다.
- `stable-ko`는 upstream sync 실패, 보안 이슈, provider 장애 시 freeze 가능해야 한다.
- channel metadata는 앱 내부 About, 릴리스 노트, Homebrew Cask 문구와 일치해야 한다.
- VibeProxy 호환성 문제는 업데이트 강제 사유가 아니라 경고 및 fallback 안내 사유로 취급한다.

## Provider 연결 정책

- official API key fallback은 모든 채널에서 first-class 경로로 유지한다.
- VibeProxy/CLIProxyAPI는 experimental 경로이며 provider ToS와 계정 정책 리스크를 고지한다.
- 자동 업데이트나 채널 전환이 사용자의 provider 설정, token, API key를 임의 변경해서는 안 된다.

## Freeze 조건

다음 상황에서는 `stable-ko` 승격 또는 배포를 중단한다.

- upstream sync 후 parity test가 실패한 경우
- patch queue 적용 또는 manifest 검증이 실패한 경우
- token 평문 저장 가능성이 발견된 경우
- local proxy detection에서 handshake/origin/port spoofing 검증이 약화된 경우
- NOTICE/About 라이선스 표기가 누락된 경우
- signed/notarized 정책과 실제 배포물이 불일치하는 경우

## 운영 메모

- 자동화는 PR 생성까지만 허용하고 자동 머지는 금지한다.
- channel 변경은 릴리스 담당자가 리뷰한다.
- alpha 사용자는 문서만 보고 설치, 첫 실행, provider 연결까지 도달할 수 있어야 한다.
