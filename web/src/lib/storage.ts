const KEY_PROGRESS = 'repeat_exam:progress'
const KEY_SESSION_COUNT = 'repeat_exam:session_count'
const KEY_NAV_REVERSED = 'repeat_exam:nav_reversed'
const KEY_ANSWER_HIGHLIGHT = 'repeat_exam:answer_highlight'

export interface Progress {
  exam_type: string
  exam_session: string
  question_number: number
}

export interface AnswerHighlight {
  bg: string
  fg: string
}

export type SessionCountMap = Record<string, number>

function sessionKey(examType: string, examSession: string): string {
  return `${examType}::${examSession}`
}

function progressKey(examType: string, examSession: string): string {
  return `${KEY_PROGRESS}:${sessionKey(examType, examSession)}`
}

export function getSessionCount(
  map: SessionCountMap,
  examType: string,
  examSession: string
): number {
  return map[sessionKey(examType, examSession)] ?? 0
}

export function saveProgress(
  p: Progress,
  examType: string,
  examSession: string
): void {
  try {
    localStorage.setItem(progressKey(examType, examSession), JSON.stringify(p))
  } catch {
    /* ignore */
  }
}

export function loadProgress(
  examType: string,
  examSession: string
): Progress | null {
  const key = progressKey(examType, examSession)
  try {
    const raw = localStorage.getItem(key)
    if (!raw) return null
    const p = JSON.parse(raw) as Progress
    if (
      typeof p.exam_type === 'string' &&
      typeof p.exam_session === 'string' &&
      typeof p.question_number === 'number'
    ) {
      return p
    }
  } catch {
    /* ignore */
  }

  // 하위 호환: 과거 단일 키에 저장된 같은 세션 데이터 1회 마이그레이션
  try {
    const legacyRaw = localStorage.getItem(KEY_PROGRESS)
    if (!legacyRaw) return null
    const p = JSON.parse(legacyRaw) as Progress
    if (
      typeof p.exam_type === 'string' &&
      typeof p.exam_session === 'string' &&
      typeof p.question_number === 'number' &&
      p.exam_type === examType &&
      p.exam_session === examSession
    ) {
      localStorage.setItem(key, JSON.stringify(p))
      localStorage.removeItem(KEY_PROGRESS)
      return p
    }
  } catch {
    /* ignore */
  }
  return null
}

export function clearProgress(examType?: string, examSession?: string): void {
  try {
    if (examType && examSession) {
      localStorage.removeItem(progressKey(examType, examSession))
      return
    }
    // 하위 호환 단일 키 + 세션별 progress 키를 모두 삭제
    localStorage.removeItem(KEY_PROGRESS)
    const keysToDelete: string[] = []
    for (let i = 0; i < localStorage.length; i += 1) {
      const key = localStorage.key(i)
      if (key && key.startsWith(`${KEY_PROGRESS}:`)) {
        keysToDelete.push(key)
      }
    }
    for (const key of keysToDelete) {
      localStorage.removeItem(key)
    }
  } catch {
    /* ignore */
  }
}

export function clearSessionCount(): void {
  try {
    localStorage.removeItem(KEY_SESSION_COUNT)
  } catch {
    /* ignore */
  }
}

export function loadSessionCountMap(): SessionCountMap {
  try {
    const raw = localStorage.getItem(KEY_SESSION_COUNT)
    if (!raw) return {}
    const parsed = JSON.parse(raw) as unknown
    if (!parsed || typeof parsed !== 'object') return {}
    const out: SessionCountMap = {}
    for (const [k, v] of Object.entries(parsed)) {
      if (typeof v === 'number' && Number.isFinite(v)) {
        out[k] = v
      }
    }
    return out
  } catch {
    /* ignore */
  }
  return {}
}

export function incrementSessionCountAndClearProgress(
  examType: string,
  examSession: string
): void {
  try {
    const current = loadSessionCountMap()
    const key = sessionKey(examType, examSession)
    current[key] = (current[key] ?? 0) + 1
    localStorage.setItem(KEY_SESSION_COUNT, JSON.stringify(current))
  } catch {
    /* ignore */
  }

  try {
    clearProgress(examType, examSession)
  } catch {
    /* ignore */
  }
}

export function loadNavReversed(): boolean {
  try {
    const raw = localStorage.getItem(KEY_NAV_REVERSED)
    if (raw === '1') return true
    if (raw === '0') return false
  } catch {
    /* ignore */
  }
  return false
}

export function saveNavReversed(value: boolean): void {
  try {
    localStorage.setItem(KEY_NAV_REVERSED, value ? '1' : '0')
  } catch {
    /* ignore */
  }
}

export function loadAnswerHighlight(): AnswerHighlight {
  const fallback: AnswerHighlight = { bg: '#c00', fg: '#fff' }
  try {
    const raw = localStorage.getItem(KEY_ANSWER_HIGHLIGHT)
    if (!raw) return fallback
    const parsed = JSON.parse(raw) as unknown
    if (!parsed || typeof parsed !== 'object') return fallback
    const obj = parsed as Record<string, unknown>
    const bg = typeof obj.bg === 'string' ? obj.bg : fallback.bg
    const fg = typeof obj.fg === 'string' ? obj.fg : fallback.fg
    return { bg, fg }
  } catch {
    /* ignore */
  }
  return fallback
}

export function saveAnswerHighlight(value: AnswerHighlight): void {
  try {
    localStorage.setItem(KEY_ANSWER_HIGHLIGHT, JSON.stringify(value))
  } catch {
    /* ignore */
  }
}
