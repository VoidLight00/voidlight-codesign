# Token Storage Policy

## 원칙

VoidLight CoDesign은 provider OAuth token이나 API key를 평문 파일에 저장하지 않는다.

## 요구 사항

- macOS: Keychain 또는 Electron safeStorage 확인
- Windows: DPAPI 또는 Electron safeStorage 확인
- Linux: libsecret 또는 사용자가 명시적으로 선택한 저장소
- logs/crash report에 token, account email, prompt 포함 금지
- logout/revoke flow 제공 여부 확인

## M0 확인 항목

- upstream이 token을 어디에 저장하는가?
- VibeProxy token 위치를 우리 코드가 직접 읽는가?
- config export/import에 secret이 포함되는가?
