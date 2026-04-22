import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
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

  useEffect(() => {
    fetchExamSessionList()
      .then(setMeta)
      .catch((e: Error) => setErr(e.message))
  }, [])

  const sessions = meta ? sessionsForExamType(meta, examType) : []

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
        {sessions.map((session) => (
          <button
            key={session}
            type="button"
            onClick={() =>
              navigate(
                `/quiz/${encodeURIComponent(examType)}/${encodeURIComponent(session)}`
              )
            }
            style={{
              display: 'block',
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
            {session}
          </button>
        ))}
      </main>
    </div>
  )
}
