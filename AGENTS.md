# Agent Entry Point

이 파일은 Qwen3-TTS-custom에서 Agent가 항상 먼저 읽는 최소 진입점이다. 모든 기준 문서를 기본으로 읽지 말고, 아래 route에서 현재 작업에 필요한 파일만 연다.

## Repository contract

- 이 저장소는 `QwenLM/Qwen3-TTS`의 사용자 Fork다.
- `main`은 upstream 추적 기준선으로 보호하고, 사용자 변경은 active `work/*`에서 진행한다.
- 작업 시작 시 repository identity, `origin`, 가능한 경우 `upstream`, 현재 branch/working tree, 최신 `origin/main`, active `work/*`의 merge-base와 ahead/behind를 확인한다.
- 로컬 working tree를 직접 확인할 수 없는 환경에서는 clean/staged/untracked 상태를 추정하지 말고 환경 제한으로 보고한다.
- upstream 원본 기능을 먼저 보호한다. 대규모 원본 재작성보다 wrapper, UI, 설정, adapter 계층의 최소 변경을 우선한다.
- 모델 가중치, cache, `.venv`, 생성 음성, 참조 음성, 저장된 voice-clone prompt와 개인 음성 자산은 Git에 넣지 않는다.
- voice cloning 검증은 본인 또는 명시적 사용 권한이 있는 음성만 기본값으로 한다.
- `ai-video-maker`는 Qwen 내부 모듈에 직접 결합하지 않고 얇은 TTS adapter 경계를 통해 연동한다. 실제 필요가 확인되기 전 범용 provider 계층이나 자동 fallback을 만들지 않는다.
- FlashAttention, quantization, offload, compile 같은 최적화는 현재 PyTorch/CUDA/GPU와 공식 지원 및 실측 효과를 확인한 뒤 적용한다.
- main 통합, VERSION 증가, tag, GitHub Release, 공식 배포는 명시적 승인 없이 수행하지 않는다.
- force push, history rewrite, `reset --hard`, 자동 stash, 자동 conflict 해결을 사용하지 않는다.

## Canonical routes

| 역할 | 기준 경로 | 읽는 경우 |
|---|---|---|
| current-state | `AI_CONTEXT.md` | 현재 구현 상태나 로컬 검증 기준을 복구할 때 |
| architecture | `docs/ARCHITECTURE.md` | component, ownership, data flow, boundary를 변경하거나 판단할 때 |
| decisions | `docs/DECISIONS.md` | 장기 제품/architecture/안전 결정을 확인하거나 추가할 때 |
| next-work | `docs/NEXT_WORK.md` | 다음 실행 작업을 선택하거나 Goal mode로 진행할 때 |
| goal-execution | `docs/GOAL_EXECUTION.md` | Goal/연속 실행 요청일 때 |
| harness-lessons | `docs/HARNESS_LESSONS.md` | 반복 검증 실패, Windows/Git/harness 문제를 다룰 때 |
| change-history | `CHANGELOG.md` | 완료 변경/릴리스 이력을 확인할 때 |
| package-version | `pyproject.toml` + `VERSION` | package/release 상태를 확인할 때 |
| harness-entrypoint | `scripts/check_harness.ps1` | 구조/안전계약 검증 시 |

`pyproject.toml`의 `[project].version`이 package version의 source of truth다. `VERSION`은 공통 Agent route용 mirror이며 Harness가 둘의 일치를 검사한다.

## Task routing

### 일반 범위 수정

`AGENTS.md` → 관련 코드 → 직접 caller/dependency → focused tests.

`NEXT_WORK`, Goal 정책, 전체 architecture/history는 현재 수정에 필요하지 않으면 읽지 않는다.

### Goal / 다음 작업 연속 실행

`AGENTS.md` → `docs/GOAL_EXECUTION.md` → `docs/NEXT_WORK.md` → 선택된 작업에 필요한 route.

### 현재 상태 복구

`AGENTS.md` → `AI_CONTEXT.md` → 상태를 결정하는 실제 코드/설정.

환경/브랜치/성능 수치는 필요하면 다시 실행 확인한다.

### Architecture / 장기 제품 결정

`AGENTS.md` → `docs/ARCHITECTURE.md` → `docs/DECISIONS.md` → 관련 코드/테스트.

### Harness / 반복 실패

`AGENTS.md` → `docs/HARNESS_LESSONS.md` → `scripts/check_harness.ps1` → 직접 관련 파일.

### Release / history 확인

`AGENTS.md` → `pyproject.toml` + `VERSION` → `CHANGELOG.md` → 필요한 upstream/release 자료.

### Upstream 동기화

현재 `origin/main`과 공식 upstream `main`을 먼저 비교한다. upstream 변경과 사용자 기능 작업을 한 작업으로 섞지 않는다. 충돌 가능성이 있으면 자동 해결하지 않는다.

### Runtime/optimization 아이디어 검토

실제 병목이나 후속 운영 아이디어를 검토할 때만 `docs/IDEA_CANDIDATES.md`를 읽는다. 이 파일은 실행 큐가 아니며 `docs/NEXT_WORK.md`를 대체하지 않는다.

## Verification

문서/Harness 구조를 바꾼 뒤에는 최소한 `scripts/check_harness.ps1`을 실행하고, 변경한 코드가 있으면 가장 좁은 관련 테스트부터 추가한다. GPU/model/audio 품질 검증은 정적/단위 검증과 구분하고 실행하지 않은 항목을 통과로 표현하지 않는다.
