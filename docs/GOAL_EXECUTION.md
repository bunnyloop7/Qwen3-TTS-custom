# Goal Execution Policy

이 문서는 특정 버전, branch, SHA, 현재 WorkUnit과 무관한 재사용 가능한 연속 실행 정책만 정의한다.

## Trigger

사용자가 `Goal`, `Goal로 진행`, `다음 작업 끝까지 진행` 또는 동등한 연속 작업 요청을 하면 Goal mode로 해석한다.

## Execution loop

1. 최신 repository identity, remote, branch, working tree와 원격 관계를 확인한다.
2. `AGENTS.md`가 지정한 next-work source를 읽는다.
3. 가장 높은 우선순위의 실행 가능한 작업부터 선택한다.
4. 각 응집 작업마다 구현 → 관련 검증 → 기준 문서 정합화 → 프로젝트 Git 규칙에 따른 commit/push → 상태 재확인을 수행한다.
5. 한 WorkUnit 완료만으로 Goal을 종료하지 않고 다음 실행 가능한 중요 작업으로 계속 진행한다.
6. 현재 프로젝트 규칙으로 안전하게 판단 가능한 사소한 선택은 사용자에게 반복 질문하지 않는다.
7. 사용자가 사소한 작업 보류를 요청하면 핵심 안전성, 정확성, 주요 사용성을 막지 않는 polish, 선택적 refactor, 비필수 최적화는 간단히 보류 기록하고 다음 중요한 작업으로 진행한다.
8. 한 작업이 사용자 판단 필요로 막혀도 독립적으로 안전한 다른 중요 작업이 있으면 해당 항목만 차단/보류하고 계속 진행한다.
9. 예상 밖 변경, Git divergence/conflict, 데이터 손상 위험, destructive migration, schema/auth/core architecture/product-scope 변경처럼 실제 사용자 판단이 필요한 경우에만 전체 또는 해당 작업을 멈춘다.
10. 별도 Goal history 문서를 만들거나 누적하지 않는다.

## Durable outputs

Goal 종료 후 살아남는 정보는 기존 기준 문서에만 남긴다.

- 현재 구현 사실 → `AI_CONTEXT.md`
- 남은/보류 작업 → `docs/NEXT_WORK.md`
- 장기 결정 → `docs/DECISIONS.md`
- 구조 계약 → `docs/ARCHITECTURE.md`
- 반복 검증 교훈 → `docs/HARNESS_LESSONS.md`
- 완료 변경 이력 → `CHANGELOG.md`

일회성 실행 로그, 임시 계획, 특정 commit 상태를 새 장기 문서로 만들지 않는다.
