# Model Location / Memory Lifecycle 설계 입력

이 프로젝트는 Qwen3-TTS 실행·수정·검증 샌드박스이므로, 상위 애플리케이션이 안정적으로 재사용할 수 있게 model location과 runtime memory state를 명시적으로 분리하는 방향을 검토한다.

## 1. Model Identity와 Path 분리

model variant/revision과 로컬 절대 경로를 동일 개념으로 취급하지 않는다.

후보 metadata:

- model family / variant
- revision
- local path
- source/cache root
- expected file set
- capability

상위 adapter는 가능하면 logical model identity를 사용하고 path resolution은 이 runtime 또는 공용 model registry가 담당한다.

## 2. Multiple Model Roots

필요하면 다음 root를 순서대로 탐색할 수 있다.

- explicit user path
- project-local model directory
- shared AI model directory
- configured cache directory

동일 model revision이 여러 곳에 있을 때 선택 우선순위를 deterministic하게 한다.

## 3. Runtime State

최소 상태 후보:

- discovered
- files complete
- loadable
- loading
- loaded
- ready
- busy
- offloaded
- unavailable

import 성공만으로 ready라고 판단하지 않는다.

## 4. Device / Memory Metadata

관측 가능한 경우 다음을 노출한다.

- selected device
- dtype / quantization
- current loaded model
- observed VRAM/RAM
- load time
- offload/unload support
- OOM / fallback reason

이 값은 관측치이며 모든 환경의 고정 최소 요구사항으로 단정하지 않는다.

## 5. Load / Offload 정책

모델 load lifecycle을 상위 앱이 내부 tensor/module까지 직접 만지지 않도록 명시적 entry point로 감싼다.

후보:

- prepare/load
- readiness
- synthesize
- unload/offload
- health

장시간 미사용 모델의 offload 정책은 실제 여러 모델을 동시에 운용할 때만 도입한다.

## 6. Shared Model Safety

공유 root를 사용하는 경우 이 프로젝트가 상위 앱 대신 모델 파일을 임의 삭제하거나 덮어쓰지 않는다. partial/incomplete model은 ready로 노출하지 않는다.
