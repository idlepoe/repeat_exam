import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
import { fetchExamTypeList, type ExamTypeListJson } from '../lib/examMeta'
import {
  clearProgress,
  clearSessionCount,
  loadAnswerHighlight,
  saveAnswerHighlight,
} from '../lib/storage'

export function ExamTypeListPage() {
  const navigate = useNavigate()
  const [data, setData] = useState<ExamTypeListJson | null>(null)
  const [err, setErr] = useState<string | null>(null)
  const [optionsFolded, setOptionsFolded] = useState(false)
  const [showHighlightDialog, setShowHighlightDialog] = useState(false)
  const [answerHighlight, setAnswerHighlight] = useState(() =>
    loadAnswerHighlight()
  )
  const [draftBg, setDraftBg] = useState(answerHighlight.bg)
  const [draftFg, setDraftFg] = useState(answerHighlight.fg)

  useEffect(() => {
    fetchExamTypeList()
      .then(setData)
      .catch((e: Error) => setErr(e.message))
  }, [])

  return (
    <div style={{ minHeight: '100svh', display: 'flex', flexDirection: 'column' }}>
      <AppBar title={data?.title ?? '시험 리스트'} />
      <main style={{ flex: 1, padding: 16 }}>
        <section style={{ marginBottom: 16 }}>
          <button
            type="button"
            onClick={() => setOptionsFolded((v) => !v)}
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              width: '100%',
              padding: '0 0 8px',
              fontSize: 14,
              fontWeight: 600,
              color: '#555',
              background: 'transparent',
              border: 'none',
              borderBottom: '1px solid #ddd',
              cursor: 'pointer',
            }}
          >
            <span>옵션</span>
            <span style={{ fontSize: 12 }}>{optionsFolded ? '펼치기' : '접기'}</span>
          </button>

          {!optionsFolded && (
            <div style={{ marginTop: 12 }}>
              <button
                type="button"
                onClick={() => {
                  setDraftBg(answerHighlight.bg)
                  setDraftFg(answerHighlight.fg)
                  setShowHighlightDialog(true)
                }}
                style={{
                  display: 'block',
                  width: '100%',
                  marginBottom: 12,
                  padding: '12px 14px',
                  fontSize: 15,
                  textAlign: 'center',
                  border: '1px solid #bbb',
                  borderRadius: 8,
                  background: answerHighlight.bg,
                  color: answerHighlight.fg,
                  cursor: 'pointer',
                }}
              >
                정답 하이라이트 색상 변경
              </button>
              <button
                type="button"
                onClick={() => {
                  clearProgress()
                  clearSessionCount()
                  window.alert('진행상황이 초기화되었습니다.')
                }}
                style={{
                  display: 'block',
                  width: '100%',
                  padding: '12px 14px',
                  fontSize: 15,
                  textAlign: 'center',
                  border: '1px solid #d44',
                  borderRadius: 8,
                  background: '#fff5f5',
                  color: '#b00',
                  cursor: 'pointer',
                }}
              >
                진행상황 초기화하기
              </button>
            </div>
          )}
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
            시험 타입
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

      {showHighlightDialog && (
        <div
          role="dialog"
          aria-modal="true"
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.45)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 100,
            padding: 16,
          }}
        >
          <div
            style={{
              background: '#fff',
              borderRadius: 12,
              padding: 20,
              width: '100%',
              maxWidth: 360,
              boxShadow: '0 8px 24px rgba(0,0,0,0.2)',
            }}
          >
            <p style={{ margin: '0 0 12px', fontSize: 17, fontWeight: 600 }}>
              정답 하이라이트 색상
            </p>

            <label
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: 8,
                fontSize: 14,
              }}
            >
              <span>배경 색상</span>
              <input
                type="color"
                value={draftBg}
                onChange={(e) => setDraftBg(e.target.value)}
              />
            </label>

            <label
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: 14,
                fontSize: 14,
              }}
            >
              <span>글자 색상</span>
              <input
                type="color"
                value={draftFg}
                onChange={(e) => setDraftFg(e.target.value)}
              />
            </label>

            <div
              style={{
                marginBottom: 14,
                padding: '10px 12px',
                borderRadius: 8,
                border: '1px solid #ddd',
                background: draftBg,
                color: draftFg,
                fontSize: 14,
                fontWeight: 600,
              }}
            >
              미리보기: 정답 보기
            </div>

            <div style={{ display: 'flex', gap: 8 }}>
              <button
                type="button"
                onClick={() => setShowHighlightDialog(false)}
                style={{
                  flex: 1,
                  padding: '10px 12px',
                  border: '1px solid #ccc',
                  borderRadius: 8,
                  background: '#f5f5f5',
                  cursor: 'pointer',
                }}
              >
                취소
              </button>
              <button
                type="button"
                onClick={() => {
                  const next = { bg: draftBg, fg: draftFg }
                  saveAnswerHighlight(next)
                  setAnswerHighlight(next)
                  setShowHighlightDialog(false)
                }}
                style={{
                  flex: 1,
                  padding: '10px 12px',
                  border: '1px solid #333',
                  borderRadius: 8,
                  background: '#222',
                  color: '#fff',
                  cursor: 'pointer',
                }}
              >
                저장
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
