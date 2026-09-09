# Next Work

현재 실행 가능한 앞으로의 작업만 유지한다. 완료 이력은 `CHANGELOG.md`와 Git history로 이동하고 이 파일에 누적하지 않는다.

## 1. ai-video-maker ↔ Qwen 최소 호출 계약 설계

- `ai-video-maker`의 실제 speech plan / TTS adapter 구현을 최신 코드에서 확인한다.
- Qwen public Python API와 현재 Base-model voice clone 입력/출력을 대조한다.
- 필요한 최소 요청/응답을 `text`, `language`, voice/clone reference, generation options → audio result, duration/metadata, error 수준으로 제한한다.
- Qwen 내부 모듈을 consumer 여러 위치에서 직접 import하지 않는다.
- 가능하면 Qwen source 변경 없이 consumer adapter로 해결한다.

완료 조건: producer/consumer ownership과 오류 경계가 명확하고 기존 ai-video-maker 계약을 깨지 않는 최소 설계가 확정돼 있다.

## 2. Saved voice-clone prompt 재사용 경계 확정

- 공식 UI의 save/load 구현과 `VoiceClonePromptItem` 사용 경로를 기준으로 consumer 재사용 방법을 결정한다.
- 개인 prompt/reference는 local-only storage로 유지한다.
- 파일 포맷을 장기 공개 계약으로 고정하기 전에 필요한 compatibility 범위를 정한다.

완료 조건: 같은 허가된 reference에서 prompt를 반복 재계산하지 않고 안전하게 재사용할 수 있으며 Git 추적 데이터와 분리돼 있다.

## 3. 한국어 end-to-end 영상 음성 smoke

1·2 완료 후 실제 ai-video-maker speech cue에서 Qwen clone 음성을 생성하고 결과 파일/메타데이터/실패 경계를 확인한다.

완료 조건: 최소 한 개 한국어 cue가 adapter 경계를 통해 생성되고 기존 프로젝트 데이터가 실패 시 보존된다.

## 4. 고정 평가 문장과 측정 항목 정리

실제 pipeline이 연결된 뒤 한국어 중심의 작은 평가 세트를 만든다. 자연스러움, 발음, speaker similarity, latency, peak VRAM, 실패 여부를 동일 조건으로 비교한다.

완료 조건: 최적화 전후를 재현 가능하게 비교할 최소 평가 절차가 있다.

## 5. 일본어 억양 품질 개선 검토

한국어 baseline을 유지하면서 고정 일본어 문장으로 억양/발음 차이를 확인한다. 추측으로 parameter를 늘리지 않고 측정 가능한 변경만 채택한다.

## 6. 속도 / streaming 최적화 검토

실제 영상 제작 병목이 확인된 뒤 `docs/IDEA_CANDIDATES.md`의 runtime capability, profile, streaming 후보를 검토한다. FlashAttention이나 환경 변경은 정상 baseline을 깨지 않는 실측 이득이 있을 때만 채택한다.
