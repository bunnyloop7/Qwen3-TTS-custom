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

### User-validated local baseline

아래는 2026-09-09에 사용자가 직접 확인한 로컬 실행 기준이며 upstream 지원 선언이나 영구 성능 보장이 아니다. 환경 또는 성능 판단이 필요한 작업에서는 다시 측정한다.

- Python 3.14.6
- editable `qwen-tts` 0.1.1
- PyTorch 2.13.0+cu126
- RTX 3070에서 CUDA 인식 성공
- FlashAttention 미설치, `--no-flash-attn`으로 Gradio Web UI 실행 성공
- Qwen3-TTS-12Hz-0.6B-Base 로컬 사용 성공
- 한국어 voice clone 실제 생성 성공
- 일본어 생성 가능, 억양은 추가 평가 필요
- 짧은 문장 생성 약 26초, VRAM 약 2.85GB 관측

모델 가중치, 생성 WAV, 참조 음성, saved voice prompt는 local-only 자산이며 저장소 상태가 아니다.

## Integration direction

우선순위는 `ai-video-maker`가 Qwen 내부 구현에 직접 결합되지 않도록 얇은 `TtsAdapter` 또는 동등한 경계를 두는 것이다. 기존 voice clone prompt 재사용 기능을 활용하고 한국어 end-to-end 영상 파이프라인을 먼저 검증한 뒤 일본어 억양, 속도, streaming 최적화를 검토한다.

아직 Qwen 전용 server/provider 계층이나 범용 다중-provider 추상화가 구현됐다고 가정하지 않는다.
