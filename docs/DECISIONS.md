# Decisions

장기간 유지할 제품, architecture, 안전 결정을 기록한다. 단기 작업 상태나 완료 이력은 넣지 않는다.

## D-001 — Upstream-first preservation

공식 Qwen 기능과 upstream 동기화 가능성을 우선 보호한다. 직접 대규모 재작성보다 public API, wrapper, UI, 설정 계층의 최소 변경을 선호한다.

## D-002 — Voice/model artifacts are local-only

모델 가중치, cache, 생성 음성, reference audio, saved voice-clone prompt 및 개인 음성 자산은 Git에 넣지 않는다. 재현성에 필요한 경우에도 저장소에는 비민감 설정/fixture만 둔다.

## D-003 — ai-video-maker owns the adapter boundary

영상 제작 애플리케이션은 Qwen 내부 구현을 직접 소비하지 않는다. `ai-video-maker`의 `TtsAdapter` 또는 동등한 얇은 경계 뒤에서 Qwen을 호출한다.

이 결정은 Qwen repo에 범용 provider framework를 만들라는 뜻이 아니다.

## D-004 — Reuse supported voice-clone prompt APIs

clone prompt 재사용은 가능한 한 `create_voice_clone_prompt`, `VoiceClonePromptItem`, `generate_voice_clone` 같은 지원되는 상위 API와 명시적 serialization boundary를 사용한다. UI DOM/state scraping이나 내부 model object 결합을 피한다.

## D-005 — Optimization is measured and opt-in

FlashAttention, quantization, offload, compile, streaming tuning은 현재 환경의 정상 동작을 먼저 보호하고 공식 지원 및 실측 이득이 확인될 때만 적용한다. 현재 `--no-flash-attn` 정상 경로를 열등한 임시 상태로 간주하지 않는다.

## D-006 — `pyproject.toml` owns the package version

package version의 source of truth는 `pyproject.toml`이다. root `VERSION`은 공통 Agent routing을 위한 mirror이며 Harness가 drift를 실패로 처리한다. release 승인 없이 둘 다 증가시키지 않는다.

## D-007 — Idea candidates are not the executable queue

`docs/IDEA_CANDIDATES.md`는 실제 병목이 확인되기 전 후보 모음으로 유지한다. 실행 우선순위가 확정된 작업만 `docs/NEXT_WORK.md`로 승격한다.
