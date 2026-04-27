# Upstream Sync — VoidLight CoDesign

> upstream(`OpenCoworkAI/open-codesign`)의 변경을 안전하게 병합하는 운영 매뉴얼.

---

## 1. Sync 주기

| 빈도 | 동작 | 트리거 |
|------|-----|-------|
| **매일** | upstream release/tag 감지 | GitHub Actions scheduled fetch |
| **변화량 임계치 도달** | dry-run sync PR 생성 | upstream main이 20 commits 이상 ahead |
| **보안/긴급 패치** | 즉시 sync PR 생성 | upstream Releases/advisory watch + 수동 |
| **메이저 버전 (0.x → 0.x+1)** | 검토 후 별도 upgrade PR | 수동, MODULES 영향 분석 후 |

기본은 upstream `main` 실시간 추종이 아니라 **release tag 우선 추종 + 필요한 hotfix cherry-pick**이다. main 추종은 developer preview에서만 허용한다.

---

## 2. 자동 워크플로우 (`.github/workflows/upstream-sync.yml`)

### 단계
```
1. upstream release/tag 또는 변화량 임계치 감지
2. 새 대상 SHA 발견 시:
   a. 임시 브랜치 upstream-sync/YYYY-MM-DD 생성
   b. submodule SHA만 갱신
   c. upstream/을 generated-app/으로 복사
   d. patches/manifest.json + series 검증
   e. patches/*.patch 를 generated-app에 적용 (git am --3way)
   f. overlays/ 적용
   g. parity/security/distribution gate 실행
   h. 통과 → develop 으로 PR 자동 생성
   i. 실패 → Issue 생성 + Telegram 알림 + stable channel freeze
3. develop 머지는 사람이 한다 (자동 머지 X)
4. main 자동 push 금지
```

