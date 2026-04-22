import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
import { examJsonUrl } from '../lib/examFiles'
import { fetchExamSessionList, nextSession } from '../lib/examMeta'
import { loadProgress, saveProgress } from '../lib/storage'
import type { Question } from '../types/question'

export function QuestionPage() {
  const { examType: et, examSession: es } = useParams<{
    examType: string
    examSession: string
  }>()
  const navigate = useNavigate()
  const examType = et ? decodeURIComponent(et) : ''
  const examSession = es ? decodeURIComponent(es) : ''

  const [questions, setQuestions] = useState<Question[]>([])
  const [loadErr, setLoadErr] = useState<string | null>(null)
  const [index, setIndex] = useState(0)
  const [navReversed, setNavReversed] = useState(false)
  const [largeFont, setLargeFont] = useState(false)
  const [showNextSessionDialog, setShowNextSessionDialog] = useState(false)

  useEffect(() => {
    if (!examType || !examSession) return
    let cancelled = false

    void (async () => {
      setLoadErr(null)
      try {
        const url = examJsonUrl(examType, examSession)
        const res = await fetch(url)
        if (!res.ok) {
          throw new Error(`문제 파일을 불러올 수 없습니다. (${res.status})`)
        }
        const data = (await res.json()) as Question[]
        if (!Array.isArray(data) || data.length === 0) {
          throw new Error('문제 데이터가 비어 있습니다.')
        }
        const sorted = [...data].sort(
          (a, b) => a.question_number - b.question_number
        )
        const saved = loadProgress()
        let start = 0
        if (
          saved &&
          saved.exam_type === examType &&
          saved.exam_session === examSession
        ) {
          const i = sorted.findIndex(
            (q) => q.question_number === saved.question_number
          )
          if (i >= 0) start = i
        }
        if (!cancelled) {
          setQuestions(sorted)
          setIndex(start)
        }
      } catch (e) {
        if (!cancelled) {
          setLoadErr(e instanceof Error ? e.message : '로드 실패')
          setQuestions([])
        }
      }
    })()

    return () => {
      cancelled = true
    }
  }, [examType, examSession])

  const q = questions[index]

  useEffect(() => {
    if (!q) return
    saveProgress({
      exam_type: examType,
      exam_session: examSession,
      question_number: q.question_number,
    })
  }, [q, examType, examSession])

  const goPrev = () => {
    if (index > 0) setIndex((i) => i - 1)
  }

  const goNext = () => {
    if (questions.length === 0) return
    if (index < questions.length - 1) {
      setIndex((i) => i + 1)
      return
    }
    setShowNextSessionDialog(true)
  }

  const handleNextSessionConfirm = async () => {
    setShowNextSessionDialog(false)
    try {
      const meta = await fetchExamSessionList()
      const next = nextSession(meta, examType, examSession)
      if (!next) {
        window.alert('이어질 다음 회차가 없습니다.')
        return
      }
      navigate(
        `/quiz/${encodeURIComponent(examType)}/${encodeURIComponent(next)}`
      )
    } catch (e) {
      window.alert(
        e instanceof Error ? e.message : '다음 회차 정보를 불러올 수 없습니다.'
      )
    }
  }

  const baseFont = largeFont ? 20 : 16
  const titleFs = largeFont ? 18 : 15

  const navPrevBtn = (
    <button
      type="button"
      onClick={goPrev}
      disabled={index <= 0}
      style={{
        padding: '12px 16px',
        fontSize: 16,
        border: '1px solid #ccc',
        borderRadius: 8,
        background: index <= 0 ? '#eee' : '#fff',
        cursor: index <= 0 ? 'not-allowed' : 'pointer',
      }}
    >
      이전
    </button>
  )

  const navNextBtn = (
    <button
      type="button"
      onClick={goNext}
      style={{
        padding: '12px 16px',
        fontSize: 16,
        border: '1px solid #ccc',
        borderRadius: 8,
        background: '#fff',
        cursor: 'pointer',
      }}
    >
      다음
    </button>
  )

  const swapBtn = (
    <button
      type="button"
      onClick={() => setNavReversed((v) => !v)}
      style={{
        padding: '12px 16px',
        fontSize: 16,
        border: '1px solid #aaa',
        borderRadius: 8,
        background: '#f0f0f0',
        cursor: 'pointer',
      }}
    >
      변경
    </button>
  )

  return (
    <div style={{ minHeight: '100svh', display: 'flex', flexDirection: 'column' }}>
      <AppBar
        title={examType}
        showBack
        onBack={() =>
          navigate(`/sessions/${encodeURIComponent(examType)}`)
        }
        right={
          <button
            type="button"
            onClick={() => setLargeFont((v) => !v)}
            style={{
              padding: '6px 10px',
              fontSize: 14,
              border: '1px solid #ccc',
              borderRadius: 6,
              background: '#fff',
              cursor: 'pointer',
            }}
            title="글자 크기"
          >
            aA
          </button>
        }
      />

      <main
        style={{
          flex: 1,
          padding: 16,
          fontSize: baseFont,
          lineHeight: 1.5,
          textAlign: 'left',
        }}
      >
        {loadErr && (
          <p style={{ color: 'crimson', marginBottom: 12 }}>{loadErr}</p>
        )}
        {!q && !loadErr && <p>불러오는 중…</p>}

        {q && (
          <>
            <div
              style={{
                fontSize: titleFs,
                fontWeight: 600,
                marginBottom: 8,
                color: '#333',
              }}
            >
              [{q.subject}]
            </div>
            <p style={{ margin: '0 0 16px' }}>
              <span style={{ fontWeight: 600 }}>{q.question_number}.</span>{' '}
              {q.question_text}
            </p>

            {q.question_image_url ? (
              <div style={{ marginBottom: 16 }}>
                <img
                  src={q.question_image_url}
                  alt=""
                  style={{ maxWidth: '100%', height: 'auto' }}
                />
              </div>
            ) : null}

            <ul
              style={{
                listStyle: 'none',
                padding: 0,
                margin: '0 0 24px',
              }}
            >
              {q.choices.map((c) => {
                const isAnswer = c.no === q.correct_answer
                return (
                  <li
                    key={c.no}
                    style={{
                      marginBottom: 10,
                      padding: '10px 12px',
                      border: '1px solid #ddd',
                      borderRadius: 6,
                      background: isAnswer ? '#c00' : '#fafafa',
                      color: isAnswer ? '#fff' : '#111',
                    }}
                  >
                    {c.no}. {c.text}
                  </li>
                )
              })}
            </ul>

            <div
              style={{
                display: 'flex',
                flexWrap: 'wrap',
                gap: 8,
                justifyContent: 'center',
                marginTop: 8,
              }}
            >
              {navReversed ? (
                <>
                  {navNextBtn}
                  {swapBtn}
                  {navPrevBtn}
                </>
              ) : (
                <>
                  {navPrevBtn}
                  {swapBtn}
                  {navNextBtn}
                </>
              )}
            </div>
          </>
        )}
      </main>

      {showNextSessionDialog && (
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
              maxWidth: 360,
              width: '100%',
              boxShadow: '0 8px 24px rgba(0,0,0,0.2)',
            }}
          >
            <p style={{ margin: '0 0 16px', fontSize: 17, fontWeight: 600 }}>
              다음 회차로 이동할까요?
            </p>
            <div
              style={{
                display: 'flex',
                flexDirection: 'column',
                gap: 8,
              }}
            >
              <button
                type="button"
                onClick={() => setShowNextSessionDialog(false)}
                style={{
                  padding: '12px',
                  fontSize: 16,
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
                  setShowNextSessionDialog(false)
                  navigate(`/sessions/${encodeURIComponent(examType)}`)
                }}
                style={{
                  padding: '12px',
                  fontSize: 16,
                  border: '1px solid #ccc',
                  borderRadius: 8,
                  background: '#fff',
                  cursor: 'pointer',
                }}
              >
                목록
              </button>
              <button
                type="button"
                onClick={handleNextSessionConfirm}
                style={{
                  padding: '12px',
                  fontSize: 16,
                  border: '1px solid #333',
                  borderRadius: 8,
                  background: '#222',
                  color: '#fff',
                  cursor: 'pointer',
                }}
              >
                다음 회차
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
