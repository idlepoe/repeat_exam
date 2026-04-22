import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
import { fetchExamTypeList, type ExamTypeListJson } from '../lib/examMeta'

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
      <AppBar title={data?.title ?? '시험 리스트'} />
      <main style={{ flex: 1, padding: 16 }}>
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
      </main>
    </div>
  )
}
