export interface ExamTypeListJson {
  title: string
  exam_type_list: string[]
}

export interface ExamSessionListJson {
  title: string
  exam_session_list: { exam_type: string; sessions: string[] }[]
}

const BASE = '/assets/json'

export async function fetchExamTypeList(): Promise<ExamTypeListJson> {
  const res = await fetch(`${BASE}/exam_type_list.json`)
  if (!res.ok) throw new Error('시험 목록을 불러올 수 없습니다.')
  return res.json() as Promise<ExamTypeListJson>
}

export async function fetchExamSessionList(): Promise<ExamSessionListJson> {
  const res = await fetch(`${BASE}/exam_session_list.json`)
  if (!res.ok) throw new Error('출시 회차 목록을 불러올 수 없습니다.')
  return res.json() as Promise<ExamSessionListJson>
}

export function sessionsForExamType(
  data: ExamSessionListJson,
  examType: string
): string[] {
  const row = data.exam_session_list.find((e) => e.exam_type === examType)
  return row ? [...row.sessions].sort() : []
}

/** ISO 날짜 문자열(2002-01-27) 기준으로 다음 회차; 없으면 null */
export function nextSession(
  data: ExamSessionListJson,
  examType: string,
  currentSession: string
): string | null {
  const sessions = sessionsForExamType(data, examType)
  const i = sessions.indexOf(currentSession)
  if (i < 0 || i >= sessions.length - 1) return null
  return sessions[i + 1] ?? null
}
