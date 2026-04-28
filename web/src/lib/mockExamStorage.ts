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
}

export function saveMockSession(state: StoredMockSession): void {
  try {
    localStorage.setItem(KEY_MOCK_SESSION, JSON.stringify(state))
  } catch {
    /* ignore */
  }
}

export function loadMockSession(): StoredMockSession | null {
  try {
    const raw = localStorage.getItem(KEY_MOCK_SESSION)
    if (!raw) return null
    const p = JSON.parse(raw) as StoredMockSession
    if (
      typeof p.examKind === 'string' &&
      Array.isArray(p.questions) &&
      typeof p.answers === 'object' &&
      p.answers !== null &&
      typeof p.currentIndex === 'number' &&
      typeof p.startedAt === 'number'
    ) {
      return p
    }
  } catch {
    /* ignore */
  }
  return null
}

export function clearMockSession(): void {
  try {
    localStorage.removeItem(KEY_MOCK_SESSION)
  } catch {
    /* ignore */
  }
}

export function appendMockHistory(entry: Omit<MockHistoryRecord, 'id'>): void {
  try {
    const list = loadMockHistory()
    const id = `${entry.endedAt}_${Math.random().toString(36).slice(2, 9)}`
    list.unshift({ ...entry, id })
    const trimmed = list.slice(0, 50)
    localStorage.setItem(KEY_MOCK_HISTORY, JSON.stringify(trimmed))
  } catch {
    /* ignore */
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
        out.push(o as unknown as MockHistoryRecord)
      }
    }
    return out
  } catch {
    /* ignore */
  }
  return []
}
