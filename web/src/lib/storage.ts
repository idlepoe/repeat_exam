const KEY = 'repeat_exam:progress'
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

export function getSessionCount(
  map: SessionCountMap,
  examType: string,
  examSession: string
): number {
  return map[sessionKey(examType, examSession)] ?? 0
}

export function saveProgress(p: Progress): void {
  try {
    localStorage.setItem(KEY, JSON.stringify(p))
  } catch {
    /* ignore */
  }
}

export function loadProgress(): Progress | null {
  try {
    const raw = localStorage.getItem(KEY)
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
  return null
}

export function clearProgress(): void {
  try {
    localStorage.removeItem(KEY)
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
    const progress = loadProgress()
    if (
      progress &&
      progress.exam_type === examType &&
      progress.exam_session === examSession
    ) {
      localStorage.removeItem(KEY)
    }
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
