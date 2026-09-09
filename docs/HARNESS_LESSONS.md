# Harness Lessons

반복될 가치가 있는 검증, Windows, Git, harness 교훈만 기록한다. 일회성 로그나 특정 실패 출력은 누적하지 않는다.

## H-001 — Remote 상태와 local working tree를 혼동하지 않는다

GitHub에서 branch/commit 관계를 확인할 수 있어도 로컬 staged/untracked 변경까지 확인한 것은 아니다. 로컬 filesystem 접근이 없는 실행 환경에서는 이를 명시하고 clean으로 추정하지 않는다.

## H-002 — Upstream fork는 소스 변경보다 ownership 확인이 먼저다

Qwen upstream과 동일한 파일을 수정하기 전 현재 upstream/main과 fork main이 같은지, active work가 무엇을 추가했는지 먼저 비교한다. 사용자 기능과 upstream sync를 한 번에 섞지 않는다.

## H-003 — GPU/model 검증과 정적 Harness를 분리한다

`check_harness.ps1` 성공은 문서 route와 저장소 안전계약의 정적 확인이다. CUDA model load, VRAM, latency, 음질, speaker similarity가 검증됐다는 뜻이 아니다.

## H-004 — PowerShell harness는 경로와 exit code가 계약이다

Harness는 repository root 이외 위치에서 실행해도 root를 스스로 계산하고, 실패 시 non-zero exit code를 반환해야 한다. 개인 절대경로를 문서/스크립트에 고정하지 않는다.
