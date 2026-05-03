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
 * 같은 exam_session(회차/PDF)에서만 과도하게 뽑히지 않도록,
 * 회차마다 한 문항씩 돌아가며 need개를 고른다.
 */
function pickSpreadAcrossSessions(pool: Question[], need: number): Question[] {
  if (pool.length < need) {
    throw new Error(
      `문항이 부족합니다 (풀 ${pool.length}개 / 필요 ${need}개).`
    )
  }

  const bySession = new Map<string, Question[]>()
  for (const q of pool) {
    const k = q.exam_session
    if (!bySession.has(k)) bySession.set(k, [])
    bySession.get(k)!.push(q)
  }
  for (const arr of bySession.values()) {
    shuffle(arr)
  }

  const sessionKeys = shuffle([...bySession.keys()])
  const selected: Question[] = []
  let round = 0

  while (selected.length < need) {
    let tookThisRound = false
    for (const key of sessionKeys) {
      if (selected.length >= need) break
      const bucket = bySession.get(key)!
      if (round < bucket.length) {
        selected.push(bucket[round])
        tookThisRound = true
      }
    }
    if (!tookThisRound) break
    round += 1
  }

  if (selected.length < need) {
    const used = new Set(selected.map((q) => q.id))
    const rest = shuffle(pool.filter((q) => !used.has(q.id)))
    selected.push(...rest.slice(0, need - selected.length))
  }

  return selected
}

/**
 * 모든 회차 JSON을 합쳐 과목별 풀을 만든 뒤,
 * 과목별 할당량만큼 회차를 고르게 섞어 추출하여 총 60문항을 만든다.
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

  const jsonLists = await Promise.all(
    sessions.map(async (session) => {
      const url = examJsonUrl(examKind, session)
      try {
        const res = await fetch(url)
        if (!res.ok) return null
        const data = (await res.json()) as unknown
        return Array.isArray(data) ? data : null
      } catch {
        return null
      }
    })
  )

  const pools: Record<string, Question[]> = {
    제조이론: [],
    재료과학: [],
    식품위생학: [],
    영양학: [],
  }

  for (const data of jsonLists) {
    if (!data) continue
    for (const item of data) {
      if (!item || typeof item !== 'object') continue
      const q = item as Question
      const sub = q.subject
      if (sub in pools) {
        pools[sub].push(q)
      }
    }
  }

  const selected: Question[] = []
  for (const [sub, need] of Object.entries(MOCK_SUBJECT_QUOTAS)) {
    const pool = pools[sub] ?? []
    if (pool.length < need) {
      throw new Error(
        `${sub} 문제가 부족합니다 (풀 ${pool.length}개 / 필요 ${need}개).`
      )
    }
    selected.push(...pickSpreadAcrossSessions(pool, need))
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
