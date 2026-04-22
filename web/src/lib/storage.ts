const KEY = 'repeat_exam:progress'

export interface Progress {
  exam_type: string
  exam_session: string
  question_number: number
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
