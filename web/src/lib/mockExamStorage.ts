import type { Question } from '../types/question'

const KEY_MOCK_SESSION = 'repeat_exam:mock_session'
const KEY_MOCK_HISTORY = 'repeat_exam:mock_history'

export type MockExamKind = '제빵기능사' | '제과기능사'

export interface StoredMockSession {
  examKind: MockExamKind
  questions: Question[]
  /** question id -> 선택한 보기 번호 */
  answers: Record<string, number>
  currentIndex: number
  startedAt: number
}

export interface MockHistoryRecord {
  id: string
  examKind: MockExamKind
  startedAt: number
  endedAt: number
  correctCount: number
  totalQuestions: number
  /** 맞은 개수 × 1.67 내림 */
  scoreFloored: number
  passed: boolean
  /** 이력 상세 재현용 문제 스냅샷(신규 저장분) */
  questions?: Question[]
  /** 이력 상세 재현용 선택 답안 맵(신규 저장분) */
  answers?: Record<string, number>
}

export function saveMockSession(state: StoredMockSession): void {
  try {
    const normalizedQuestions = state.questions.map(normalizeQuestionForSession)
    localStorage.setItem(
      KEY_MOCK_SESSION,
      JSON.stringify({
        ...state,
        questions: normalizedQuestions,
      })
    )
    if (import.meta.env.DEV) {
      console.log('[MockExam]', 'saveMockSession', {
        examKind: state.examKind,
        questionCount: normalizedQuestions.length,
        aiExplanationCount: normalizedQuestions.filter((q) => q.aiExplanation)
          .length,
        answerCount: Object.keys(state.answers).length,
        currentIndex: state.currentIndex,
        startedAt: state.startedAt,
      })
    }
  } catch {
    /* ignore */
  }
}

export function loadMockSession(): StoredMockSession | null {
  try {
    const raw = localStorage.getItem(KEY_MOCK_SESSION)
    if (!raw) return null
    const p = JSON.parse(raw) as StoredMockSession
    const normalizedQuestions = Array.isArray(p.questions)
      ? p.questions.map(normalizeQuestionForSession)
      : null
    if (
      typeof p.examKind === 'string' &&
      normalizedQuestions !== null &&
      typeof p.answers === 'object' &&
      p.answers !== null &&
      typeof p.currentIndex === 'number' &&
      typeof p.startedAt === 'number'
    ) {
      return {
        ...p,
        questions: normalizedQuestions,
      }
    }
  } catch {
    /* ignore */
  }
  return null
}

export function clearMockSession(reason = '(reason not set)'): void {
  let hadBefore = false
  let rawLen = 0
  try {
    const raw = localStorage.getItem(KEY_MOCK_SESSION)
    hadBefore = raw != null
    rawLen = raw?.length ?? 0
    localStorage.removeItem(KEY_MOCK_SESSION)
    const after = localStorage.getItem(KEY_MOCK_SESSION)
    console.log('[MockExam]', 'clearMockSession', reason, {
      key: KEY_MOCK_SESSION,
      hadBefore,
      rawLen,
      cleared: after === null,
      stillPresent: after !== null,
    })
    if (after !== null) {
      console.warn('[MockExam]', 'clearMockSession: 키 삭제 후에도 값이 남음')
    }
  } catch (e) {
    console.warn('[MockExam]', 'clearMockSession failed', reason, e)
  }
}

export function appendMockHistory(entry: Omit<MockHistoryRecord, 'id'>): void {
  try {
    const list = loadMockHistory()
    const id = `${entry.endedAt}_${Math.random().toString(36).slice(2, 9)}`
    list.unshift({ ...entry, id })
    const trimmed = list.slice(0, 50)
    localStorage.setItem(KEY_MOCK_HISTORY, JSON.stringify(trimmed))
    console.log('[MockExam]', 'appendMockHistory', {
      id,
      examKind: entry.examKind,
      correctCount: entry.correctCount,
      scoreFloored: entry.scoreFloored,
      passed: entry.passed,
      historyLen: trimmed.length,
    })
  } catch (e) {
    console.warn('[MockExam]', 'appendMockHistory failed', e)
  }
}

export function loadMockHistory(): MockHistoryRecord[] {
  try {
    const raw = localStorage.getItem(KEY_MOCK_HISTORY)
    if (!raw) return []
    const parsed = JSON.parse(raw) as unknown
    if (!Array.isArray(parsed)) return []
    const out: MockHistoryRecord[] = []
    for (const item of parsed) {
      if (!item || typeof item !== 'object') continue
      const o = item as Record<string, unknown>
      if (
        typeof o.id === 'string' &&
        typeof o.examKind === 'string' &&
        typeof o.startedAt === 'number' &&
        typeof o.endedAt === 'number' &&
        typeof o.correctCount === 'number' &&
        typeof o.totalQuestions === 'number' &&
        typeof o.scoreFloored === 'number' &&
        typeof o.passed === 'boolean'
      ) {
        const questions = Array.isArray(o.questions)
          ? (o.questions as Question[])
          : undefined
        const answers = isNumberRecord(o.answers) ? o.answers : undefined
        out.push({
          id: o.id,
          examKind: o.examKind as MockExamKind,
          startedAt: o.startedAt,
          endedAt: o.endedAt,
          correctCount: o.correctCount,
          totalQuestions: o.totalQuestions,
          scoreFloored: o.scoreFloored,
          passed: o.passed,
          questions,
          answers,
        })
      }
    }
    return out
  } catch {
    /* ignore */
  }
  return []
}

export function clearMockHistory(): void {
  try {
    localStorage.removeItem(KEY_MOCK_HISTORY)
  } catch {
    /* ignore */
  }
}

export function hasHistoryDetailPayload(
  record: MockHistoryRecord
): record is MockHistoryRecord & {
  questions: Question[]
  answers: Record<string, number>
} {
  return (
    Array.isArray(record.questions) &&
    record.questions.length > 0 &&
    isNumberRecord(record.answers)
  )
}

function isNumberRecord(value: unknown): value is Record<string, number> {
  if (!value || typeof value !== 'object') return false
  return Object.values(value).every((v) => typeof v === 'number')
}

function normalizeQuestionForSession(q: Question): Question {
  if (!q.aiExplanation) return q
  return {
    ...q,
    aiExplanation: {
      correctExplanation: q.aiExplanation.correctExplanation,
      wrongAnswerNotes: [...q.aiExplanation.wrongAnswerNotes],
      examTip: q.aiExplanation.examTip,
    },
  }
}
