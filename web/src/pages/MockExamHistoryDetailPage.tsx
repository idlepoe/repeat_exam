import {
  useEffect,
  useMemo,
  useRef,
  useState,
  type CSSProperties,
  type ReactNode,
} from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import {
  hasHistoryDetailPayload,
  loadMockHistory,
  type MockHistoryRecord,
} from '../lib/mockExamStorage'
import { BottomNavButtons } from '../components/BottomNavButtons'
import { loadNavReversed, saveNavReversed } from '../lib/storage'
import type { Question } from '../types/question'

function formatMockStartedAt(ts: number): string {
  return new Date(ts).toLocaleString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  })
}

export function MockExamHistoryDetailPage() {
  const navigate = useNavigate()
  const { historyId: rawHistoryId } = useParams<{ historyId: string }>()
  const historyId = rawHistoryId ? decodeURIComponent(rawHistoryId) : ''
  const [index, setIndex] = useState(0)
  const [showAnswerSheet, setShowAnswerSheet] = useState(false)
  const [showMoveListConfirm, setShowMoveListConfirm] = useState(false)
  const [navReversed, setNavReversed] = useState(() => loadNavReversed())
  const mainRef = useRef<HTMLDivElement>(null)

  const record = useMemo<MockHistoryRecord | null>(() => {
    if (!historyId) return null
    return loadMockHistory().find((item) => item.id === historyId) ?? null
  }, [historyId])

  useEffect(() => {
    mainRef.current?.scrollTo(0, 0)
  }, [index])

  if (!record || !hasHistoryDetailPayload(record)) {
    return (
      <div style={{ padding: 16 }}>
        <p style={{ marginTop: 0, marginBottom: 14 }}>
          상세 데이터를 찾을 수 없습니다.
        </p>
        <button
          type="button"
          onClick={() => navigate('/')}
          style={{
            padding: '10px 12px',
            border: '1px solid #ccc',
            borderRadius: 8,
            background: '#fff',
            cursor: 'pointer',
          }}
        >
          목록으로
        </button>
      </div>
    )
  }

  const questions = record.questions
  const answers = record.answers
  const total = questions.length
  const q = questions[index]

  const goPrev = () => {
    if (index > 0) setIndex((v) => v - 1)
  }

  const goNext = () => {
    if (index < total - 1) {
      setIndex((v) => v + 1)
      return
    }
    setShowMoveListConfirm(true)
  }

  const toggleNavOrder = () => {
    setNavReversed((prev) => {
      const next = !prev
      saveNavReversed(next)
      return next
    })
  }

  const appTitle = `모의고사 (${formatMockStartedAt(record.startedAt)})`

  return (
    <div
      style={{
        height: '100svh',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        maxWidth: '100%',
      }}
    >
      <header
        style={{
          position: 'sticky',
          top: 0,
          zIndex: 10,
          display: 'flex',
          flexWrap: 'wrap',
          alignItems: 'center',
          gap: 8,
          minHeight: 48,
          padding: '8px 10px',
          borderBottom: '1px solid #e5e4e7',
          background: '#fff',
          boxSizing: 'border-box',
        }}
      >
        <button
          type="button"
          onClick={() => navigate(-1)}
          style={headerBtnStyle}
        >
          뒤로가기
        </button>
        <div
          style={{
            flex: '1 1 120px',
            fontWeight: 600,
            fontSize: 14,
            textAlign: 'center',
          }}
        >
          {appTitle}
        </div>
        <button
          type="button"
          onClick={() => setShowAnswerSheet(true)}
          style={headerBtnStyle}
        >
          답안확인
        </button>
      </header>

      <main
        ref={mainRef}
        style={{
          flex: 1,
          minHeight: 0,
          overflowY: 'auto',
          WebkitOverflowScrolling: 'touch',
          padding: 16,
          paddingBottom: 8,
          fontSize: 16,
          lineHeight: 1.5,
          textAlign: 'left',
        }}
      >
        <div
          style={{
            fontSize: 15,
            fontWeight: 600,
            marginBottom: 8,
            color: '#333',
          }}
        >
          [{q.subject}] {index + 1}/{total}
        </div>
        <p style={{ margin: '0 0 16px' }}>
          <span style={{ fontWeight: 600 }}>{index + 1}.</span> {q.question_text}
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

        <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
          {q.choices.map((c) => {
            const picked = answers[q.id]
            const isCorrect = c.no === q.correct_answer
            const isPicked = picked === c.no
            const isWrongPick = isPicked && !isCorrect
            const bg = isCorrect ? '#eaf6ea' : isWrongPick ? '#fdeaea' : '#fafafa'
            const border = isCorrect ? '#7cb67c' : isWrongPick ? '#e28e8e' : '#ddd'
            const fg = isCorrect ? '#1b5e20' : isWrongPick ? '#b71c1c' : '#111'
            return (
              <li
                key={c.no}
                style={{
                  marginBottom: 10,
                  padding: '10px 12px',
                  border: `1px solid ${border}`,
                  borderRadius: 6,
                  background: bg,
                  color: fg,
                }}
              >
                {c.no}. {c.text}
                {isPicked ? (
                  <span style={{ marginLeft: 6, fontSize: 13, fontWeight: 600 }}>
                    (선택)
                  </span>
                ) : null}
              </li>
            )
          })}
        </ul>

        {q.aiExplanation ? (
          <section
            style={{
              marginTop: 18,
              padding: 12,
              border: '1px solid #e5e4e7',
              borderRadius: 8,
              background: '#fff',
            }}
            aria-label="AI 해설"
          >
            <h3 style={{ margin: '0 0 8px', fontSize: 16 }}>AI 해설</h3>

            <p style={{ margin: '0 0 10px' }}>
              <strong>정답 해설</strong>
              <br />
              {q.aiExplanation.correctExplanation}
            </p>

            <div style={{ marginBottom: 10 }}>
              <strong>오답 노트</strong>
              <ul style={{ margin: '6px 0 0 18px', padding: 0 }}>
                {q.aiExplanation.wrongAnswerNotes.map((note, i) => (
                  <li key={`${q.id}-ai-note-${i}`} style={{ marginBottom: 4 }}>
                    {note}
                  </li>
                ))}
              </ul>
            </div>

            <p style={{ margin: 0 }}>
              <strong>쪽집게</strong>
              <br />
              {q.aiExplanation.examTip}
            </p>
          </section>
        ) : null}
      </main>

      <BottomNavButtons
        navReversed={navReversed}
        prevDisabled={index <= 0}
        onPrev={goPrev}
        onNext={goNext}
        onToggleOrder={toggleNavOrder}
      />

      {showAnswerSheet && (
        <ModalOverlay>
          <ModalCard title="답안 확인">
            <div style={{ maxHeight: '60vh', overflowY: 'auto', marginBottom: 12 }}>
              {questions.map((qq: Question, i: number) => {
                const picked = answers[qq.id]
                const isCorrectPick = picked === qq.correct_answer
                const isWrongPick = picked !== undefined && picked !== qq.correct_answer
                const statusText =
                  picked === undefined
                    ? '미응답'
                    : isCorrectPick
                      ? '정답'
                      : '오답'
                const statusColor =
                  picked === undefined
                    ? '#777'
                    : isCorrectPick
                      ? '#1b5e20'
                      : '#b71c1c'

                return (
                  <button
                    key={qq.id}
                    type="button"
                    onClick={() => {
                      setIndex(i)
                      setShowAnswerSheet(false)
                    }}
                    style={{
                      display: 'block',
                      width: '100%',
                      textAlign: 'left',
                      padding: '10px 8px',
                      border: 'none',
                      borderBottom: '1px solid #eee',
                      background: i === index ? '#f0f7ff' : '#fff',
                      cursor: 'pointer',
                    }}
                  >
                    <div style={{ fontWeight: 600, fontSize: 13, marginBottom: 4 }}>
                      {i + 1}. {qq.question_text}
                    </div>
                    <div style={{ fontSize: 13, color: '#444' }}>
                      선택: {picked === undefined ? '—' : `${picked}번`} / 정답:{' '}
                      {qq.correct_answer}번
                    </div>
                    <div
                      style={{
                        marginTop: 2,
                        fontSize: 12,
                        fontWeight: 700,
                        color: statusColor,
                      }}
                    >
                      {statusText}
                      {isWrongPick ? ' (오답)' : ''}
                    </div>
                  </button>
                )
              })}
            </div>
            <button
              type="button"
              onClick={() => setShowAnswerSheet(false)}
              style={modalSecondaryBtn}
            >
              닫기
            </button>
          </ModalCard>
        </ModalOverlay>
      )}

      {showMoveListConfirm && (
        <ModalOverlay>
          <ModalCard title="안내">
            <p style={{ marginBottom: 16 }}>목록으로 이동하시겠습니까?</p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              <button
                type="button"
                onClick={() => navigate('/')}
                style={modalPrimaryBtn}
              >
                확인
              </button>
              <button
                type="button"
                onClick={() => setShowMoveListConfirm(false)}
                style={modalSecondaryBtn}
              >
                취소
              </button>
            </div>
          </ModalCard>
        </ModalOverlay>
      )}
    </div>
  )
}

