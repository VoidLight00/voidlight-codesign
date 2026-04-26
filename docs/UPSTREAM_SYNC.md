# Upstream Sync — VoidLight CoDesign

> upstream(`OpenCoworkAI/open-codesign`)의 변경을 안전하게 병합하는 운영 매뉴얼.

---

## 1. Sync 주기

| 빈도 | 동작 | 트리거 |
|------|-----|-------|
| **매주 월 09:00 KST** | 자동 rebase 시도 | GitHub Actions cron |
| **보안/긴급 패치** | 즉시 sync | upstream Releases watch + 수동 |
| **메이저 버전 (0.x → 0.x+1)** | 검토 후 sync | 수동, MODULES 영향 분석 후 |

---

## 2. 자동 워크플로우 (`.github/workflows/upstream-sync.yml`)

### 단계
```
1. submodule update --remote upstream/
2. 새 commit 발견 시:
   a. 임시 브랜치 upstream-sync/YYYY-MM-DD 생성
   b. patches/*.patch 를 다시 적용 (git am --3way)
   c. overlays/ 적용
   d. parity test 실행
   e. 통과 → develop 으로 PR 자동 생성
   f. 실패 → Issue 생성 + Telegram 알림
3. develop 머지는 사람이 한다 (자동 머지 X)
```

### 충돌 분류
| 타입 | 처리 |
|------|------|
| **patches/*.patch 적용 실패** | 해당 patch 재작성 → PR 본문에 명시 |
| **parity test 실패** | upstream의 동작 변화 → modules 업데이트 필요 |
| **typescript 빌드 실패** | upstream의 API 변경 → patches 또는 modules 수정 |

---

## 3. 수동 sync 절차 (긴급 시)

```bash
cd ~/Projects/voidlight-codesign

# 1) submodule을 최신 upstream/main으로
git submodule update --remote upstream

# 2) 임시 작업 브랜치
git switch -c upstream-sync/$(date +%Y-%m-%d)

# 3) patches 재적용
cd upstream
for p in ../patches/*.patch; do
  git am --3way "$p" || {
    echo "Conflict at $p — fix and re-run"
    exit 1
  }
done
cd ..

# 4) overlays 적용
./scripts/apply-modules.sh

# 5) 검증
pnpm install -r
pnpm test:parity
pnpm build

# 6) PR 생성
gh pr create --base develop --title "upstream-sync: $(date +%Y-%m-%d)" --body "..."
```

---

## 4. patch 재작성 가이드

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

## 5. patch 단위 upstream PR 시나리오

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

## 6. 메이저 버전 (0.x → 0.x+1) 대응

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

## 7. 알림 채널

| 이벤트 | 채널 | 누구 |
|--------|-----|-----|
| 자동 sync 성공 | (조용히) PR만 생성 | 팀 |
| 자동 sync 충돌 | Telegram | 사용자 (손상현) |
| upstream Release 감지 | Telegram | 사용자 |
| parity test 회귀 | Telegram + Issue | 사용자 |

---

## 8. 의존성 정리

| 의존 | 사용처 | 핀(pin) 정책 |
|------|------|-------------|
| `OpenCoworkAI/open-codesign` | submodule | 명시적 SHA |
| `pnpm` | workspace | major version pin |
| `electron-builder` | upstream에서 사용 | upstream에 위임 |
| `vibeproxy` (CLIProxyAPI) | M02 호환성 | minor version compat-matrix |

---

## 9. 비상 절차 (Catastrophic Failure)

upstream이 라이선스 변경, 폐기, 또는 fork 불가능한 변경을 한 경우:

1. 마지막으로 호환되는 SHA에 submodule pin
2. patches/ 재정비 (해당 SHA 기준)
3. 결정: "long-term fork 모드" 진입 여부 사용자 결정
4. 그 시점부터 upstream sync 중단

→ 발생 가능성: 매우 낮음. MIT 라이선스이므로 라이선스 변경 위험은 사실상 없음.
