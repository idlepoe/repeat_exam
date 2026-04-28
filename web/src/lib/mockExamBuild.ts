import { fetchExamSessionList } from './examMeta'
import { examJsonUrl } from './examFiles'
import type { Question } from '../types/question'
import type { MockExamKind } from './mockExamStorage'

/** 과목별 출제 문항 수 (모의고사.md) */
export const MOCK_SUBJECT_QUOTAS: Record<string, number> = {
  제조이론: 30,
  재료과학: 15,
  식품위생학: 10,
  영양학: 5,
}

const TOTAL_MOCK = Object.values(MOCK_SUBJECT_QUOTAS).reduce((a, b) => a + b, 0)

function shuffle<T>(items: T[]): T[] {
  const arr = [...items]
  for (let i = arr.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[arr[i], arr[j]] = [arr[j], arr[i]]
  }
  return arr
}

/**
 * 회차 JSON을 랜덤 순으로 열어 과목별 풀을 쌓은 뒤,
 * 과목별 할당량만큼 무작위 추출하여 총 60문항을 만든다.
 */
export async function buildMockExamQuestions(
  examKind: MockExamKind
): Promise<Question[]> {
  const meta = await fetchExamSessionList()
  const row = meta.exam_session_list.find((e) => e.exam_type === examKind)
  if (!row?.sessions?.length) {
    throw new Error(`${examKind} 회차 정보가 없습니다.`)
  }

  const sessions = shuffle([...row.sessions])

  const pools: Record<string, Question[]> = {
    제조이론: [],
    재료과학: [],
    식품위생학: [],
    영양학: [],
  }

  for (const session of sessions) {
    const url = examJsonUrl(examKind, session)
    try {
      const res = await fetch(url)
      if (!res.ok) continue
      const data = (await res.json()) as unknown
      if (!Array.isArray(data)) continue
      for (const item of data) {
        if (!item || typeof item !== 'object') continue
        const q = item as Question
        const sub = q.subject
        if (sub in pools) {
          pools[sub].push(q)
        }
      }
    } catch {
      continue
    }

    const enough = Object.entries(MOCK_SUBJECT_QUOTAS).every(
      ([sub, need]) => (pools[sub]?.length ?? 0) >= need
    )
    if (enough) break
  }

  const selected: Question[] = []
  for (const [sub, need] of Object.entries(MOCK_SUBJECT_QUOTAS)) {
    const pool = shuffle(pools[sub] ?? [])
    if (pool.length < need) {
      throw new Error(
        `${sub} 문제가 부족합니다 (풀 ${pool.length}개 / 필요 ${need}개).`
      )
    }
    selected.push(...pool.slice(0, need))
  }

  if (selected.length !== TOTAL_MOCK) {
    throw new Error(
      `출제 문항 수가 ${TOTAL_MOCK}이 아닙니다 (${selected.length}).`
    )
  }

  return shuffle(selected)
}

export function countCorrectAnswers(
  questions: Question[],
  answers: Record<string, number>
): number {
  let n = 0
  for (const q of questions) {
    const picked = answers[q.id]
    if (picked !== undefined && picked === q.correct_answer) {
      n += 1
    }
  }
  return n
}

/** 맞은 개수 × 1.67 내림 (모의고사.md) */
export function mockExamScoreFloored(correctCount: number): number {
  return Math.floor(correctCount * 1.67)
}

export function isMockExamPassed(scoreFloored: number): boolean {
  return scoreFloored >= 60
}
