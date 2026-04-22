import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
import {
  getSessionCount,
  loadAnswerHighlight,
  loadProgress,
  loadSessionCountMap,
  type SessionCountMap,
} from '../lib/storage'
import {
  fetchExamSessionList,
  sessionsForExamType,
  type ExamSessionListJson,
} from '../lib/examMeta'

const TOTAL_QUESTIONS_PER_SESSION = 60

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
  const [answerHighlight] = useState(() => loadAnswerHighlight())

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

    const entries = sessions.map((session) => {
      const saved = loadProgress(examType, session)
      if (!saved) return [session, 0] as const
      const solved = Math.max(
        0,
        Math.min(TOTAL_QUESTIONS_PER_SESSION, saved.question_number)
      )
      const pct = Math.round((solved / TOTAL_QUESTIONS_PER_SESSION) * 100)
      return [session, Math.max(0, Math.min(100, pct))] as const
    })
    setSessionProgressMap(Object.fromEntries(entries))
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
                backgroundColor: '#fafafa',
                backgroundImage: `linear-gradient(to right, ${answerHighlight.bg} ${pct}%, transparent ${pct}%)`,
                backgroundRepeat: 'no-repeat',
                backgroundSize: '100% 5px',
                backgroundPosition: 'left bottom',
                cursor: 'pointer',
              }}
            >
              <span style={{ color: '#111' }}>{session}</span>
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
