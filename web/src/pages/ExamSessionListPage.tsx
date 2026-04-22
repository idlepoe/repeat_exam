import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
import { examJsonUrl } from '../lib/examFiles'
import {
  getSessionCount,
  loadProgress,
  loadSessionCountMap,
  type SessionCountMap,
} from '../lib/storage'
import {
  fetchExamSessionList,
  sessionsForExamType,
  type ExamSessionListJson,
} from '../lib/examMeta'

export function ExamSessionListPage() {
  const { examType: examTypeParam } = useParams<{ examType: string }>()
  const navigate = useNavigate()
  const examType = examTypeParam ? decodeURIComponent(examTypeParam) : ''

  const [meta, setMeta] = useState<ExamSessionListJson | null>(null)
  const [err, setErr] = useState<string | null>(null)
  const [sessionCountMap, setSessionCountMap] = useState<SessionCountMap>({})
  const [sessionProgressMap, setSessionProgressMap] = useState<
    Record<string, number>
  >({})

  useEffect(() => {
    fetchExamSessionList()
      .then(setMeta)
      .catch((e: Error) => setErr(e.message))
    setSessionCountMap(loadSessionCountMap())
  }, [])

  const sessions = meta ? sessionsForExamType(meta, examType) : []

  useEffect(() => {
    if (!examType || sessions.length === 0) {
      setSessionProgressMap({})
      return
    }

    let cancelled = false

    void (async () => {
      const entries = await Promise.all(
        sessions.map(async (session) => {
          const saved = loadProgress(examType, session)
          if (!saved) return [session, 0] as const

          try {
            const res = await fetch(examJsonUrl(examType, session))
            if (!res.ok) return [session, 0] as const
            const data = (await res.json()) as Array<{ question_number: number }>
            if (!Array.isArray(data) || data.length === 0) {
              return [session, 0] as const
            }
            const sorted = [...data].sort(
              (a, b) => a.question_number - b.question_number
            )
            const idx = sorted.findIndex(
              (q) => q.question_number === saved.question_number
            )
            const solved = idx >= 0 ? idx + 1 : 0
            const pct = Math.round((solved / sorted.length) * 100)
            return [session, Math.max(0, Math.min(100, pct))] as const
          } catch {
            return [session, 0] as const
          }
        })
      )

      if (!cancelled) {
        setSessionProgressMap(Object.fromEntries(entries))
      }
    })()

    return () => {
      cancelled = true
    }
  }, [examType, sessions])

  return (
    <div style={{ minHeight: '100svh', display: 'flex', flexDirection: 'column' }}>
      <AppBar
        title={meta?.title ?? '출시회차'}
        showBack
        onBack={() => navigate('/')}
      />
      <main style={{ flex: 1, padding: 16 }}>
        <p style={{ fontWeight: 600, marginBottom: 12, fontSize: 16 }}>{examType}</p>
        {err && <p style={{ color: 'crimson' }}>{err}</p>}
        {!meta && !err && <p>불러오는 중…</p>}
        {sessions.map((session) => {
          const count = getSessionCount(sessionCountMap, examType, session)
          const pct = sessionProgressMap[session] ?? 0
          return (
            <button
              key={session}
              type="button"
              onClick={() =>
                navigate(
                  `/quiz/${encodeURIComponent(examType)}/${encodeURIComponent(session)}`
                )
              }
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                width: '100%',
                marginBottom: 12,
                padding: '14px 16px',
                fontSize: 17,
                textAlign: 'left',
                border: '1px solid #ccc',
                borderRadius: 8,
                background: '#fafafa',
                cursor: 'pointer',
              }}
            >
              <span>{session}</span>
              <span style={{ fontSize: 14, color: '#666' }}>
                {pct}% · 회독 {count}
              </span>
            </button>
          )
        })}
      </main>
    </div>
  )
}