### 충돌 분류
| 타입 | 처리 |
|------|------|
| **patch manifest 불일치** | `patches/manifest.json` 또는 `series` 수정 후 재실행 |
| **patches/*.patch 적용 실패** | 해당 patch 재작성 → PR 본문에 명시 |
| **parity test 실패** | upstream의 동작 변화 → modules 업데이트 필요 |
| **security gate 실패** | M07 checklist 해결 전 merge 금지 |
| **distribution gate 실패** | M04/M05 release metadata 수정 |
| **typescript 빌드 실패** | upstream의 API 변경 → patches 또는 modules 수정 |

---

## 3. 수동 sync 절차 (긴급 시)

```bash
cd ~/Projects/voidlight-codesign

# 1) upstream target SHA/tag 선택 후 submodule 갱신
# release tag 우선, main 직접 추종은 developer preview에서만 허용
git submodule update --init upstream

# 2) 임시 작업 브랜치
git switch -c upstream-sync/$(date +%Y-%m-%d)

# 3) generated-app 재생성
rm -rf generated-app
rsync -a upstream/ generated-app/

# 4) patch manifest 검증 + patches 재적용
pnpm verify:patches
cd generated-app
for p in ../patches/*.patch; do
  git am --3way "$p" || {
    echo "Conflict at $p — fix and re-run"
    exit 1
  }
done
cd ..

# 5) overlays 적용
./scripts/apply-modules.sh

# 6) 검증
pnpm install -r
pnpm verify:parity
pnpm verify:security
pnpm build

# 7) PR 생성
gh pr create --base develop --title "upstream-sync: $(date +%Y-%m-%d)" --body "..."
```

---

## 4. patch governance

### manifest 필수 필드

`patches/manifest.json`은 patch마다 다음 정보를 기록한다.

```json
{
  "id": "0001-i18n-introduce-locale-loader",
  "file": "0001-i18n-introduce-locale-loader.patch",
  "tag": "PR_safe",
  "owner": "core",
  "risk": "high",
  "dependsOn": [],
  "upstreamPr": null,
  "dropWhen": "upstream ships i18n runtime",
  "touches": ["apps/desktop/src/renderer"]
}
```

### patch budget

- 활성 patch 20개 초과: 신규 기능보다 patch diet 우선
- 활성 patch 30개 초과: release freeze, upstream PR/drop/rewrite 계획 수립 전 신규 patch 금지

## 5. patch 재작성 가이드

### 충돌 빈도가 높은 patch는 다음 후보:
- `0001-i18n-introduce-locale-loader.patch` — i18n 인프라 변경 시
- `0003-add-vibeproxy-preset-detection.patch` — provider 시스템 변경 시
- `0004-model-registry-allow-override-file.patch` — 카탈로그 구조 변경 시

### 재작성 절차
```bash
# 1) 충돌 patch를 unstage
cd upstream
git am --abort

# 2) 직접 변경 후 새 patch 추출
git apply --3way ../patches/0003-add-vibeproxy-preset-detection.patch
# (수동 충돌 해결)
git diff > /tmp/new.patch

# 3) 새 patch로 교체
mv /tmp/new.patch ../patches/0003-add-vibeproxy-preset-detection.patch

# 4) 검증
git am --abort  # 작업 트리 정리
git am --3way ../patches/0003-*
```

---

## 6. patch 단위 upstream PR 시나리오

각 patch는 **upstream PR 후보**다. 다음 조건이면 PR을 시도한다:

| 조건 | 권장 |
|------|-----|
| 100줄 미만 + 단일 책임 | ✅ PR 시도 |
| 신규 기능(i18n 인프라 등) | ✅ PR 시도, 거부 시 patch 유지 |
| 한국어 전용 자산 | ❌ PR 불필요 (modules/01 의 결과물만 PR) |
| 우리만 쓰는 우회 | ❌ PR 부적절 |

### upstream PR이 머지되면
1. patch 파일 삭제
2. ARCHITECTURE.md / MODULES.md에서 해당 항목 제거
3. CHANGELOG에 "upstream merged" 기록
4. → 우리 fork의 유지 비용 감소

---

## 7. 메이저 버전 (0.x → 0.x+1) 대응

### 사전 검토 체크리스트
- [ ] upstream CHANGELOG 정독
- [ ] 우리 patches 4개 각각이 영향 받는지 확인
- [ ] modules/ 의 빌드 산출물 경로 변경 여부
- [ ] tests/parity/ 에 추가할 시나리오
- [ ] i18n 키 변경 → ko.json 마이그레이션

### 절차
```
1. develop에서 분기: upgrade/v0.2-prep
2. 위 체크리스트 결과를 ISSUE로 기록
3. 단계적 patch 재작성
4. parity test 보강
5. 별도 PR로 머지
```

---

## 8. 알림 채널

| 이벤트 | 채널 | 누구 |
|--------|-----|-----|
| 자동 sync 성공 | (조용히) PR만 생성 | 팀 |
| 자동 sync 충돌 | Telegram | 사용자 (손상현) |
| upstream Release 감지 | Telegram | 사용자 |
| parity test 회귀 | Telegram + Issue + stable freeze | 사용자 |
| security/distribution gate 실패 | Telegram + Issue | 사용자 |

---

## 9. 의존성 정리

| 의존 | 사용처 | 핀(pin) 정책 |
|------|------|-------------|
| `OpenCoworkAI/open-codesign` | submodule | release tag 우선 + 명시적 SHA |
| `pnpm` | workspace | major version pin |
| `electron-builder` | upstream에서 사용 | upstream에 위임 |
| `vibeproxy` (CLIProxyAPI) | M02 호환성 | minor version compat-matrix |

---

## 10. 비상 절차 (Catastrophic Failure)

upstream이 라이선스 변경, 폐기, 또는 fork 불가능한 변경을 한 경우:

1. 마지막으로 호환되는 SHA에 submodule pin
2. patches/ 재정비 (해당 SHA 기준)
3. 결정: "long-term fork 모드" 진입 여부 사용자 결정
4. 그 시점부터 upstream sync 중단

→ 발생 가능성: 매우 낮음. MIT 라이선스이므로 라이선스 변경 위험은 사실상 없음.
