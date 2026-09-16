# Engine Capability Export 설계 입력

이 프로젝트는 Qwen3-TTS 실행·수정·검증에 집중하고, 상위 애플리케이션의 orchestration이나 UI를 소유하지 않는다. 다른 프로젝트가 안정적으로 adapter를 만들 수 있도록 최소 capability/readiness 정보를 노출하는 방향을 검토한다.

## 1. 기계 판독 가능한 Capability

모델/런타임별로 가능한 경우 다음을 구조화한다.

- model ID / variant
- voice clone
- voice design
- custom/preset voice
- instruction control
- streaming
- batch
- supported languages
- supported speakers
- local inference
- reference audio requirement

지원하지 않는 기능을 wrapper가 임의로 흉내내지 않는다.

## 2. Readiness

최소 판정 후보:

- model available
- dependencies ready
- device ready
- weights loaded / loadable
- runtime healthy
- unavailable reason

상위 프로젝트는 import 성공만으로 생성 가능하다고 판단하지 않도록 한다.

## 3. Runtime / Benchmark Metadata

관측값은 환경과 함께 보존한다.

- OS
- Python
- torch / CUDA
- GPU / unified memory
- model
- dtype / attention implementation
- VRAM/RAM 관측치
- first-token / total generation time
- text length / audio duration

특정 장비에서의 관측값을 모델의 고정 최소 요구사항으로 단정하지 않는다.

## 4. Stable Adapter Surface

상위 공용 TTS 계층이 직접 내부 구현을 의존하지 않도록 최소 실행 surface를 유지하는 방향을 검토한다.

후보:

- capabilities
- readiness
- list_languages / list_speakers
- synthesize
- clone/design 관련 명시적 entry point
- structured error

프로젝트 내부 실험 옵션을 모두 외부 계약으로 노출하지 않는다.

## 5. 소유권

이 프로젝트는 엔진 실행과 검증을 담당한다. 비용 라우팅, 웹 queue, 영상 timeline, 음악 Vocal Identity, 사용자 계정 정책은 상위 소비 프로젝트가 담당한다.
