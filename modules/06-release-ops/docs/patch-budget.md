# Patch Budget

## Thresholds

| Active patches | Policy |
|----------------|--------|
| 0-19 | 정상 운영 |
| 20-29 | 신규 기능보다 patch diet 우선 |
| 30+ | release freeze, 신규 patch 금지 |

## Patch metadata

모든 patch는 `patches/manifest.json`에 다음 정보를 가져야 한다.

- `id`
- `file`
- `tag`: `PR_safe` 또는 `Fork_only`
- `owner`
- `risk`
- `dependsOn`
- `upstreamPr`
- `dropWhen`
- `touches`

## Diet routine

분기마다 다음을 수행한다.

1. upstream에 머지된 patch drop
2. 같은 파일을 건드리는 patch 병합 검토
3. Fork_only patch가 여전히 필요한지 재검토
4. conflict surface가 큰 patch를 upstream PR로 전환
