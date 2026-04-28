import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
import { fetchExamTypeList, type ExamTypeListJson } from '../lib/examMeta'

function CogIcon() {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="22"
      height="22"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
    >
      <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
      <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z" />
    </svg>
  )
}

export function ExamTypeListPage() {
  const navigate = useNavigate()
  const [data, setData] = useState<ExamTypeListJson | null>(null)
  const [err, setErr] = useState<string | null>(null)

  useEffect(() => {
    fetchExamTypeList()
      .then(setData)
      .catch((e: Error) => setErr(e.message))
  }, [])

  return (
    <div style={{ minHeight: '100svh', display: 'flex', flexDirection: 'column' }}>
      <AppBar
        title={data?.title ?? '시험 리스트'}
        right={
          <button
            type="button"
            onClick={() => navigate('/options')}
            aria-label="옵션"
            title="옵션"
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              width: 40,
              height: 40,
              padding: 0,
              border: '1px solid #ccc',
              borderRadius: 8,
              background: '#fff',
              color: '#333',
              cursor: 'pointer',
            }}
          >
            <CogIcon />
          </button>
        }
      />
      <main style={{ flex: 1, padding: 16 }}>
        <section style={{ marginBottom: 24 }}>
          <div
            style={{
              marginBottom: 12,
              paddingBottom: 8,
              fontSize: 14,
              fontWeight: 600,
              color: '#555',
              borderBottom: '1px solid #ddd',
            }}
          >
            모의고사
          </div>
          <button
            type="button"
            onClick={() =>
              navigate(`/mock-quiz/${encodeURIComponent('제빵기능사')}`)
            }
            style={{
              display: 'block',
              width: '100%',
              marginBottom: 12,
              padding: '14px 16px',
              fontSize: 18,
              textAlign: 'left',
              border: '1px solid #ccc',
              borderRadius: 8,
              background: '#fafafa',
              cursor: 'pointer',
            }}
          >
            제빵기능사
          </button>
          <button
            type="button"
            onClick={() =>
              navigate(`/mock-quiz/${encodeURIComponent('제과기능사')}`)
            }
            style={{
              display: 'block',
              width: '100%',
              marginBottom: 12,
              padding: '14px 16px',
              fontSize: 18,
              textAlign: 'left',
              border: '1px solid #ccc',
              borderRadius: 8,
              background: '#fafafa',
              cursor: 'pointer',
            }}
          >
            제과기능사
          </button>
        </section>

        <section>
          <div
            style={{
              marginBottom: 12,
              paddingBottom: 8,
              fontSize: 14,
              fontWeight: 600,
              color: '#555',
              borderBottom: '1px solid #ddd',
            }}
          >
            기출문제 (정답&해설 표시)
          </div>
        {err && <p style={{ color: 'crimson' }}>{err}</p>}
        {!data && !err && <p>불러오는 중…</p>}
        {data?.exam_type_list.map((name) => (
          <button
            key={name}
            type="button"
            onClick={() =>
              navigate(`/sessions/${encodeURIComponent(name)}`)
            }
            style={{
              display: 'block',
              width: '100%',
              marginBottom: 12,
              padding: '14px 16px',
              fontSize: 18,
              textAlign: 'left',
              border: '1px solid #ccc',
              borderRadius: 8,
              background: '#fafafa',
              cursor: 'pointer',
            }}
          >
            {name}
          </button>
        ))}
        </section>
      </main>
    </div>
  )
}
