import type { NavigateFunction } from 'react-router-dom'

/**
 * 모의고사 완료 후 결과 다이얼로그에서「확인」을 눌렀을 때
 * 시험 타입 목록(/)으로 이동한다.
 *
 * 모의고사.md 58행: 확인 다이얼로그 후 목록 이동.
 * `replace: true` 로 완료 뒤 브라우저 뒤로가기로 모의고사 화면에
 * 다시 들어가기 어렵게 한다.
 */
export function navigateToExamTypeListAfterMockExamComplete(
  navigate: NavigateFunction
): void {
  navigate('/', { replace: true })
}
