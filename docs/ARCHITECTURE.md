# Architecture

## Scope

Qwen3-TTS-custom은 공식 Qwen3-TTS Python package와 CLI/UI를 가능한 그대로 유지하면서 로컬 영상 제작에 필요한 TTS 경계를 최소 확장하는 Fork다.

## Components and ownership

### Upstream-owned core

- `qwen_tts/core/`: 모델, processor, tokenizer와 핵심 생성 구현.
- `qwen_tts/cli/demo.py`: 공식 Gradio demo 및 model loading/generation UI.
- `examples/`: 공식 Python 사용 예제.
- `finetuning/`: 공식 fine-tuning 경로.
- `README.md`: 공식 기능/사용법 설명이 중심인 upstream 문서.

이 영역은 upstream 동기화 비용이 크므로 직접 재작성보다 기존 public API 사용을 우선한다.

### Fork-owned coordination layer

- `AGENTS.md`: 항상 읽는 최소 router와 절대 안전계약.
- `AI_CONTEXT.md`: 현재 구현/로컬 검증 상태.
- `docs/DECISIONS.md`: 장기 결정.
- `docs/NEXT_WORK.md`: 실행 가능한 앞으로의 작업 큐.
- `docs/GOAL_EXECUTION.md`: 재사용 가능한 Goal mode 정책.
- `docs/HARNESS_LESSONS.md`: 반복 검증 교훈.
- `scripts/check_harness.ps1`: 문서 route/안전계약 정적 검사.
- `docs/IDEA_CANDIDATES.md`: 실제 병목이 확인될 때 검토하는 비실행 아이디어 후보.

## Source of truth

| 대상 | Source of truth |
|---|---|
| package version | `pyproject.toml` `[project].version` |
| 공통 version route mirror | `VERSION` |
| 현재 구현 사실 | 실제 코드/설정, 요약은 `AI_CONTEXT.md` |
| 구조/boundary | `docs/ARCHITECTURE.md` |
| 장기 결정 | `docs/DECISIONS.md` |
| 앞으로의 실행 큐 | `docs/NEXT_WORK.md` |
| 완료 변경 이력 | `CHANGELOG.md` + Git history |
| Qwen 공식 기능 계약 | upstream 코드와 공식 README |

## TTS data flow

현재 공식 Base-model voice clone 경로는 개념적으로 다음과 같다.

```text
reference audio + reference text
→ Qwen3TTSModel.create_voice_clone_prompt(...)
→ VoiceClonePromptItem collection
→ Qwen3TTSModel.generate_voice_clone(..., voice_clone_prompt=...)
→ waveform + sample rate
```

Gradio UI는 이 prompt payload를 로컬 파일로 저장하고 다시 읽어 합성에 재사용하는 기능을 제공한다. 개인 reference audio와 저장 prompt는 민감한 local-only asset으로 취급한다.

## ai-video-maker boundary

권장 consumer 흐름은 다음과 같다.

```text
ai-video-maker scene/cue speech plan
→ thin TtsAdapter
→ stable Qwen request boundary
→ Qwen public Python API or a deliberately small wrapper
→ audio result + duration/metadata or explicit error
```

`ai-video-maker` 여러 위치에서 `qwen_tts.core.*` 내부 구현을 직접 import하지 않는다. Qwen 실행 방식이 library/CLI/service 중 무엇으로 확정되더라도 consumer 전체가 바뀌지 않게 adapter가 ownership boundary가 된다.

## Failure and asset boundaries

- 합성 실패는 영상 프로젝트 데이터나 다른 pipeline 단계를 불필요하게 훼손하지 않아야 한다.
- model/cache/output/reference/prompt asset은 Git-tracked source와 분리한다.
- GPU/VRAM/latency/quality는 환경 의존 관측값이며 code contract로 고정하지 않는다.
- 최적화는 동일 조건의 측정 전후 비교를 근거로 한다.
