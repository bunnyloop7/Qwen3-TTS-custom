# Current State

## Repository role

이 저장소는 공식 `QwenLM/Qwen3-TTS`를 기반으로 로컬 TTS와 voice cloning을 안정적으로 사용하기 위한 사용자 Fork다. upstream 원본 기능을 우선 보존하고, 필요한 사용자 변경은 최소한의 wrapper/UI/설정 경계에 둔다.

현재 active 사용자 작업선은 `work/local-custom`이다. branch/SHA/ahead/behind는 작업 시작 시 Git으로 다시 확인하며 이 문서의 고정값으로 취급하지 않는다.

Harness 구조 도입 직전 원격 기준으로 사용자 source code 수정은 없었고, 사용자 고유 변경은 `docs/IDEA_CANDIDATES.md`의 운영 후보 문서뿐이었다.

## Package and runtime baseline

- package version source of truth: `pyproject.toml`의 `[project].version`
- `VERSION`은 위 값을 mirror하며 `scripts/check_harness.ps1`이 일치 여부를 검사한다.
- 공식 Gradio CLI는 FlashAttention 사용 여부를 선택할 수 있고 `--no-flash-attn` 경로를 제공한다.
- 공식 Base-model UI에는 voice clone prompt 생성/저장과 저장 prompt 재로드 후 합성 경로가 있다.

### Local validation policy

개별 사용자의 장비 모델, OS/런타임 세부 버전, VRAM/RAM 관측치, latency, 개인 음성 기반 생성 결과처럼 환경을 지문화할 수 있는 실행 기록은 공개 저장소의 정본으로 고정하지 않는다.

실행 가능 여부나 성능 판단이 필요한 작업에서는 해당 로컬 환경에서 다시 측정하고, 저장소에는 재현에 필요한 비민감 계약과 일반화된 검증 기준만 남긴다.

모델 가중치, 생성 WAV, 참조 음성, saved voice prompt는 local-only 자산이며 저장소 상태가 아니다.

## Integration direction

우선순위는 `ai-video-maker`가 Qwen 내부 구현에 직접 결합되지 않도록 얇은 `TtsAdapter` 또는 동등한 경계를 두는 것이다. 기존 voice clone prompt 재사용 기능을 활용하고 한국어 end-to-end 영상 파이프라인을 먼저 검증한 뒤 일본어 억양, 속도, streaming 최적화를 검토한다.

아직 Qwen 전용 server/provider 계층이나 범용 다중-provider 추상화가 구현됐다고 가정하지 않는다.