const headerBtnStyle: CSSProperties = {
  padding: '6px 10px',
  border: '1px solid #ccc',
  borderRadius: 6,
  background: '#f8f8f8',
  cursor: 'pointer',
  fontSize: 13,
}

const modalPrimaryBtn: CSSProperties = {
  width: '100%',
  padding: '12px',
  fontSize: 16,
  border: '1px solid #333',
  borderRadius: 8,
  background: '#222',
  color: '#fff',
  cursor: 'pointer',
}

const modalSecondaryBtn: CSSProperties = {
  width: '100%',
  padding: '12px',
  fontSize: 16,
  border: '1px solid #ccc',
  borderRadius: 8,
  background: '#f5f5f5',
  cursor: 'pointer',
}

function ModalOverlay({ children }: { children: ReactNode }) {
  return (
    <div
      role="presentation"
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
      {children}
    </div>
  )
}

function ModalCard({
  title,
  children,
}: {
  title: string
  children: React.ReactNode
}) {
  return (
    <div
      role="dialog"
      aria-modal="true"
      style={{
        background: '#fff',
        borderRadius: 12,
        padding: 20,
        maxWidth: 420,
        width: '100%',
        boxShadow: '0 8px 24px rgba(0,0,0,0.2)',
      }}
    >
      <p style={{ margin: '0 0 14px', fontSize: 17, fontWeight: 600 }}>{title}</p>
      {children}
    </div>
  )
}
